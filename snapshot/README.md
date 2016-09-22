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

    $ docker login https://docker2.molflow.com

Build the snapshot image:

    $ ./build_snapshot.sh projectname /path/to/config

This will take some time because it will save the docker image to a file.
The first time it will also need to fetch the base docker image from the
molflow registry.

The script will create these files in the project directory
`qsmr_snapshot_<projectname>_<yymmdd>`:

* `docker-compose.yml`: Docker config file.
* `docker_image`: The qsmr snapshot image.
* `start_worker.sh`: The startup script.

## Distribute the processing

Copy the files in the project directory to machines with docker and
docker-compose installed.

Run the start script to start a worker on the machine:

    $ bash start_worker.sh

This will take some time because it will need to load the docker image from
file.

## Add processing jobs

The `add_jobs.py` script can add scan ids from a text file to the job service:

    $ ./add_jobs.py projectname /path/to/config --freq-mode 1 \
                    --jobs-file /path/to/scanids.txt

Sometimes the job api can timeout, which will break the script.
It will then print this message:

    Exiting, you can try add_jobs.py again with --skip=X

It is then possible to continue from the scan id that failed with:

    $ ./add_jobs.py projectname /path/to/config --freq-mode 1 \
                    --jobs-file /path/to/scanids.txt --skip=X

The jobs can also be added directly by the `build_snapshot.sh` script:

    $ ./build_snapshot.sh projectname /path/to/config /path/to/scanids.txt freqmode

## Processing status and results

The processing status for your project can be fetched from the job service api:
http://example.com/job_api/v4/<projectname>

The level2 data can be fetched from the odin api:
http://example.com/odin_api/v4/level2/<projectname>/<freqmode>/<scanid>
