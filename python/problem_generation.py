# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Marina Kreme
"""
import numpy as np
from scipy.signal import chirp
import matplotlib.pyplot as plt
from scipy.ndimage.morphology import grey_dilation


def generate_random_missing_phases(X, missing_ratio, width=1):
    """

    Parameters
    ----------
    X : nd-array, complex
        Array to be masked
    missing_ratio : float
        Ratio of missing phases, in [0, 1]
    width : int
        width of the holes

    Returns
    -------
    B : nd-array
        Modified array, with same shape as X, with B[M]=X[M] unchanged and
        B[~M] = abs(X[~M])
    M : nd-array, bool
        Mask, as an array with same shape as X, with False values for masked
        phases and True values for unchanged coefficients
    """
    nb_miss = int(np.round(missing_ratio * X.size))

    M0 = np.zeros(X.shape)
    ind_miss = np.random.permutation(M0.size)[:nb_miss]
    M0.flat[ind_miss] = np.arange(nb_miss)+nb_miss
    for i in range((width - 1) // 2):
        M0 = grey_dilation(M0, footprint=[[0, 1, 0], [1, 1, 1], [0, 1, 0]])
    ind_sort = np.argsort(M0.flat)
    M0.flat[ind_sort[:-nb_miss]] = 0

    M = np.ones(X.shape, dtype=bool)
    M[np.nonzero(M0)] = False

    B = X.copy()
    B[~M] = np.abs(B[~M])

    return B, M


def generate_chirp_dirac_noise(sig_len, fs, flim1, flim2, snr):
    """

    Parameters
    ----------
    sig_len : int
        signal length, in samples
    fs : float
        sampling frequency in Hz
    flim1 : array-like
        chirp 1's initial and final frequency (vector with length 2)
    flim2 : array-like
        chirp 2's initial and final frequency (vector with length 2)
    snr : float
        signal to noise ratio

    Returns
    -------
    nd-array
        generated signal
    """
    t = np.arange(sig_len) / fs
    t1 = (sig_len - 1) / fs

    # Build components
    x_chirp = chirp(t, flim1[0], t1, flim1[1]) \
              + chirp(t, flim2[0], t1, flim2[1])
    x_chirp = x_chirp / np.amax(np.abs(x_chirp))

    x_dirac = np.zeros(sig_len)
    x_dirac[sig_len // 2] = 1

    x_noise = np.random.randn(sig_len)

    x = x_chirp + x_dirac

    # Adjust noise level
    x_noise *= 10**(-snr / 20) * np.linalg.norm(x) / np.linalg.norm(x_noise)

    # Add noise
    x += x_noise

    # normalize final signal
    x = x / np.amax(np.abs(x))

    return x


if __name__ == '__main__':
    from scipy.ndimage.morphology import grey_dilation
    m_shape = 100, 110
    n_miss = np.prod(m_shape) // 10
    M = np.zeros(m_shape)
    ind_miss = np.random.permutation(M.size)[:n_miss]
    M.flat[ind_miss] = np.arange(n_miss)+n_miss

    M_dilated = grey_dilation(M, footprint=[[0, 1, 0], [1, 1, 1], [0, 1, 0]])
    M_dilated = grey_dilation(M_dilated, footprint=[[0, 1, 0], [1, 1, 1], [0, 1, 0]])
    M_dilated = grey_dilation(M_dilated, footprint=[[0, 1, 0], [1, 1, 1], [0, 1, 0]])
    M_dilated = grey_dilation(M_dilated, footprint=[[0, 1, 0], [1, 1, 1], [0, 1, 0]])
    M_dilated = grey_dilation(M_dilated, footprint=[[0, 1, 0], [1, 1, 1], [0, 1, 0]])
    M_dilated = grey_dilation(M_dilated, footprint=[[0, 1, 0], [1, 1, 1], [0, 1, 0]])

    ind_sort = np.argsort(M_dilated.flat)
    M_filtered = M_dilated.copy()
    M_filtered.flat[ind_sort[:-n_miss]] = 0

    plt.figure()
    plt.subplot(221)
    plt.imshow(M)
    plt.title('{:.0%} missing'.format(np.count_nonzero(M) / M.size))
    plt.subplot(222)
    plt.imshow(M_dilated)
    plt.title('Dilation: {:.0%} missing'
              .format(np.count_nonzero(M_dilated) / M_dilated.size))
    plt.subplot(224)
    plt.imshow(M_filtered)
    plt.title('Dilation+filtering: {:.0%} missing'
              .format(np.count_nonzero(M_filtered) / M_filtered.size))
    plt.show()

    # from ltfatpy import sgram
    # fs = 500
    # sig_len = 128
    #
    # win_len = 16
    # hop = win_len // 2
    # nb_bins = 2 * win_len
    #
    # flim1 = [0, 200]
    # flim2 = [200, 150]
    # snr = 10
    # x = generate_chirp_dirac_noise(sig_len, fs, flim1, flim2, snr)
    #
    # win_len = 16
    # hop = 1
    # nb_bins = sig_len
    # plt.figure()
    # sgram(x, fs=fs, wlen=win_len)
    # plt.title('generate_chirp_dirac_noise')
    # plt.savefig('generate_chirp_dirac_noise.png')
    # plt.show()
    #
