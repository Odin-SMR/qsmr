#!/bin/bash

set -e

build_qsmr_snapshot() {
    (cd .. && ./build.sh)
    cp ../*.tar.gz docker/
}

today() {
    date +%y%m%d
}

image_name() {
    local project_name=$1
    echo "qsmr_snapshot_${project_name}:$(today)"
}

snapshot_dir() {
    local project_name=$1
    echo "qsmr_snapshot_${project_name}_$(today)"
}

get_image_id() {
    local image_name=$1
    docker images -q $image_name
}

remove_image() {
    local project_name=$1
    local image_id
    image_id=$(get_image_id $(image_name $project_name))
    if [[ -n $image_id ]]; then
        docker rmi $image_id
    fi
}

build_docker_image() {
    local project_name=$1
    docker build -t "$(image_name $project_name)" docker/
    docker save -o "$(snapshot_dir $project_name)/docker_image" \
           $(image_name $project_name)
    remove_image $project_name
}

generate_docker_compose() {
    local project_name=$1
    local uservice_url=$2
    local uservice_username=$3
    local uservice_password=$4
    
    cat >"$(snapshot_dir $project_name)/docker-compose.yml" <<EOF
uworker:
  image: $(image_name $project_name)
  environment:
    - UWORKER_HOSTNAME=\$HOST_NAME
    - UWORKER_CONTAINER_NAME=uworker_1
    - UWORKER_JOB_API_ROOT=$uservice_url
    - UWORKER_JOB_API_PROJECT=$project_name
    - UWORKER_JOB_API_USERNAME=$uservice_username
    - UWORKER_JOB_API_PASSWORD=$uservice_password
    - UWORKER_EXTERNAL_API_USERNAME=notused
    - UWORKER_EXTERNAL_API_PASSWORD=notused
EOF
}

generate_start_script() {
    local project_name=$1
    local file_name
    file_name=$(snapshot_dir $project_name)/start_worker.sh
    cat >"$file_name" <<EOF
docker load -i docker_image

export COMPOSE_PROJECT_NAME=$project_name
export HOST_NAME=\$(hostname)

docker-compose up -d
EOF
    chmod +x "$file_name"
}

main() {
    local project_name=$1
    local config_file=$2
    local jobs_file=$3
    local freq_mode=$4

    # Verify project name and config
    ./add_jobs.py $project_name $config_file

    source $config_file
    local uservice_username=$JOB_API_USERNAME
    local uservice_password=$JOB_API_PASSWORD
    local uservice_url=$JOB_API_ROOT
    local odin_api_url=$ODIN_API_ROOT

    mkdir -p $(snapshot_dir $project_name)

    build_qsmr_snapshot
    build_docker_image $project_name
    generate_docker_compose $project_name $uservice_url $uservice_username \
                            $uservice_password 
    generate_start_script $project_name

    echo ""
    echo ""
    echo "========= Snapshot built ========="
    echo "Copy the files in ./$(snapshot_dir $project_name) to a machine that"
    echo "has docker and docker-compose installed."
    echo ""
    echo "Start the worker with:"
    echo ">>> bash start_worker.sh"
    echo ""
    echo "The status of the project can be seen here:"
    echo "${uservice_url}/v4/${project_name}"
    echo ""
    # TODO:
    echo "The level2 data can be accessed here:"
    echo "${odin_api_url}/v4/level2/$project_name/<freqmode>/<scanid>"

    if [[ -n $jobs_file ]]; then
        echo ""
        echo "Adding jobs from $jobs_file"
        ./add_jobs.py $project_name $config_file --freq-mode $freq_mode \
                      --jobs-file $jobs_file
    fi
}

main "$@"
