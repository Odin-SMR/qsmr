#!/bin/bash

set -e

if [ $# -eq 0 ]
  then
    today=$(date +%y%m%d)
  else
    today=$1
fi

docker build -t "molflow/u-jobs:qsmr_base_${today}" base/
# docker push -t "molflow/q-jobs:qsmr_base_${today}"
