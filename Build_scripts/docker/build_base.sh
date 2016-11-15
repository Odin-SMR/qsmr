#!/bin/bash

set -e

today=$(date +%y%m%d)

docker build -t "docker2.molflow.com/devops/qsmr_base:${today}" base/
#docker push "docker2.molflow.com/devops/qsmr_base:${today}"
