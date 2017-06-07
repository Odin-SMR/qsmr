#! /bin/bash -eu
# Batch build and push new images for all frequency and inversion modes.
# Assumes that a base image has been built and that QSMR/docker/Dockerfile
# has been updated to use it, see:
#   https://phabricator.molflow.com/w/odin-redo-processing/
#   https://phabricator.molflow.com/diffusion/QQ/browse/master/Build_scripts/
# and
#   https://phabricator.molflow.com/diffusion/QQD/browse/master/Build_scripts/
# for details!


# To run, paths to the QSMR and QSMRDATA repositories are needed, e.g.:
#   QSMR_PATH="/home/skymandr/Documents/Work/odin/qsmr"
#   QSMRDATA_PATH="/home/skymandr/Documents/Work/odin/qsmr-data"
# This is checked below:

: "${QSMR_PATH:?Need to set QSMR_PATH}"
: "${QSMRDATA_PATH:?Need to set QSMRDATA_PATH}"


# Build the QSMR-data image:
YYMMDD=`date +%y%m%d`
PRECALC_IMAGE="docker2.molflow.com/devops/qsmr_precalc:"$YYMMDD
PRECALC="docker run --name qsmr_precalc "$PRECALC_IMAGE" /artifact"
# Clean up precalc build:
docker rmi -f $PRECALC_IMAGE || true
# Build:
cd $QSMRDATA_PATH"/Build_scripts"
./build.sh


# Build the worker images:
declare -a FREQMODES=(1 2 8 13 14 17 19 21)
declare -a INVMODES=("stnd" "meso")

for fmode in "${FREQMODES[@]}"
do
    for imode in "${INVMODES[@]}"
    do
        echo "Building image for "$imode" "$fmode
        # Clean up build:
        rm -r $QSMR_PATH"/Build_scripts/docker/complete/data/*" || echo "Data directory already clean"
        docker rm qsmr_precalc -f || true

        # Run precalculation for settings:
        $PRECALC $imode $fmode || continue

        # Copy results to build environment:
        docker cp qsmr_precalc:/artifact/. $QSMR_PATH"/Build_scripts/docker/complete/data/"

        # Build QSMR image for worker:
        cd $QSMR_PATH"/Build_scripts/docker"
        ./build_complete.sh

        # Push to repository:
        docker push "docker2.molflow.com/devops/qsmr_"$imode"_"$fmode":"$YYMMDD
    done
done
