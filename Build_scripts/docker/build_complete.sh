#!/bin/bash

set -e -x

source complete/data/env.sh

push_registry="odinregbackend.molflow.com/devops"
pull_registry="odinregistry.molflow.com/devops"

if [ $# -eq 0 ]
  then
    today=$(date +%y%m%d)
  else
    today=$1
    file="$PWD/complete/Dockerfile"
    printf "FROM ${pull_registry}/qsmr_base:${today}\n\nCOPY data /QsmrData\n" > $file
    cat $file
fi

image_name="qsmr_${INVEMODE}_${FREQMODE}"

echo $image_name

docker build -t "${push_registry}/${image_name}:${today}" complete/
