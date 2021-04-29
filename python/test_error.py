import unittest
import numpy as np
import numpy.testing as npt

from exp_phasecut_results import compute_error


class TestError(unittest.TestCase):
    def test_error(self):
        nb_tests = 5
        for i_test in range(nb_tests):
            x_shape = 11, 12
            theta_ref = np.random.rand() * 2 * np.pi
            x_ref = np.random.randn(*x_shape) + 1j * np.random.randn(*x_shape)
            x_est = x_ref * np.exp(1j * theta_ref)
            err = compute_error(x_ref=x_ref, x_est=x_est)
            self.assertAlmostEqual(err,
                                   20*np.log10(np.finfo(x_ref.dtype).eps),
                                   delta=20)


if __name__ == '__main__':
    unittest.main()
