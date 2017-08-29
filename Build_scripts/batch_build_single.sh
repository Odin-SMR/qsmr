#! /bin/bash -eu
# Batch build and push new image for a given frequency and inversion modes.
# This script is supposed to be called by create_qsmr_worker_image.sh


# To run, paths to the QSMR and QSMRDATA repositories are needed, e.g.:
QSMR_PATH=$1
QSMRDATA_PATH=$2
imode=$3
fmode=$4
YYMMDD=$5
# This is checked below:

: "${QSMR_PATH:?Need to set QSMR_PATH}"
: "${QSMRDATA_PATH:?Need to set QSMRDATA_PATH}"
: "${imode:?Need to set imode}"
: "${fmode:?Need to set fmode}"
: "${YYMMDD:?Need to set YYMMDD}"

# Build the QSMR-data image:
YYMMDD=`date +%y%m%d`
PRECALC_IMAGE="odinregistry.molflow.com/devops/qsmr_precalc:"$YYMMDD
PRECALC="docker run --name qsmr_precalc "$PRECALC_IMAGE" /artifact"
# Clean up precalc build:
docker rmi -f $PRECALC_IMAGE || echo "precalc image clean"
# Build:
cd $QSMRDATA_PATH"/Build_scripts"
./build.sh $YYMMDD

# Build the worker image:
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
./build_complete.sh $YYMMDD

# Push to repository:
docker push "odinregistry.molflow.com/devops/qsmr_"$imode"_"$fmode":"$YYMMDD
echo "succesfully built and pushed image odinregistry.molflow.com/devops/qsmr_${imode}_${fmode}:${YYMMDD}"
