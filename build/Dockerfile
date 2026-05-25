# syntax=docker/dockerfile:1.6

############################
# Stage 1: builder
############################
FROM debian:13.5-slim AS builder

ENV OPENSIPS_VERSION=3.6.6
ENV DEBIAN_FRONTEND=noninteractive

# Build-only deps (dev headers, compilers, autotools). Not shipped to final image.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        bison \
        flex \
        wget \
        ca-certificates \
        git \
        pkg-config \
        autoconf \
        automake \
        libtool \
        gettext \
        libssl-dev \
        libpq-dev \
        libncurses5-dev \
        libjwt-dev \
        libxml2-dev \
        libmemcached-dev \
        libhiredis-dev \
        libcurl4-openssl-dev \
        librabbitmq-dev \
        librdkafka-dev \
        libpcre2-dev \
        libjson-c-dev \
        libmariadb-dev-compat \
        libmariadb-dev \
        libmaxminddb-dev \
        libmongoc-dev \
        libmicrohttpd-dev \
        libconfuse-dev \
        libev-dev \
        liblua5.3-dev \
        python3-dev \
        uuid-dev && \
    rm -rf /var/lib/apt/lists/*

# Build rtpproxy (only headers + librtpproxy needed by OpenSIPS rtp.io).
WORKDIR /usr/src/
RUN git clone --depth 1 https://github.com/sippy/rtpproxy.git && \
    cd rtpproxy && \
    git submodule update --init --recursive && \
    ./configure --enable-librtpproxy && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

# Build OpenSIPS
COPY ./templates/Makefile.conf /tmp/Makefile.conf
WORKDIR /usr/src/
RUN wget --no-check-certificate https://download.opensips.org/opensips-${OPENSIPS_VERSION}.tar.gz && \
    tar -xzf opensips-${OPENSIPS_VERSION}.tar.gz && \
    rm opensips-${OPENSIPS_VERSION}.tar.gz

RUN cd opensips-${OPENSIPS_VERSION} && \
    cp /tmp/Makefile.conf . && \
    make exclude_modules="cachedb_dynamodb aaa_diameter aaa_radius \
    cachedb_cassandra cachedb_couchbase db_berkeley db_oracle \
    db_perlvdb db_sqlite db_unixodbc event_sqs jabber \
    http2d launch_darkly osp perl proto_ipsec proto_sctp \
    pua_xmpp sngtc snmpstats\
    " include_modules="rtp.io" \
    RTPPROXY_DIR=/usr/src/rtpproxy \
    all install

# Strip binaries and shared modules to shrink the artifacts going into the final image.
RUN find /usr/local/sbin /usr/local/lib64/opensips/modules /usr/local/lib -type f \
        \( -name 'opensips*' -o -name '*.so' -o -name '*.so.*' \) \
        -exec strip --strip-unneeded {} + 2>/dev/null || true


############################
# Stage 2: runtime (slim)
############################
FROM debian:13.5-slim

ENV DEBIAN_FRONTEND=noninteractive

# Runtime shared libs ONLY — no -dev packages, no compilers.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libssl3 \
        libpq5 \
        libncurses6 \
        libjwt2 \
        libxml2 \
        libmemcached11 \
        libhiredis1.1.0 \
        libcurl4 \
        librabbitmq4 \
        librdkafka1 \
        libpcre2-8-0 \
        libjson-c5 \
        libmariadb3 \
        libmaxminddb0 \
        libmongoc-1.0-0 \
        libmicrohttpd12 \
        libconfuse2 \
        libev4 \
        liblua5.3-0 \
        python3 \
        libuuid1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy OpenSIPS binaries, modules, configs and rtpproxy lib from builder.
COPY --from=builder /usr/local/sbin/        /usr/local/sbin/
COPY --from=builder /usr/local/bin/         /usr/local/bin/
COPY --from=builder /usr/local/lib64/       /usr/local/lib64/
COPY --from=builder /usr/local/lib/         /usr/local/lib/
COPY --from=builder /usr/local/etc/         /usr/local/etc/
COPY --from=builder /usr/local/share/opensips/ /usr/local/share/opensips/

RUN ldconfig && ln -sf /usr/local/sbin/opensips /usr/sbin/opensips && \
    ln -sf /usr/bin/python3 /usr/bin/python

COPY ./opensips.sh /opensips.sh
RUN chmod +x /opensips.sh

EXPOSE 5060/udp 5060/tcp
EXPOSE 8844/tcp

ENTRYPOINT ["/opensips.sh"]
