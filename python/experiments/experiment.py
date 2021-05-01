# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Valentin Emiya
"""

import pickle
import os
from pathlib import Path
import abc


from problem_generation \
    import generate_chirp_dirac_noise
from algorithms import get_stft_operators


class PhasecutExperiment:
    def __init__(self, name, win_len=16, hop=8, nb_bins=32):
        """

        Parameters
        ----------
        name : str
            Each instance should have a unique name used to recall it and
            store data in a dedicated folder.
        win_len
        hop
        nb_bins
        """
        self.name = name
        # Signal parameters
        self.sig_params = {'sig_len': 128, 'fs': 500, 'flim1': [0, 200],
                           'flim2': [200, 150], 'snr': 10}

        # STFT parameters
        self.stft_params = {'win_type': 'hann', 'win_len': win_len, 'hop': hop,
                            'nb_bins': nb_bins, 'phase_conv': 'freqinv'}
        self.x_ref = generate_chirp_dirac_noise(**self.sig_params)

    def __str__(self):
        s = 'Instance {}\n'.format(self.name)
        s += 'Signal parameters:\n'
        s += '    - signal length: {}\n'.format(self.sig_params['sig_len'])
        s += '    - sampling frequency: {}\n'.format(self.sig_params['fs'])
        s += '    - Chirp 1 in range {}Hz\n'.format(self.sig_params['flim1'])
        s += '    - Chirp 2 in range {}Hz\n'.format(self.sig_params['flim2'])
        s += '    - SNR: {}dB\n'.format(self.sig_params['snr'])
        s += 'STFT parameters:\n'
        s += '    - window: {}\n'.format(self.stft_params['win_type'])
        s += '    - window length: {}\n'.format(self.stft_params['win_len'])
        s += '    - hop size: {}\n'.format(self.stft_params['hop'])
        s += '    - number of bins: {}\n'.format(self.stft_params['nb_bins'])
        s += '    - phase convention: {}\n'.format(
            self.stft_params['phase_conv'])
        s += '{} tasks\n'.format(self.get_n_tasks())
        return s

    def save_exp(self):
        with open(PhasecutExperiment.get_exp_filename(self.name), 'wb') as f:
            pickle.dump(self, f, pickle.HIGHEST_PROTOCOL)

    @staticmethod
    def load_exp(name):
        with open(PhasecutExperiment.get_exp_filename(name), 'rb') as f:
            return pickle.load(f)

    def get_stft_operators(self):
        stft, _, istft = get_stft_operators(**self.stft_params,
                                            sig_len=self.sig_params['sig_len'])
        return stft, istft

    #########
    # Tasks #
    #########
    @abc.abstractmethod
    def get_n_tasks(self):
        raise NotImplementedError()

    def run_all_tasks(self):
        for i_task in range(self.get_n_tasks()):
            self.run_task(i_task)

    #####################
    # Files and folders #
    #####################
    @staticmethod
    def get_data_folder(name):
        exp_data = Path('exp_data')
        if not exp_data.exists():
            os.mkdir(exp_data)
        exp_data = exp_data / name
        if not exp_data.exists():
            os.mkdir(exp_data)
        return exp_data

    @staticmethod
    def get_exp_filename(name):
        return PhasecutExperiment.get_data_folder(name) / 'experiment.pickle'

    def get_task_filename(self, task_id):
        return PhasecutExperiment.get_data_folder(self.name) / 'task{}.npz'\
            .format(task_id)

    def get_results_filename(self):
        return PhasecutExperiment.get_data_folder(self.name) / 'results.npz'

    def get_figure_folder(self):
        fig_folder = PhasecutExperiment.get_data_folder(self.name) / 'figures'
        if not fig_folder.exists():
            os.mkdir(fig_folder)
        return fig_folder


# def run_task(name, task_id):
#     load_from_name(name).run_task(task_id)
#
#
# def run_all_tasks(name):
#     load_from_name(name).run_all_tasks()


def exp_results(name):
    loaded_exp = PhasecutExperiment.load_exp(name)
    print(loaded_exp)
    loaded_exp.collect_results()
    loaded_exp.plot_results()
