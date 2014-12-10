#!/bin/bash

BASE_DIR="../audioparser/data/movies/"
VIDEO_INPUT="-i ../audioparser/data/sequence/%05d.tif"
VIDEO_CODEC="-vcodec mpeg4 -b:v 16384k -shortest"
AUDIO_INPUT="-i ../audioparser/data/session.wav"
AUDIO_CODEC="-c:a aac -strict experimental -b:a 128k"

rm -rf ${BASE_DIR}
mkdir ${BASE_DIR}

#ffmpeg -r 30 ${VIDEO_INPUT} -vcodec mjpeg -qscale 1 ${BASE_DIR}movie_mjpeg.avi
#ffmpeg -r 30 ${VIDEO_INPUT} -b:v 16384k ${BASE_DIR}movie_mpeg.mpeg
ffmpeg -r 30 ${VIDEO_INPUT} ${AUDIO_INPUT} ${VIDEO_CODEC} ${AUDIO_CODEC} ${BASE_DIR}movie_mpeg4.mp4