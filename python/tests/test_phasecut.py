import unittest

from numpy.random import randn
from numpy import vdot
import numpy.testing as npt

from algorithms import get_stft_operators


class TestStftOperators(unittest.TestCase):
    def setUp(self):
        self.win_type = 'hann'
        self.win_len = 16
        self.hop = 8
        self.nb_bins = 32
        self.sig_len = 128
        self.phase_conv = 'freqinv'
        self.stft, self.adjoint, self.pinv = get_stft_operators(
            win_type=self.win_type, win_len=self.win_len, hop=self.hop,
            nb_bins=self.nb_bins, sig_len=self.sig_len,
            phase_conv=self.phase_conv)

    @property
    def nb_frames(self):
        return self.sig_len // self.hop

    def test_adjoint(self):
        nb_tests = 50
        for i_test in range(nb_tests):
            x = randn(self.sig_len) + 1j * randn(self.sig_len)
            y = randn(self.nb_bins, self.nb_frames) \
                + 1j * randn(self.nb_bins, self.nb_frames)
            x_adjy = vdot(x, self.adjoint(y))
            dirx_y = vdot(self.stft(x), y)
            npt.assert_almost_equal(x_adjy, dirx_y)

    def test_pinv(self):
        nb_tests = 50
        for i_test in range(nb_tests):
            # self.stft(self.pinv(self.stft(.))) = self.stft(.)
            x = randn(self.sig_len) + 1j * randn(self.sig_len)
            y1 = self.stft(x)
            y2 = self.stft(self.pinv(y1))
            npt.assert_array_almost_equal(y1, y2)

            # self.pinv(self.stft(self.pinv(.))) = self.pinv(.)
            y = randn(self.nb_bins, self.nb_frames) \
                + 1j * randn(self.nb_bins, self.nb_frames)
            x1 = self.pinv(y)
            x2 = self.pinv(self.stft(x1))
            npt.assert_array_almost_equal(x1, x2)

            # self.pinv(self.stft(.)) self-adjoint
            x1 = randn(self.sig_len) + 1j * randn(self.sig_len)
            x2 = randn(self.sig_len) + 1j * randn(self.sig_len)
            p1 = vdot(x1, self.pinv(self.stft(x2)))
            p2 = vdot(self.pinv(self.stft(x1)), x2)
            npt.assert_almost_equal(p1, p2)

            # self.stft(self.pinv(.)) self-adjoint
            y1 = randn(self.nb_bins, self.nb_frames) \
                + 1j * randn(self.nb_bins, self.nb_frames)
            y2 = randn(self.nb_bins, self.nb_frames) \
                + 1j * randn(self.nb_bins, self.nb_frames)
            p1 = vdot(y1, self.stft(self.pinv(y2)))
            p2 = vdot(self.stft(self.pinv(y1)), y2)
            npt.assert_almost_equal(p1, p2)


if __name__ == '__main__':
    unittest.main()
