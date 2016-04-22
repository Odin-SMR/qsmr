from docker2.molflow.com/odin_redo/odin_matlab:2015b
run set -x && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        libblas3gf \
        liblapack3 \
        libblas-dev \
        liblapack-dev \
        libatlas3gf-base \
        libatlas-dev \
        zlib1g \
        zlib1g-dev \
        subversion \
        --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    svn export \
        --non-interactive \
        --trust-server-cert \
        -q -r9798 \
        https://arts.mi.uni-hamburg.de/svn/rt/arts/trunk/ arts 
run cd arts/build && \
    cmake .. && \
    make arts && \
    make install && \
    cd ../.. && \
    rm -rf arts && \
    apt-get purge -y --auto-remove \
        build-essential \
        cmake \
        libblas-dev \
        liblapack-dev \
        libatlas-dev \
        zlib1g-dev \
        subversion
