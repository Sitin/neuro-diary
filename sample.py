#!/usr/bin/env python3
__author__ = 'sitin'

import matplotlib.pyplot as plt
import neurod
import neurod.test.fixtures as fixtures
import os

__dir__ = os.path.dirname(os.path.realpath(__file__))

df_all = neurod.parse(fixtures.path_to_sample_log_file).interpolate(method='slinear')
df_att = neurod.parse(fixtures.path_to_sample_log_file, {'EEGATT'})
df_med = neurod.parse(fixtures.path_to_sample_log_file, {'EEGMED'})

# Write to CSV file
df_all.to_csv(__dir__ + '/output/sample.csv')

# Plot data
df_all.plot(x='TS', title='Attention & Meditation')
df_att.plot(x='TS', title='Attention')
df_med.plot(x='TS', title='Meditation')
plt.show()


