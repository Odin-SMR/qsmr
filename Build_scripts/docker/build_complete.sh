#!/bin/bash

set -e -x

source complete/data/env.sh

registry="molflow/u-jobs"

if [ $# -eq 0 ]
  then
    today=$(date +%y%m%d)
    IMG_TAG="qsmr_${INVEMODE}_${FREQMODE}"
  else
    today=$1
    IMG_TAG=$2
    file="$PWD/complete/Dockerfile"
    printf "FROM ${registry}:qsmr_base_${today}\n\nCOPY data /QsmrData\n" > $file
    cat $file
fi


echo $image_name

docker build -t "${registry}:${IMG_TAG}" complete/
