# Build scripts

This directory contains scripts for compiling the matlab qsmr algorithm
and building docker images that can run the qsmr processing.

## Compile matlab script

Run `compile.sh` on a machine with matlab R2015b. This will produce the
archive `mcr/qsmr.tar.gz`. Put this archive in the docker/base directory.


## Create a processing project
Run `create_qsmr_project.sh --help` 
