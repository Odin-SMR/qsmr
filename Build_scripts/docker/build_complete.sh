#!/bin/bash

set -e

source complete/data/env.sh

if [ $# -eq 0 ]
  then
    today=$(date +%y%m%d)
  else
    today=$1
    file="$PWD/complete/Dockerfile"
    printf "FROM odinregistry.molflow.com/devops/qsmr_base:${today}\n\nCOPY data /QsmrData\n" > $file
    cat $file
fi

image_name="qsmr_${INVEMODE}_${FREQMODE}"

echo $image_name

docker build -t "odinregistry.molflow.com/devops/${image_name}:${today}" complete/
#docker push "odinregistry.molflow.com/devops/${image_name}:${today}"
