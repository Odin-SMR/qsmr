#!/bin/bash
#
# Launches the "offical" matlab installation.
#
scrip_dir=$(basename $(dirname $(realpath $0)))
full_path_dir=$(dirname $(realpath $0))

docker run \
    --tty=true \
    --interactive=true \
    --link=${scrip_dir}_webapi_1:webapi \
    --env=DISPLAY=${DISPLAY} \
    --volume=${full_path_dir}:/src \
    --volume=/tmp/.X11-unix/:/tmp/.X11-unix \
    docker.molflow.com/odin_redo/odin_matlab:latest 
