# -*- coding: utf-8 -*-
"""

@author: marina
"""
import numpy as np
from scipy.sparse.linalg import eigsh
from ltfatpy import dgt, idgt, gabwin, gabdual
import matplotlib.pyplot as plt

from performance import fix_global_phase, compute_error


def random_phase_inpainting(M, B, istft):
    X = B.copy()
    X[~M] *= np.exp(1j*2*np.pi*np.random.rand(np.count_nonzero(~M)))
    return istft(X)


def griffin_lim_inpainting(M, B, stft, istft, n_iter, verbose_it=100,
                           tracker=None):
    X = B.copy()
    X[~M] *= np.exp(1j*2*np.pi*np.random.rand(np.count_nonzero(~M)))
    C = np.abs(B[~M])
    for i in range(n_iter):
        if tracker is not None:
            tracker.update(X, i)
        X[:] = stft(istft(X))
        X[M] = B[M]
        X[~M] = C * np.exp(1j*np.angle(X[~M]))
    if tracker is not None:
        tracker.update(X, n_iter)
    return istft(X)


class GLTracker():
    def __init__(self, x_ref, istft):
        self.error = []
        self.iter = []
        self.x_ref = x_ref
        self.istft = istft

    def update(self, X, i):
        self.iter.append(i)
        x_est = self.istft(X)
        err = compute_error(x_ref=self.x_ref, x_est=x_est)
        self.error.append(err)


def phasecut_inpainting(M, B, stft, istft, n_iter, nu=1e-4, verbose_it=1000,
                        tracker=None):
    U = phasecut_bcd(M=M, B=B, tfct=stft, tfctinv=istft, n_iter=n_iter,
                     nu=nu, verbose_it=verbose_it, tracker=tracker)
    
    return phasecut_signal_reconstruction(U, B, istft)


def phasecut_bcd(M, B, tfct, tfctinv, n_iter, nu=1e-4, verbose_it=1000,
                 tracker=None):
    """

    Parameters
    ----------
    M : bool nd-array [F,T]
    B : complex nd-array [F,T]
    tfct : function
    tfctinv : function
    niter : int
    nu : real

    Returns
    -------
    U : complex nd-array [FT, FT]
    """
    mvec = M.ravel()
    nbmeas = M.size
    C = np.abs(B)
    U = np.eye(nbmeas, dtype=complex)
    um = np.exp(1j*np.angle(B[M]))
    U[np.ix_(mvec, mvec)] = np.outer(um, np.conjugate(um))
    ind_unknown = np.nonzero(~mvec)[0]
    if ind_unknown.size == 0:
        n_iter = 0
    ic = np.ones(nbmeas, dtype=bool)
    for i_iter in range(n_iter):
        if i_iter % verbose_it == 0:
            print('Iteration ', i_iter)
        i = np.random.choice(ind_unknown)
        ic[:] = 1
        ic[i] = 0

        x = _applyM_ic_i(U, C, tfct, tfctinv, i)
        gamma = _applyM_ic_i(np.conjugate(x)[None, :], C, tfct, tfctinv, i)
        x = x[ic]

        if gamma > 0:
            U[ic, i] = -np.sqrt((1-nu) / gamma) * x
            U[i, ic] = np.conjugate(U[ic, i])
        else:
            U[ic, i] = 0
            U[i, ic] = 0
        if tracker is not None:
            tracker.update(U, i_iter)
    return U


def phasecut_signal_reconstruction(U, B, istft):
    eig_val, eig_vec = eigsh(U, k=1)
    u = np.sqrt(eig_val[0]) * eig_vec[:, 0]
    u = np.exp(1j*np.angle(u))
    return istft(np.abs(B) * u.reshape(B.shape))


def phaselift_signal_reconstruction(X):
    eig_val, eig_vec = eigsh(X, k=1)
    x = np.sqrt(eig_val[0]) * eig_vec[:, 0]
    return x


def _applyM_ic_i(Y, c, tfct, tfctinv, i):
    if np.iscomplexobj(c):
        raise ValueError('Not implemented with complex values for c')
    Z = np.conjugate(Y)
    Z[:, i] = 0 # warning: do not modify the original Y[i, i] inplace!
    for j in range(Z.shape[0]):
        Z[j, :] -= tfct(tfctinv(c * Z[j, :].reshape(c.shape))).reshape(-1)
    Z = np.conjugate(Z) * c.reshape((1, -1))
    return Z[:, i]


def get_stft_operators(win_type='hann', win_len=16, hop=8, nb_bins=32,
                       sig_len=128, phase_conv= 'freqinv'):
    w = gabwin(g={'name': win_type, 'M': win_len}, a=hop, M=nb_bins,
               L=sig_len)[0]
    wd = gabdual(w, a=hop, M=nb_bins, L=sig_len)
    direct_stft = \
        lambda x:dgt(x, g=w, a=hop, M=nb_bins, L=sig_len, pt=phase_conv)[0]
    adjoint_stft = \
        lambda x:idgt(x, g=w, a=hop, Ls=sig_len, pt=phase_conv)[0]
    pseudoinverse_stft = \
        lambda x:idgt(x, g=wd, a=hop, Ls=sig_len, pt=phase_conv)[0]
    return direct_stft, adjoint_stft, pseudoinverse_stft


class PhasecutTracker():
    def __init__(self, x_ref, B, istft):
        self.error = []
        self.iter = []
        self.x_ref = x_ref
        self.B = B
        self.istft = istft

    def update(self, U, i):
        self.iter.append(i)
        x_est = phasecut_signal_reconstruction(U, self.B, self.istft)
        err = compute_error(x_ref=self.x_ref, x_est=x_est)
        self.error.append(err)
