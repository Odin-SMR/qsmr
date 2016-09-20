from docker2.molflow.com/devops/arts:9979

# Fetch Qsmr data
run set -x && \
    apt-get update -qq && \
    apt-get upgrade -qq && \
	apt-get install -y -qq \
        wget \
        unzip \
        --no-install-recommends && \
    cd / && \
    wget --no-verbose --user=odin --password=hugin http://fukushima.molflow.com/QsmrData.zip && \
    unzip -q QsmrData.zip && \
    rm QsmrData.zip && \
    apt-get remove -q -y wget unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Fetch artifacts built by qsmr/build.sh

copy qsmr.tar.gz /qsmr/qsmr.tar.gz
copy qsmr_data.tar.gz /qsmr/qsmr_data.tar.gz

run set -x && \
    cd /qsmr && \
    tar xf qsmr.tar.gz && \
    rm qsmr.tar.gz && \
    tar xf qsmr_data.tar.gz && \
    rm qsmr_data.tar.gz

# TODO: This is needed by the matlab runtime, but breaks apt-get and probably other programs.
ENV LD_LIBRARY_PATH /opt/matlab/v90/runtime/glnxa64:/opt/matlab/v90/bin/glnxa64:/opt/matlab/v90/sys/os/glnxa64

ENV UWORKER_JOB_CMD "/qsmr/run_runscript.sh /opt/matlab/v90"
ENV UWORKER_JOB_TYPE qsmr
