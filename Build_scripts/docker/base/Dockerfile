FROM docker2.molflow.com/devops/arts:10134

COPY qsmr.tar.gz /qsmr/qsmr.tar.gz

RUN set -x && \
    cd /qsmr && \
    tar xf qsmr.tar.gz && \
    rm qsmr.tar.gz

# TODO: This is needed by the matlab runtime, but breaks apt-get and probably other programs.
ENV LD_LIBRARY_PATH /opt/matlab/v90/runtime/glnxa64:/opt/matlab/v90/bin/glnxa64:/opt/matlab/v90/sys/os/glnxa64

ENTRYPOINT ["/qsmr/run_runscript.sh", "/opt/matlab/v90"]
