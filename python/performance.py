# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Valentin Emiya
"""
import numpy as np


def fix_global_phase(x_ref, x_est):
    phase_diff = np.angle(np.vdot(x_est, x_ref))
    return x_est * np.exp(1j * phase_diff)


def compute_error(x_ref, x_est):
    x_est = fix_global_phase(x_ref=x_ref, x_est=x_est)
    return 20 * np.log10(np.linalg.norm(x_ref-x_est) / np.linalg.norm(x_ref))
