#!/usr/bin/env python3
__author__ = 'sitin'

import matplotlib.pyplot as plt
import neurod
import os

__dir__ = os.path.dirname(os.path.realpath(__file__))
base_output_path = __dir__ + '/visualizer/data'
input_file = __dir__ + '/input/session.json'
att_file = base_output_path + '/attention.csv'

df_all = neurod.parse(input_file).interpolate(method='slinear')
df_att = neurod.parse(input_file, {'EEGATT'})
df_med = neurod.parse(input_file, {'EEGMED'})

# Write to CSV file
df_att.to_csv(att_file)

# Plot data
df_all.plot(x='TS', title='Attention & Meditation')
df_att.plot(x='TS', title='Attention')
df_med.plot(x='TS', title='Meditation')
plt.show()


