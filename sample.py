#!/usr/bin/env python3
__author__ = 'sitin'

import matplotlib.pyplot as plt
import neurod
import neurod.test.fixtures as fixtures
import os

__dir__ = os.path.dirname(os.path.realpath(__file__))

df = neurod.parse(fixtures.path_to_sample_log_file).interpolate(method='slinear')

# Write to CSV file
df.to_csv(__dir__ + '/output/sample.csv')

# Plot data
plt.figure()
df.plot(x='TS')
plt.show()


