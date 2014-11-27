__author__ = 'sitin'

from NeuroPy import NeuroPy
from time import sleep
import mp3play
import os


__dir__ = os.path.dirname(os.path.realpath(__file__))

devices = {
    'OS X': '/dev/cu.MindWaveMobile-DevA'
}

headset = NeuroPy('/dev/cu.MindWaveMobile-DevA')


def cb(name):
    def a_cb(value):
        print(name, value)
    return a_cb

#call start method
headset.start()

#set call back:
for attr in ('attention', 'delta', 'highAlpha', 'highBeta', 'lowAlpha', 'lowBeta', 'lowGamma', 'meditation', 'midGamma', 'theta'):
    headset.setCallBack(attr, cb(attr))

mp3 = mp3play.load('../6.mp3')
mp3.play()

# while True:
#     sleep(5)
#     print('Instant meditation:', headset.meditation)
#     if headset.meditation > 90:
#         headset.stop()






