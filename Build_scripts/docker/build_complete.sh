#!/bin/bash

set -e

source complete/data/env.sh

today=$(date +%y%m%d)

image_name="qsmr_${INVEMODE}_${FREQMODE}"

echo $image_name

docker build -t "docker2.molflow.com/devops/${image_name}:${today}" complete/
#docker push "docker2.molflow.com/devops/${image_name}:${today}"
