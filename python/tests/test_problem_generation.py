# -*- coding: utf-8 -*-
"""

.. moduleauthor:: Valentin Emiya
"""

import unittest

import numpy as np
from numpy.random import randn
from numpy import vdot
import numpy.testing as npt

from problem_generation import generate_random_missing_phases


class TestGenerateRandomMissPhases(unittest.TestCase):
    def setUp(self):
        x_shape = 13, 29
        X = np.random.randn(*x_shape) + 1j * np.random.randn(*x_shape)
        # Test array in C and Fortran ordering conventions
        self.Xs = [np.asfortranarray(X), np.ascontiguousarray(X)]
        self.widths = [1, 2, 3, 5, 7]

    def test_input_not_changed(self):
        """ Test if function does not modify its input data array"""
        for X in self.Xs:
            for width in self.widths:
                Xcopy = X.copy()
                generate_random_missing_phases(Xcopy, missing_ratio=0.5,
                                               width=width)
                npt.assert_array_equal(Xcopy, X)

    def test_ratio(self):
        """ Check number of values in mask """
        for X in self.Xs:
            for ratio in np.arange(0, 1, 0.1):
                for width in self.widths:
                    B, M = generate_random_missing_phases(X,
                                                          missing_ratio=ratio,
                                                          width=width)
                    self.assertAlmostEqual(
                        np.count_nonzero(~M), ratio*X.size, delta=1)

    def test_values(self):
        """ Check changed and unchanged values in data array """
        for X in self.Xs:
            for ratio in np.arange(0, 1, 0.1):
                for width in self.widths:
                    B, M = generate_random_missing_phases(X,
                                                          missing_ratio=ratio,
                                                          width=width)
                    npt.assert_array_almost_equal(B[M], X[M])
                    npt.assert_array_almost_equal(B[~M], np.abs(X[~M]))


if __name__ == '__main__':
    unittest.main()
