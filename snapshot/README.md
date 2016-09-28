# Distributed experimental qsmr processing

## Summary

Build a snapshot docker image from the local qsmr code and distribute the
processing of a list of scan ids for a certain freq mode.

Contents of this directory:

* `build_snapshot.sh`: Script that creates a snapshot docker image
  from the local qsmr code.
* `add_jobs.py`: Script that adds processing jobs to the job service.
* `test.conf`: Example config file.

## Configuration

The scripts need some information that is provided with a configuration file.
The file should contain these settings:

    ODIN_API_ROOT=http://example.com/odin_api
    ODIN_SECRET=<secret encryption key>
    JOB_API_ROOT=http://example.com/job_api
    JOB_API_USERNAME=<username>
    JOB_API_PASSWORD=<password>

## Build snapshot image

The snapshot image is based on a docker image that will be fetched from the
molflow docker registry. Login with the credentials that are provided by
molflow:

    docker login https://docker2.molflow.com

The snapshot image will need ~4.6G disk space, make sure that enough space
is available on the partition that this repo is located on.

Build the snapshot image:

    ./build_snapshot.sh projectname /path/to/config

This will take some time. The build consists of these steps (the estimated
durations are from a test build on malachite):

1. Build qsmr matlab binary (~1 minute).
1. Build docker image (~5 minutes the first time, then ~10 seconds). The first
   time the base image and qsmr data must be fetched. The base image contains
   the matlab runtime and arts).
1. Save snapshot image to file (~5 minutes).

The script will create these files in the project directory
`qsmr_snapshot_<projectname>_<yymmdd>`:

* `docker-compose.yml`: Docker config file.
* `docker_image`: The qsmr snapshot image.
* `start_worker.sh`: The startup script.

## Distribute the processing

Copy the files in the project directory to machines with docker and
docker-compose installed.

Run the start script to start a worker on the machine:

    bash start_worker.sh

This will take one or two minutes because it will need to load the docker
image from file.

### Start new project without rebuild

If you want to start workers from an existing snapshot image but with an other
project name you only need to change this line in `docker-compose.yml`:

    - UWORKER_JOB_API_PROJECT=<newprojectname>

## Add processing jobs

The `add_jobs.py` script can add scan ids from a text file to the job service:

    ./add_jobs.py projectname /path/to/config --freq-mode 1 \
        --jobs-file /path/to/scanids.txt

The text file should contain one scan id per row.

Sometimes the job api can timeout, which will break the script.
It will then print this message:

    Exiting, you can try add_jobs.py again with --skip=X

It is then possible to continue from the scan id that failed with:

    ./add_jobs.py projectname /path/to/config --freq-mode 1 \
        --jobs-file /path/to/scanids.txt --skip=X

The jobs can also be added directly by the `build_snapshot.sh` script:

    ./build_snapshot.sh projectname /path/to/config /path/to/scanids.txt freqmode

Example:

    ./build_snapshot.sh mytest /path/to/config /path/to/scanids.txt 1

## Processing status and results

The processing status for your project can be fetched from the job service api:
`http://example.com/job_api/v4/<projectname>`

The level2 data can be fetched from the odin api:
`http://example.com/odin_api/v4/level2/<projectname>/<freqmode>/<scanid>`
