FROM debian:bullseye-slim

ENV OPENSIPS_VERSION=3.2.9

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        bison \
        flex \
        libssl-dev \
        libpq-dev \
        libncurses5-dev \
        libjwt-dev \
        libxml2-dev \
        libmemcached-dev \
        libhiredis-dev \
        libcurl4-openssl-dev \
        libpq-dev \
        librabbitmq-dev \
        librdkafka-dev \
        libpcre3-dev \
        libjson-c-dev \
        libmariadb-dev-compat \
        libmariadb-dev \
        libmaxminddb-dev \
        net-tools \
        sngrep \
        telnet \
        wget \
        libmongoc-dev \
        libmicrohttpd-dev \
        curl \
        vim \
        gettext \
        ca-certificates && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    wget --no-check-certificate https://download.opensips.org/opensips-${OPENSIPS_VERSION}.tar.gz && \
    tar -xzvf opensips-${OPENSIPS_VERSION}.tar.gz && \
    cd opensips-${OPENSIPS_VERSION} && \
    make all include_modules="db_mysql db_postgres proto_tls proto_wss tls_mgm cachedb_mongodb cachedb_redis httpd json xcap presence presence_xml dialplan" \
    prefix="/usr/local/" && \
    make install && \
    ln -sf /usr/local/sbin/opensips /usr/sbin/opensips && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/src/opensips*

COPY ./templates/ /templates
COPY ./opensips.sh /opensips.sh
RUN chmod +x /opensips.sh

EXPOSE 5060/udp 5060/tcp 8844/tcp

ENTRYPOINT ["/opensips.sh"]
