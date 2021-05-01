# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Valentin Emiya
"""
import datetime
import time
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat

from experiments.experiment import PhasecutExperiment, exp_results
from problem_generation import generate_random_missing_phases
from algorithms import phasecut_inpainting, PhasecutTracker, \
    random_phase_inpainting, griffin_lim_inpainting, GLTracker
from performance import compute_error


class PhasecutVarMissRatioExp(PhasecutExperiment):
    def __init__(self,
                 name, win_len=16, hop=8, nb_bins=32,
                 missing_ratios=np.arange(0, 1, 0.1),
                 phasecut_n_iter=1000, phasecut_nu=1e-4, gli_n_iter=5000):
        PhasecutExperiment.__init__(self, name,
                                    win_len=win_len, hop=hop, nb_bins=nb_bins)
        self.missing_ratios = missing_ratios
        # Solvers
        self.solvers = ['RPI', 'GLI', 'PCI']
        self.phasecut_params = {'n_iter': phasecut_n_iter, 'nu': phasecut_nu}
        self.gli_params = {'n_iter': gli_n_iter}

    def __str__(self):
        s = PhasecutExperiment.__str__(self)
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
        return self.missing_ratios.size * len(self.solvers)

    def get_task(self, task_id):
        i_solver, i_ratio = np.unravel_index(
            task_id, (len(self.solvers), self.missing_ratios.size))
        return i_solver, i_ratio

    def run_task(self, task_id):
        i_solver, i_ratio = self.get_task(task_id)
        solver = self.solvers[i_solver]
        ratio = self.missing_ratios[i_ratio]
        start_time = datetime.datetime.now()
        print('Task', task_id)
        print('Start at', start_time)
        print('{:%}% missing phases'.format(ratio))
        print('Solver: {}'.format(solver))

        # Generate problem
        stft, istft = self.get_stft_operators()
        X_ref = stft(self.x_ref)
        B, M = generate_random_missing_phases(X_ref, missing_ratio=ratio)

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
                 x_est=x_est, ratio=ratio, solver=solver, runtime=runtime,
                 track_iter=track_iter, track_error=track_error)

        print('End at', datetime.datetime.now())

    def plot_task_results(self, task_id):
        filename = self.get_task_filename(task_id=task_id)
        print('Load ', filename)
        data = np.load(filename)

        plt.figure()
        plt.plot(self.x_ref)
        plt.plot(np.real(data['x_est']))
        plt.plot(np.imag(data['x_est']))

        plt.figure()
        plt.plot(data['track_iter'], data['track_error'])
        print('Run time: {}'.format(data['runtime']))

    def collect_results(self):
        n_miss = self.missing_ratios.size
        n_solvers = len(self.solvers)
        x_est = np.full((self.sig_params['sig_len'], n_solvers, n_miss),
                        np.nan, dtype=complex)
        track_iter = [[None for _ in range(n_miss)] for _ in range(n_solvers)]
        track_error = [[None for _ in range(n_miss)] for _ in range(n_solvers)]
        runtime = np.full((n_solvers, n_miss), np.nan)
        reconstruction_error = np.full((n_solvers, n_miss), np.nan)
        for i_task in range(self.get_n_tasks()):
            i_solver, i_ratio = self.get_task(i_task)
            filename = self.get_task_filename(task_id=i_task)
            if Path(filename).exists():
                print('.', end='')
                data = np.load(filename,allow_pickle=True)
                x_est[:, i_solver, i_ratio] = data['x_est']
                track_iter[i_solver][i_ratio] = data['track_iter']
                track_error[i_solver][i_ratio] = data['track_error']
                runtime[i_solver, i_ratio] = data['runtime']
                reconstruction_error[i_solver, i_ratio] = \
                    compute_error(x_ref=self.x_ref,
                                  x_est=x_est[:, i_solver, i_ratio])
            else:
                print('M', end='')
        np.savez(self.get_results_filename(), x_est=x_est,
                 track_iter=track_iter, track_error=track_error,
                 reconstruction_error=reconstruction_error,
                 runtime=runtime, x_ref=self.x_ref)
        print('')

    def plot_results(self):
        # mat20 = loadmat('mat_files/rescomp_alea_chirp3128_10lambda=1e-20.mat')
        mat30 = loadmat('mat_files/average_results_pli.mat')
        miss_r = np.arange(0,1.1,0.1)
        res = np.load(self.get_results_filename(),allow_pickle=True)
        plt.figure()
        for i_solver in range(len(self.solvers)):
            plt.plot(self.missing_ratios,
                     res['reconstruction_error'][i_solver, :],
                     label=self.solvers[i_solver])
        # plt.plot(mat20['d'].flat, mat20['err_dB_Lift'].flat, label='PLI-20')
        # plt.plot(mat30['d'].flat, mat30['err_dB_Lift'].flat, label='PLI-30')
        plt.plot(miss_r, mat30['mean_pli_var_miss_ratio'].flat, label='PLI')
        plt.legend()
        plt.xlabel('Ratio of missing phases')
        plt.ylabel('Error (dB)')
        plt.grid()
        # plt.title('')
        plt.savefig(str(self.get_figure_folder() / '{}_err_ratio.pdf'
                        .format(self.name)), bbox_inches='tight')
        plt.show()

        for i_solver in range(len(self.solvers)):
            if self.solvers[i_solver] == 'RPI':
                continue
            plt.figure()
            for i_ratio in range(self.missing_ratios.size):
                plt.plot(
                    res['track_iter'][i_solver][i_ratio],
                    res['track_error'][i_solver][i_ratio],
                    label='{:.0%} missing'.format(
                        self.missing_ratios[i_ratio]))
            plt.xlabel('Iterations')
            plt.ylabel('Error (dB)')
            plt.grid()
            plt.title('Convergence of {}'.format(self.solvers[i_solver]))
            plt.legend()
            plt.savefig(str(self.get_figure_folder() / '{}_err_iter_{}.pdf')
                        .format(self.name, self.solvers[i_solver]), bbox_inches='tight')
            plt.show()


def create_exp(name):
    exp = PhasecutVarMissRatioExp(name=name, **exp_instances[name])
    exp.save_exp()
    print(exp)


exp_instances = {
    'pcmi_small': {'win_len': 16,
                   'hop': 8,
                   'nb_bins': 32,
                   'missing_ratios': np.arange(0, 1, 0.2),
                   'phasecut_n_iter': 100,
                   'phasecut_nu': 1e-14,
                   'gli_n_iter': 100},
    'pcmi_large': {'win_len': 16,
                   'hop': 8,
                   'nb_bins': 32,
                   'missing_ratios': np.arange(0, 1, 0.1),
                   'phasecut_n_iter': 10000,
                   'phasecut_nu': 1e-14,
                   'gli_n_iter': 3000},
    'pcmi_final': {'win_len': 16,
                   'hop': 8,
                   'nb_bins': 32,
                   'missing_ratios': np.arange(0, 1, 0.1),
                   'phasecut_n_iter': 50000,
                   'phasecut_nu': 1e-14,
                   'gli_n_iter': 3000},
    'pcmi_final100': {'win_len': 16,
                      'hop': 8,
                      'nb_bins': 32,
                      'missing_ratios': np.arange(0, 1, 0.1),
                      'phasecut_n_iter': 100000,
                      'phasecut_nu': 1e-14,
                      'gli_n_iter': 6000},
    'pcmi_h2b2': {'win_len': 16,
                  'hop': 4,
                  'nb_bins': 64,
                  'missing_ratios': np.arange(0, 1, 0.1),
                  'phasecut_n_iter': 10000,
                  'phasecut_nu': 1e-14,
                  'gli_n_iter': 3000},
    'pcmi_h2': {'win_len': 16,
                'hop': 4,
                'nb_bins': 32,
                'missing_ratios': np.arange(0, 1, 0.1),
                'phasecut_n_iter': 10000,
                'phasecut_nu': 1e-14,
                'gli_n_iter': 3000},
    'pcmi_b2': {'win_len': 16,
                'hop': 8,
                'nb_bins': 64,
                'missing_ratios': np.arange(0, 1, 0.1),
                'phasecut_n_iter': 10000,
                'phasecut_nu': 1e-14,
                'gli_n_iter': 3000},
}


def run_exp(name):
    create_exp(name)
    PhasecutVarMissRatioExp.load_exp(name).run_all_tasks()
    exp_results(name)


def create_all():
    for name in exp_instances.keys():
        create_exp(name)


if __name__ == '__main__':
    # exp_results('small_exp')
    run_exp('pcmi_small')
    # run_exp('small_exp')
    # run_exp('hop2_exp')
    # run_exp('bins2_exp')
    
    # run_exp('hop2_bins2_exp')
    # run_exp('large_exp')
    #exp_results('pcmi_final100')
