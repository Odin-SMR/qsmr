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
    echo "./qsmr_snapshot_${project_name}_$(today)"
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
    local qsmr_data_path=$2
    rm -rf docker/QsmrData
    mkdir -p docker/QsmrData
    cp -r $qsmr_data_path/* docker/QsmrData/
    docker build -t "$(image_name $project_name)" docker/
    echo "Saving image to file"
    docker save -o "$(snapshot_dir $project_name)/docker_image_$project_name" \
           $(image_name $project_name)
    remove_image $project_name
}

generate_docker_compose() {
    local project_name=$1
    local uservice_url=$2
    local uservice_username=$3
    local uservice_password=$4
    local qsmr_config=$5
    local qsmr_invemode=$6
    
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
    - QSMR_CONFIG=$qsmr_config
    - QSMR_INVEMODE=$qsmr_invemode
EOF
}

generate_start_script() {
    local project_name=$1
    local file_name
    file_name=$(snapshot_dir $project_name)/start_worker.sh
    cat >"$file_name" <<EOF
echo "Loading image from file"
docker load -i docker_image_$project_name

export COMPOSE_PROJECT_NAME=$project_name
export HOST_NAME=\$(hostname)

docker-compose up -d
EOF
    chmod +x "$file_name"
}

main() {
    local project_config=$1
    local api_config=$2
    local jobs_file=$3
    local freq_mode=$4

    source $project_config
    local project_name=$PROJECT_NAME
    local qsmr_config=$QSMR_CONFIG
    local qsmr_invemode=$QSMR_INVEMODE
    local qsmr_data_path=$QSMR_DATA_PATH

    # Verify project name and config
    ./add_jobs.py $project_name $api_config

    source $api_config
    local uservice_username=$JOB_API_USERNAME
    local uservice_password=$JOB_API_PASSWORD
    local uservice_url=$JOB_API_ROOT
    local odin_api_url=$ODIN_API_ROOT

    mkdir -p $(snapshot_dir $project_name)

    build_qsmr_snapshot
    build_docker_image $project_name $qsmr_data_path
    generate_docker_compose $project_name $uservice_url $uservice_username \
                            $uservice_password $qsmr_config $qsmr_invemode
    generate_start_script $project_name

    echo ""
    echo ""
    echo "========= Snapshot built ========="
    echo "Copy the files in $(snapshot_dir $project_name) to a machine that"
    echo "has docker and docker-compose installed."
    echo ""
    echo "Start the worker with:"
    echo ">>> bash start_worker.sh"
    echo ""
    echo "The status of the project can be seen here:"
    echo "${uservice_url}/v4/${project_name}"
    echo ""
    echo "The level2 data can be accessed here:"
    echo "${odin_api_url}/v4/level2/$project_name/<freqmode>/<scanid>"

    if [[ -n $jobs_file ]]; then
        echo ""
        echo "Adding jobs from $jobs_file"
        ./add_jobs.py $project_name $api_config --freq-mode $freq_mode \
                      --jobs-file $jobs_file
    fi
}

main "$@"
