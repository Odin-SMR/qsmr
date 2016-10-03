from docker2.molflow.com/devops/arts:9979

# Copy Qsmr data
copy QsmrData /QsmrData/

# Copy artifacts built by qsmr/build.sh

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
