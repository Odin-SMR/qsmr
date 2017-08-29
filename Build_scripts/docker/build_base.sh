#!/bin/bash

set -e

if [ $# -eq 0 ]
  then
    today=$(date +%y%m%d)
  else
    today=$1
fi

docker build -t "odinregistry.molflow.com/devops/qsmr_base:${today}" base/
#docker push "docker2.molflow.com/devops/qsmr_base:${today}"
