# Build scripts

This directory contains scripts for compiling the matlab qsmr algorithm
and building docker images that can run the qsmr processing.

## Compile matlab script

Run `compile.sh` on a machine with matlab R2015b. This will produce the
archive `mcr/qsmr.tar.gz`. Put this archive in the docker/base directory.

## Build base qsmr docker image

Run `docker/build_base.sh` on a machine with docker. Note that the
`qsmr.tar.gz` archive must have been copied to the docker/base directory first.

This will produce the docker image:

    docker2.molflow.com/devops/qsmr_base:<yymmdd>

## Build final qsmr processing image

Copy the data produced by the precalc image (see README in Build_scripts in
the qsmr-data repo) to docker/complete/data/.

Run `docker/build_complete.sh`. This will produce the docker image:

    docker2.molflow.com/devops/qsmr_<invemode>_<freqmode>:<yymmdd>
