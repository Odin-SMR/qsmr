#!/bin/bash

set -e

# TODO:
# invemode and freqmode as parameters
# create data artifact with precalc docker image
# rm old complete/data and copy artifact files to complete/data
# build

today=$(date +%y%m%d)

docker build -t "docker2.molflow.com/devops/qsmr_stnd_1:${today}" complete/
#docker push "docker2.molflow.com/devops/qsmr_stnd_1:${today}"
