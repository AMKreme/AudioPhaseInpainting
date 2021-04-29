# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Marina Kreme
"""
import matplotlib.pyplot as plt
from ltfatpy import plotdgt, tfplot
from experiment import PhasecutExperiment, get_stft_operators
from experiment_var_width import exp_instances
from problem_generation import generate_chirp_dirac_noise, generate_random_missing_phases

import matplotlib as mpl
mpl.rcParams['figure.figsize'] = 7, 7
mpl.rcParams['font.size'] = 22

name = 'pcwd_final'
missing_ratio=0.2
width = 5
exp = PhasecutExperiment.load_exp(name)

x = generate_chirp_dirac_noise(**exp.sig_params)
plt.figure()
plt.plot(x)
plt.savefig('signal.pdf', bbox_inches='tight')
plt.show()

stft, istft = exp.get_stft_operators()
X_ref = stft(x)
B, M = generate_random_missing_phases(X_ref,
                                      missing_ratio=missing_ratio,
                                      width=width)

# Generate problem
plt.figure()
plotdgt(coef=B, a=exp.stft_params['hop'], colorbar=False)
plt.savefig('spectro.pdf', bbox_inches='tight')
plt.show()

stft_params = exp.stft_params
stft_params['hop'] = 1
stft_params['nb_bins'] = exp.sig_params['sig_len']
print(stft_params)
stft, _, _ = get_stft_operators(sig_len=exp.sig_params['sig_len'],
                                 **stft_params)
X = stft(x)

fig=plt.figure()
plotdgt(coef=X, a=1)
plt.savefig('smooth_spectro.pdf', bbox_inches='tight')
plt.show()

plt.figure()
plotdgt(coef=M, a=exp.stft_params['hop'], colorbar=False)
plt.set_cmap('gray')
plt.savefig('mask.pdf', bbox_inches='tight')
plt.show()

