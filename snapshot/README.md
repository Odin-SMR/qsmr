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

The scripts need some information that is provided with two configuration
files, one with paths and credentials to the api:s and one with project
configuration.

The api config file should contain these settings:

    ODIN_API_ROOT=http://example.com/odin_api
    ODIN_SECRET=<secret encryption key>
    JOB_API_ROOT=http://example.com/job_api
    JOB_API_USERNAME=<username>
    JOB_API_PASSWORD=<password>

The project config file should contain these settings:

    PROJECT_NAME=<projectname> # Must only contain alphanumerical characters
    QSMR_CONFIG=<default:q_std>
    QSMR_INVEMODE=<default:stnd>
    QSMR_DATA_PATH=/path/to/QsmrData

## Build snapshot image

The snapshot image is based on a docker image that will be fetched from the
molflow docker registry. Login with the credentials that are provided by
molflow:

    docker login https://docker2.molflow.com

The snapshot image will need ~4.6G disk space, make sure that enough space
is available on the partition that this repo is located on.

Build the snapshot image:

    ./build_snapshot.sh /path/to/project.config /path/to/api.config

This will take some time. The build consists of these steps (the estimated
durations are from a test build on malachite):

1. Build qsmr matlab binary (~1 minute).
1. Copy qsmr data to the docker directory.
1. Build docker image (~5 minutes the first time, then ~10 seconds. The first
   time the base image must be fetched. It contains the matlab runtime and
   arts).
1. Save snapshot image to file (~5 minutes).

The script will create these files in the project directory
`qsmr_snapshot_<projectname>_<yymmdd>`:

* `docker-compose.yml`: Docker config file.
* `docker_image_<projectname>`: The qsmr snapshot image.
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
project name and settings you only need to change these lines in
`docker-compose.yml`:

    - UWORKER_JOB_API_PROJECT=<newprojectname>
    - QSMR_CONFIG=<new_q_config>
    - QSMR_INVEMODE=<new_invemode>

The qsmr data will be the same though.

## Add processing jobs

The `add_jobs.py` script can add scan ids from a text file to the job service:

    ./add_jobs.py projectname /path/to/api.config --freq-mode 1 \
        --jobs-file /path/to/scanids.txt

The text file should contain one scan id per row.

Sometimes the job api can timeout, which will break the script.
It will then print this message:

    Exiting, you can try add_jobs.py again with --skip=X

It is then possible to continue from the scan id that failed with:

    ./add_jobs.py projectname /path/to/api.config --freq-mode 1 \
        --jobs-file /path/to/scanids.txt --skip=X

The jobs can also be added directly by the `build_snapshot.sh` script:

    ./build_snapshot.sh /path/to/project.config /path/to/api.config \
        /path/to/scanids.txt freqmode

Example:

    ./build_snapshot.sh /path/to/project.config /path/to/api.config \
        /path/to/scanids.txt 1

## Processing status and results

The processing status for your project can be fetched from the job service api:
`http://example.com/rest_api/v4/<projectname>`

The level2 data can be fetched from the odin api:
`http://example.com/rest_api/v4/level2/<projectname>/<freqmode>/<scanid>`
