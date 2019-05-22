#! /bin/bash -eu
#
# Bash script for creating a project and adding jobs to the project
#
usage ()
{
  echo "
  Bash script that uploads a new QSMR processing project
  and possibly also a new qsmr worker image, if not specified.

  Running this scripts requires a filed called odin.cfg in the user home.
  This file should contain the following variables:

       JOB_API_ROOT=http://localhost:8080/rest_api
       JOB_API_USERNAME=admin
       JOB_API_PASSWORD=sqrrl
       ODIN_API_ROOT=http://localhost:5000/rest_api
       ODIN_SECRET=XXXXXXXXXXXXXXXX

  For more info on that run:

  	./microq_admin.sh --help

  Usage:
  ./create_qsmr_project.sh inputfile [OPTION]

  Help options:
  -h, --help             show help options

  Required input:
  inputfile              input file must specify the following:

                           PROJECT_NAME="testproj25" # the actual name of the project in the api
                           ODIN_PROJECT="MESO19VDSsidebandleakagetest1" # a descriptive name
                           FREQMODE="21" # frequency mode
                           INVMODE="meso" [meso or stnd]
                           VDS_OR_ALL="all" [VDS or ALL]
                             VDS means that all scans in verification
                             dataset will be added to project and ALL means all scans
                             (a further selection can be made by the optional start_day and end_day options)
                           QSMR_PATH="/home/bengt/work/qsmr"
                             path to qsmr repo
                             (git clone http://phabricator.molflow.com/diffusion/QQ/qsmr.git)
                           QSMRDATA_PATH="/home/bengt/work/qsmr-data"
                             path to qsmr-data repo
                             (git clone http://phabricator.molflow.com/diffusion/QQD/qsmr-data.git)

  Application options:
  -d, --deadline         deadline of project (used to set priority)
  -s, --start_day        start date (YYYY-MM-DD) of data to be processed
  -e, --end_day          end_date (YYYY-MM-DD) of data to be processed
  -w, --worker_image     path to qsmr worker image (if this option is not set
                         a worker image will be created)
  "
  exit
}


create_qsmr_worker_image()
{
  # function for creating qsmr worker image
  QSMR_PATH=$1
  QSMRDATA_PATH=$2
  FREQMODE=$3
  INVMODE=$4
  YYMMDD=$5
  WORKERIMGTAG=$6
  #copy most recent compiled qsmr package
  #compiled_qsmr_package_url="${JENKINS_ROOT}/job/qsmr_compile_matlab/lastSuccessfulBuild/artifact/Build_scripts/mcr/qsmr.tar.gz"
  compiled_qsmr_package_url="http://odin.rss.chalmers.se/qsmr/qsmr.tar.gz"
  curl -L $compiled_qsmr_package_url -o "${QSMR_PATH}/Build_scripts/docker/base/qsmr.tar.gz"
  #create base image
  cd "${QSMR_PATH}/Build_scripts/docker/"
  ./build_base.sh $YYMMDD
  #copy most recent copiled qsmr-data package
  compiled_qsmr_data_package_url="http://odin.rss.chalmers.se/qsmr/qsmr_precalc.tar.gz"
  curl -L $compiled_qsmr_data_package_url -o "${QSMRDATA_PATH}/Build_scripts/docker/qsmr_precalc.tar.gz"

  #create worker images (also builds qsmr_precalc image)
  cd "${QSMR_PATH}/Build_scripts/"
  ./batch_build_single.sh $QSMR_PATH $QSMRDATA_PATH $INVMODE $FREQMODE $YYMMDD $WORKERIMGTAG
}

if [ "$#" -ge 9 ]
then
  usage
fi

for i in "$@" ; do
    if [[ $i == "-h" ]] ; then
        usage
        break
    fi
    if [[ $i == "--help" ]] ; then
        usage
        break
    fi
done

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

inputfile="$1"
source $inputfile

DEADLINE=" "
START_DAY=" "
END_DAY=" "
WORKER_IMAGE=" "
show_usage=0
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -d|--deadline)
    DEADLINE="--deadline $2"
    shift # past argument
    ;;
    -s|--start_day)
    START_DAY="--start-day $2"
    shift # past argument
    ;;
    -e|--end_day)
    END_DAY="--end-day $2"
    shift # past argument
    ;;
    -w|--worker_image)
    WORKER_IMAGE="$2"
    shift # past argument
    ;;
    *)
          # unknown option
    ;;
esac
shift # past argument or value
done
if [ $show_usage == 1 ]
then
  usage
fi

: "${WORKER_IMAGE:?Need to set WORKER_IMAGE}"
: "${PROJECT_NAME:?Need to set PROJECT_NAME}"
: "${ODIN_PROJECT:?Need to set ODIN_PROJECT}"
: "${FREQMODE:?Need to set FREQMODE}"
: "${INVMODE:?Need to set INVMODE}"
: "${DEADLINE:?Need to set DEADLINE}"
: "${START_DAY:?Need to set START_DAY}"
: "${END_DAY:?Need to set QSMR_PATH}"
: "${VDS_OR_ALL:?Need to set VDS_OR_ALL}"


if [ "$WORKER_IMAGE" == " " ]; then
    echo "Create worker image!"
    : "${QSMR_PATH:?Need to set QSMR_PATH}"
    : "${QSMRDATA_PATH:?Need to set QSMRDATA_PATH}"
    YYMMDD=`date +%y%m%d`
    WORKER_IMAGE_TAG="qsmr_${INVMODE}_${FREQMODE}_${YYMMDD}"
    create_qsmr_worker_image $QSMR_PATH $QSMRDATA_PATH $FREQMODE $INVMODE $YYMMDD $WORKER_IMAGE_TAG
else
    echo "Use image ${WORKER_IMAGE}"
fi

# Add the processing project
cd $DIR
./microq_admin.sh qsmrprojects $PROJECT_NAME $ODIN_PROJECT $DEADLINE $WORKER_IMAGE
exitcode=$?
if [ $exitcode -ne 0 ]
then
    exit $exitcode
fi

# Add jobs to the processing project
cd $DIR
./microq_admin.sh qsmrjobs --freq-mode $FREQMODE $START_DAY $END_DAY --$VDS_OR_ALL $PROJECT_NAME $ODIN_PROJECT
