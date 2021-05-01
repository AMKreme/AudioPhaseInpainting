# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Valentin Emiya
"""

# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Valentin Emiya
"""
import datetime
import time
from pathlib import Path

import numpy as np
from scipy.io import savemat, loadmat
import matplotlib.pyplot as plt
from ltfatpy import plotdgt

from experiments.experiment import PhasecutExperiment, exp_results
from problem_generation import generate_random_missing_phases
from algorithms import phasecut_inpainting, PhasecutTracker, \
    random_phase_inpainting, griffin_lim_inpainting, GLTracker
from performance import compute_error
from algorithms import phaselift_signal_reconstruction

class PhasecutVarWidthExp(PhasecutExperiment):
    def __init__(self,
                 name, win_len=16, hop=8, nb_bins=32,
                 widths=np.arange(1, 11, 2),
                 missing_ratios=np.arange(0.1, 0.7, 0.2),
                 phasecut_n_iter=1000, phasecut_nu=1e-4, gli_n_iter=5000):
        PhasecutExperiment.__init__(self, name,
                                    win_len=win_len, hop=hop, nb_bins=nb_bins)
        self.widths = widths
        self.missing_ratios = missing_ratios
        # Solvers
        self.solvers = ['RPI', 'GLI', 'PCI']
        self.phasecut_params = {'n_iter': phasecut_n_iter, 'nu': phasecut_nu}
        self.gli_params = {'n_iter': gli_n_iter}

    def __str__(self):
        s = PhasecutExperiment.__str__(self)
        s += 'Widths of holes: {}\n'.format(self.widths)
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
        return len(self.solvers) * self.missing_ratios.size * self.widths.size

    def get_task(self, task_id):
        i_solver, i_ratio, i_width = np.unravel_index(
            task_id,
            (len(self.solvers), self.missing_ratios.size, self.widths.size))
        
        return i_solver, i_ratio, i_width

    def get_problem_data(self, ratio, width):
        stft, istft = self.get_stft_operators()
        X_ref = stft(self.x_ref)
        B, M = generate_random_missing_phases(X_ref,
                                              missing_ratio=ratio,
                                              width=width)
        return B, M, stft, istft

    def export_problem_data(self):
        for ratio in self.missing_ratios:
            for width in self.widths:
                B, M, _, _ = self.get_problem_data(ratio=ratio, width=width)
                savemat(str(PhasecutExperiment.get_data_folder(self.name)
                            / '{}_{}_{}.mat'.format(self.name, ratio, width)),
                        {'B': B, 'M': M, 'x_ref': self.x_ref,
                         **self.sig_params, **self.stft_params})

    def run_task(self, task_id):
        start_time = datetime.datetime.now()
        print('Task', task_id)
        print('Start at', start_time)

        i_solver, i_ratio, i_width = self.get_task(task_id)

        ratio = self.missing_ratios[i_ratio]
        width = self.widths[i_width]
        solver = self.solvers[i_solver]
        print('{:%}% missing phases, width={}'.format(ratio, width))
        print('Solver: {}'.format(solver))

        # Generate problem
        B, M, stft, istft = self.get_problem_data(ratio=ratio, width=width)

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
                                        nu=self.phasecut_params['nu'],
                                        verbose_it=100, tracker=tracker)
            runtime = time.process_time() - t0
            track_iter = tracker.iter
            track_error = tracker.error
        else:
            raise ValueError('Unknown solver: {}'.format(solver))

        # Save results
        np.savez(self.get_task_filename(task_id=task_id),
                 x_est=x_est, ratio=ratio, solver=solver, width=width,
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

        i_solver, i_ratio, i_width = self.get_task(task_id)
        ratio = self.missing_ratios[i_ratio]
        width = self.widths[i_width]
        solver = self.solvers[i_solver]

        # Generate problem
        B, M, stft, istft = self.get_problem_data(ratio=ratio, width=width)
        plt.figure()
        plotdgt(coef=B, a=self.stft_params['hop'])
        plt.show()
        plt.figure()
        plotdgt(coef=M, a=self.stft_params['hop'])
        plt.show()


    def collect_results(self):
        n_miss = self.missing_ratios.size
        n_solvers = len(self.solvers)
        n_width = self.widths.size
        x_est = np.full(
            (self.sig_params['sig_len'], n_solvers, n_miss, n_width),
            np.nan, dtype=complex)
        track_iter = [[[None for _ in range(n_width)] for _ in range(n_miss)]
                      for _ in range(n_solvers)]
        track_error = [[[None for _ in range(n_width)] for _ in range(n_miss)]
                       for _ in range(n_solvers)]
        runtime = np.full((n_solvers, n_miss, n_width), np.nan)
        reconstruction_error = np.full((n_solvers, n_miss, n_width), np.nan)
        for i_task in range(self.get_n_tasks()):
            i_solver, i_ratio, i_width = self.get_task(i_task)
            filename = self.get_task_filename(task_id=i_task)
            if Path(filename).exists():
                print('.', end='')
                data = np.load(filename,allow_pickle=True)
                x_est[:, i_solver, i_ratio, i_width] = data['x_est']
                track_iter[i_solver][i_ratio][i_width] = data['track_iter']
                track_error[i_solver][i_ratio][i_width] = data['track_error']
                runtime[i_solver, i_ratio, i_width] = data['runtime']
                reconstruction_error[i_solver, i_ratio, i_width] = \
                    compute_error(x_ref=self.x_ref,
                                  x_est=x_est[:, i_solver, i_ratio, i_width])
            else:
                print('M', end='')
        np.savez(self.get_results_filename(), x_est=x_est,
                 track_iter=track_iter, track_error=track_error,
                 reconstruction_error=reconstruction_error,
                 runtime=runtime, x_ref=self.x_ref)
        print('')


    def plot_results(self):
        res = np.load(self.get_results_filename(),allow_pickle=True)
        print("dim res=",res['reconstruction_error'].shape)
        for i_ratio in range(self.missing_ratios.size):
            plt.figure()
            for i_solver in range(len(self.solvers)):
                plt.plot(self.widths,
                         res['reconstruction_error'][i_solver, i_ratio, :],
                         label=self.solvers[i_solver])
            if self.missing_ratios[i_ratio] == 0.5:
                pli_error = np.full(5, fill_value=np.nan)
                for i in range(5):
                    try:
                        refmat = loadmat(
                            'mat_files/pcwd_large_0.5000000000000001_{}.mat'
                            .format(2 * i + 1))
                        mat = loadmat(
                            'mat_files/Sol_pcwd_large_0.5000000000000001_{}.mat.mat'
                            .format(2 * i + 1))
                        x_pli = phaselift_signal_reconstruction(mat['Sol'])
                        pli_error[i] = compute_error(refmat['x_ref'], x_pli)
                    except FileNotFoundError as e:
                        print(e)
                print(pli_error)
                plt.plot(self.widths[~np.isnan(pli_error)],
                         pli_error[~np.isnan(pli_error)],
                         label='PLI')
            elif self.missing_ratios[i_ratio] == 0.3:
                pli_error = np.full(5, fill_value=np.nan)
                for i in range(5):
                    try:
                        refmat = loadmat(
                            'mat_files/pcwd_large_0.30000000000000004_{}.mat'
                            .format(2 * i + 1))
                        mat = loadmat(
                            'mat_files/Sol_pcwd_large_0.30000000000000004_{}.mat.mat'
                            .format(2 * i + 1))
                        x_pli = phaselift_signal_reconstruction(mat['Sol'])
                        pli_error[i] = compute_error(refmat['x_ref'], x_pli)
                    except FileNotFoundError as e:
                        print(e)
                print(pli_error)
                plt.plot(self.widths[~np.isnan(pli_error)],
                         pli_error[~np.isnan(pli_error)],
                         label='PLI')
            else:
                pli_error = np.full(5, fill_value=np.nan)
            plt.legend()
            plt.xlabel('Hole width')
            plt.ylabel('Error (dB)')
            plt.grid()
            plt.title('{:.0%} missing phases'
                      .format(self.missing_ratios[i_ratio]))
            plt.savefig(str(self.get_figure_folder() / '{}_err_ratio{:.0f}.pdf'
                            .format(self.name,
                                    self.missing_ratios[i_ratio]*100)), bbox_inches='tight')
            plt.show()

        for i_solver in range(len(self.solvers)):
            if self.solvers[i_solver] == 'RPI':
                continue
            for i_ratio in range(self.missing_ratios.size):
                plt.figure()
                for i_width in range(self.widths.size):
                    plt.plot(
                        res['track_iter'][i_solver][i_ratio][i_width],
                        res['track_error'][i_solver][i_ratio][i_width],
                        label='width: {}'.format(self.widths[i_width]))
                plt.xlabel('Iterations')
                plt.ylabel('Error (dB)')
                plt.grid()
                plt.title('Convergence of {}, {:.0%} missing'.format(
                    self.solvers[i_solver], self.missing_ratios[i_ratio]))
                plt.legend()
                plt.savefig(str(self.get_figure_folder() /
                                '{}_err_iter_{}_miss{:.0f}.pdf')
                            .format(self.name,
                                    self.solvers[i_solver],
                                    self.missing_ratios[i_ratio]*100), bbox_inches='tight')
                plt.show()


def create_exp(name):
    exp = PhasecutVarWidthExp(name=name, **exp_instances[name])
    exp.save_exp()
    exp.export_problem_data()
    print(exp)


exp_instances = {
    'pcwd_small': {'win_len': 16,
                   'hop': 8,
                   'nb_bins': 32,
                   'widths': np.array([1, 5]),
                   'missing_ratios': np.arange(0.2, 0.6, 0.2),
                   'phasecut_n_iter': 50,
                   'phasecut_nu': 1e-14,
                   'gli_n_iter': 50},
    'pcwd_large': {'win_len': 16,
                   'hop': 8,
                   'nb_bins': 32,
                   'widths': np.arange(1, 11, 2),
                   'missing_ratios': np.arange(0.1, 0.7, 0.2),
                   'phasecut_n_iter': 10000,
                   'phasecut_nu': 1e-14,
                   'gli_n_iter': 6000},
    'pcwd_final': {'win_len': 16,
                   'hop': 8,
                   'nb_bins': 32,
                   'widths': np.arange(1, 11, 2),
                   'missing_ratios': np.arange(0.1, 0.7, 0.2),
                   'phasecut_n_iter': 50000,
                   'phasecut_nu': 1e-14,
                   'gli_n_iter': 6000},
    'pcwd_final100': {'win_len': 16,
                   'hop': 8,
                   'nb_bins': 32,
                   'widths': np.arange(1, 11, 2),
                   'missing_ratios': np.arange(0.3, 0.7, 0.2),
                   'phasecut_n_iter': 100000,
                   'phasecut_nu': 1e-14,
                   'gli_n_iter': 6000},
    'pcwd_h2b2': {'win_len': 16,
                  'hop': 4,
                  'nb_bins': 64,
                  'widths': np.arange(1, 11, 2),
                  'missing_ratios': np.arange(0.1, 0.7, 0.2),
                  'phasecut_n_iter': 10000,
                  'phasecut_nu': 1e-14,
                  'gli_n_iter': 6000},
}


def run_exp(name):
    create_exp(name)
    PhasecutVarWidthExp.load_exp(name).run_all_tasks()
    exp_results(name)


def create_all():
    for name in exp_instances.keys():
        create_exp(name)


if __name__ == '__main__':
    run_exp('pcwd_small')
    # exp_results('pliw_small')
    #exp_results('pcwd_final100')
