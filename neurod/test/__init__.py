__author__ = 'sitin'

import os
import unittest


def load_tests(loader, tests, pattern='*_test.py'):
    # Set default pattern
    if pattern is None:
        pattern = '*_test.py'
    # Load test from module
    package_tests = loader.discover(start_dir=os.path.dirname(__file__), pattern=pattern)
    tests.addTests(package_tests)
    return tests


def run_test():
    unittest.main(module=__name__)


if __name__ == '__main__':
    run_test()