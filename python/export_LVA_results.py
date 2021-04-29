# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Marina Kreme
"""
from os import mkdir
from shutil import copy
from pathlib import Path
from experiment import PhasecutExperiment
import matplotlib as mpl

mpl.rcParams['figure.figsize'] = 7, 6
mpl.rcParams['font.size'] = 18

# mpl.rcParams['figure.figsize'] = 16, 5

exp_names = ['pcmi_final', 'pcwd_final',]
fig_files = [
    'exp_data/pcmi_final/figures/pcmi_final_err_ratio.pdf',
    'exp_data/pcmi_final/figures/pcmi_final_err_iter_PCI.pdf',
    'exp_data/pcwd_final/figures/pcwd_final_err_iter_PCI_miss50.pdf',
    'exp_data/pcwd_final/figures/pcwd_final_err_ratio50.pdf',
    'exp_data/pcwd_final/figures/pcwd_final_err_iter_PCI_miss30.pdf',
    'exp_data/pcwd_final/figures/pcwd_final_err_ratio30.pdf',
]
fig_dir = Path('../../2017_Dossier_article/2018_LVAICA/figures')

if not fig_dir.exists():
    mkdir(fig_dir)

for name in exp_names:
    try:
        exp = PhasecutExperiment.load_exp(name)
        exp.plot_results()
    except FileNotFoundError as err:
        print(err)

for filename in fig_files:
    copy(filename, fig_dir)
