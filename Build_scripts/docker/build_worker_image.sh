#!/bin/bash

create_docker_file()
{
  # function for creating multistage docker file
  INVEMODE=$1
  FREQMODE=$2

  file="$PWD/Dockerfile"
  cat <<EOF > ${file}
FROM odinsmr/arts:10134 AS builder
COPY data /QsmrData
# TODO: Fetch from binary repo service?
COPY qsmr_precalc.tar.gz /qsmr_precalc/qsmr_precalc.tar.gz
RUN set -x && \
cd /qsmr_precalc && \
    tar xf qsmr_precalc.tar.gz && \
    rm qsmr_precalc.tar.gz
# TODO: This is needed by the matlab runtime, but breaks apt-get and probably other programs.
ENV LD_LIBRARY_PATH /opt/matlab/v90/runtime/glnxa64:/opt/matlab/v90/bin/glnxa64:/opt/matlab/v90/sys/os/glnxa64
COPY build_data_artifact.sh /build_data_artifact.sh
RUN chmod u+x /build_data_artifact.sh
RUN /build_data_artifact.sh /QsmrData ${INVEMODE} ${FREQMODE}
RUN rm -r /QsmrData/DataInput

FROM odinsmr/arts:10134
COPY qsmr.tar.gz /qsmr/qsmr.tar.gz
RUN set -x && \
    cd /qsmr && \
    tar xf qsmr.tar.gz && \
    rm qsmr.tar.gz

COPY --from=builder /QsmrData /QsmrData
ENV LD_LIBRARY_PATH /opt/matlab/v90/runtime/glnxa64:/opt/matlab/v90/bin/glnxa64:/opt/matlab/v90/sys/os/glnxa64
ENTRYPOINT ["/qsmr/run_runscript.sh", "/opt/matlab/v90"]
EOF
}

INVEMODE=$1
FREQMODE=$2
IMG_TAG=$3

create_docker_file $INVEMODE $FREQMODE

registry="odinsmr/u-jobs"
worker_image="${registry}:${IMG_TAG}"

docker build --no-cache -t $worker_image .

# Push to repository:
docker push $worker_image
echo "succesfully built and pushed image ${worker_image}"

