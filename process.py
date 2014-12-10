#!/usr/bin/env python3
__author__ = 'sitin'

import matplotlib.pyplot as plt
import neurod
import os

__dir__ = os.path.dirname(os.path.realpath(__file__))
destination_dirs = ['/visualizer/data/']
input_file = __dir__ + '/input/session.json'
att_file = 'attention.csv'

df_all = neurod.parse(input_file).interpolate(method='slinear')
df_att = neurod.parse(input_file, {'EEGATT'})
df_med = neurod.parse(input_file, {'EEGMED'})

# Write to CSV files
for destination_dir in destination_dirs:
    df_att.to_csv(__dir__ + destination_dir + att_file)

# Plot data
df_all.plot(x='TS', title='Attention & Meditation')
df_att.plot(x='TS', title='Attention')
df_med.plot(x='TS', title='Meditation')
plt.show()


