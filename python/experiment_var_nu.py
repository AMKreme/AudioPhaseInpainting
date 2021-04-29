# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Marina Kreme
"""

import datetime
import time
from pathlib import Path

import numpy as np
from scipy.io import savemat, loadmat
import matplotlib.pyplot as plt

from experiment import PhasecutExperiment, exp_results
from problem_generation import generate_random_missing_phases
from algorithms import phasecut_inpainting, PhasecutTracker, \
    random_phase_inpainting, griffin_lim_inpainting, GLTracker
from performance import compute_error


class PhasecutVarWidthNu(PhasecutExperiment):
    def __init__(self,
                 name, win_len=16, hop=8, nb_bins=32,
                 nus=10.0 ** np.arange(-20, 10),
                 missing_ratios=np.arange(0.1, 0.7, 0.2),
                 phasecut_n_iter=1000, gli_n_iter=5000):
        PhasecutExperiment.__init__(self, name,
                                    win_len=win_len, hop=hop, nb_bins=nb_bins)
        self.nus = nus
        self.missing_ratios = missing_ratios
        # Solvers
        self.solvers = ['PCI']
        self.phasecut_params = {'n_iter': phasecut_n_iter, 'nu': None}
        self.gli_params = {'n_iter': gli_n_iter}

    def __str__(self):
        s = PhasecutExperiment.__str__(self)
        s += 'Nu values: {}\n'.format(self.nus)
        s += 'Ratios of missing data: {}\n'.format(self.missing_ratios)
        s += 'Solvers: {}\n'.format(self.solvers)
        s += 'GLI params: {} iterations\n'.format(self.gli_params['n_iter'])
        s += 'PCI params: {} iterations, nu={}\n'.format(
            self.phasecut_params['n_iter'], self.phasecut_params['nu'])
        return s

    #########
    # Tasks #
    #########
    def get_n_tasks(self):
        return len(self.solvers) * self.missing_ratios.size * self.nus.size

    def get_task(self, task_id):
        i_solver, i_ratio, i_nu = np.unravel_index(
            task_id,
            (len(self.solvers), self.missing_ratios.size, self.nus.size))
        return i_solver, i_ratio, i_nu

    def get_problem_data(self, ratio):
        stft, istft = self.get_stft_operators()
        X_ref = stft(self.x_ref)
        B, M = generate_random_missing_phases(X_ref, missing_ratio=ratio)
        return B, M, stft, istft

    def export_problem_data(self):
        for ratio in self.missing_ratios:
            B, M, _, _ = self.get_problem_data(ratio=ratio)
            savemat(str(PhasecutExperiment.get_data_folder(self.name)
                        / '{}_{}.mat'.format(self.name, ratio)),
                    {'B': B, 'M': M,
                     **self.sig_params, **self.stft_params})

    def run_task(self, task_id):
        start_time = datetime.datetime.now()
        print('Task', task_id)
        print('Start at', start_time)

        i_solver, i_ratio, i_nu = self.get_task(task_id)
        ratio = self.missing_ratios[i_ratio]
        nu = self.nus[i_nu]
        solver = self.solvers[i_solver]
        print('{:%}% missing phases, nu={}'.format(ratio, nu))
        print('Solver: {}'.format(solver))

        # Generate problem
        B, M, stft, istft = self.get_problem_data(ratio=ratio)

        if solver == 'RPI':
            # Solve problem
            t0 = time.process_time()
            x_est = random_phase_inpainting(M=M, B=B, istft=istft)
            runtime = time.process_time() - t0
            track_iter = None
            track_error = None
        elif solver == 'GLI':
            # Build tracker
            tracker = GLTracker(x_ref=self.x_ref, istft=istft)

            # Solve problem
            t0 = time.process_time()
            x_est = griffin_lim_inpainting(M=M, B=B, stft=stft, istft=istft,
                                           n_iter=self.gli_params['n_iter'],
                                           verbose_it=100, tracker=tracker)
            runtime = time.process_time() - t0
            track_iter = tracker.iter
            track_error = tracker.error
        elif solver == 'PCI':
            # Build tracker
            tracker = PhasecutTracker(x_ref=self.x_ref, B=B, istft=istft)

            # Solve problem
            t0 = time.process_time()
            x_est = phasecut_inpainting(M=M, B=B, stft=stft, istft=istft,
                                        n_iter=self.phasecut_params['n_iter'],
                                        nu=nu,
                                        verbose_it=100, tracker=tracker)
            runtime = time.process_time() - t0
            track_iter = tracker.iter
            track_error = tracker.error
        else:
            raise ValueError('Unknown solver: {}'.format(solver))

        # Save results
        np.savez(self.get_task_filename(task_id=task_id),
                 x_est=x_est, ratio=ratio, solver=solver, nu=nu,
                 runtime=runtime,
                 track_iter=track_iter, track_error=track_error)

        print('End at', datetime.datetime.now())

    def plot_task_results(self, task_id):
        filename = self.get_task_filename(task_id=task_id)
        print('Load ', filename)
        data = np.load(filename)

        plt.figure()
        plt.plot(self.x_ref)
        plt.plot(data['x_est'])

        plt.figure()
        plt.plot(data['track_iter'], data['track_error'])
        print('Run time: {}'.format(data['runtime']))

    def collect_results(self):
        n_miss = self.missing_ratios.size
        n_solvers = len(self.solvers)
        n_nu = self.nus.size
        x_est = np.full((self.sig_params['sig_len'], n_solvers, n_miss, n_nu),
                        np.nan, dtype=complex)
        track_iter = [[[None for _ in range(n_nu)] for _ in range(n_miss)]
                      for _ in range(n_solvers)]
        track_error = [[[None for _ in range(n_nu)] for _ in range(n_miss)]
                       for _ in range(n_solvers)]
        runtime = np.full((n_solvers, n_miss, n_nu), np.nan)
        reconstruction_error = np.full((n_solvers, n_miss, n_nu), np.nan)
        for i_task in range(self.get_n_tasks()):
            i_solver, i_ratio, i_nu = self.get_task(i_task)
            filename = self.get_task_filename(task_id=i_task)
            if Path(filename).exists():
                print('Load ', filename)
                data = np.load(filename)
                x_est[:, i_solver, i_ratio, i_nu] = data['x_est']
                track_iter[i_solver][i_ratio][i_nu] = data['track_iter']
                track_error[i_solver][i_ratio][i_nu] = data['track_error']
                runtime[i_solver, i_ratio, i_nu] = data['runtime']
                reconstruction_error[i_solver, i_ratio, i_nu] = \
                    compute_error(x_ref=self.x_ref,
                                  x_est=x_est[:, i_solver, i_ratio, i_nu])
            else:
                print('Missing file: ', filename)
        np.savez(self.get_results_filename(), x_est=x_est,
                 track_iter=track_iter, track_error=track_error,
                 reconstruction_error=reconstruction_error,
                 runtime=runtime, x_ref=self.x_ref)

    def plot_results(self):
        res = np.load(self.get_results_filename())
        for i_ratio in range(self.missing_ratios.size):
            plt.figure()
            for i_solver in range(len(self.solvers)):
                plt.semilogx(self.nus,
                             res['reconstruction_error'][i_solver, i_ratio, :],
                             label=self.solvers[i_solver])
            plt.legend()
            plt.xlabel('Nu')
            plt.ylabel('Error (dB)')
            plt.title('{:.0%} missing phases'
                      .format(self.missing_ratios[i_ratio]))
            plt.savefig(str(self.get_figure_folder() / 'err_nu.pdf'))
            plt.show()

        for i_solver in range(len(self.solvers)):
            if self.solvers[i_solver] == 'RPI':
                continue
            for i_ratio in range(self.missing_ratios.size):
                plt.figure()
                for i_nu in range(self.nus.size):
                    plt.plot(
                        res['track_iter'][i_solver][i_ratio][i_nu],
                        res['track_error'][i_solver][i_ratio][i_nu],
                        label='nu: {}'.format(self.nus[i_nu]))
                plt.xlabel('Iterations')
                plt.ylabel('Error')
                plt.title('{:.0%} missing, solver {}'.format(
                    self.missing_ratios[i_ratio], self.solvers[i_solver]))
                plt.legend()
                plt.savefig(str(self.get_figure_folder() /
                                'err_iter_{}_miss{}.pdf')
                            .format(self.solvers[i_solver],
                                    self.missing_ratios[i_ratio]))
                plt.show()


def create_exp(name):
    exp = PhasecutVarWidthNu(name=name, **exp_instances[name])
    exp.save_exp()
    exp.export_problem_data()
    print(exp)


exp_instances = {
    'pcnu_small': {'win_len': 16,
                   'hop': 8,
                   'nb_bins': 32,
                   'nus': 10.0 ** np.arange(-5, 0),
                   'missing_ratios': np.arange(0.2, 0.6, 0.2),
                   'phasecut_n_iter': 50,
                   'gli_n_iter': 50},
    'pcnu_large': {'win_len': 16,
                   'hop': 8,
                   'nb_bins': 32,
                   'nus': 10.0 ** np.arange(-20, 10),
                   'missing_ratios': np.array((0.1, 0.2, 0.4, 0.8)),
                   'phasecut_n_iter': 10000,
                   'gli_n_iter': 3000},
    'pcnu_h2b2': {'win_len': 16,
                  'hop': 4,
                  'nb_bins': 64,
                  'nus': 10.0 ** np.arange(-20, 10),
                  'missing_ratios': np.array((0.1, 0.2, 0.4, 0.8)),
                  'phasecut_n_iter': 10000,
                  'gli_n_iter': 3000},
}


def run_exp(name):
    create_exp(name)
    PhasecutVarWidthNu.load_exp(name).run_all_tasks()
    exp_results(name)



def create_all():
    for name in exp_instances.keys():
        create_exp(name)


if __name__ == '__main__':
    run_exp('pcnu_small')
    
    #exp_results('pcnu_small')
