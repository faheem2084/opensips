FROM debian:12-slim

ENV OPENSIPS_VERSION=3.2.9

# Install essential build tools and development libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
        ca-certificates

# Create a symbolic link for Python
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Copy necessary files
COPY ./templates/ /templates

# Download and compile OpenSIPS
WORKDIR /usr/src/
RUN wget --no-check-certificate https://download.opensips.org/opensips-${OPENSIPS_VERSION}.tar.gz && \
    tar -xzvf opensips-${OPENSIPS_VERSION}.tar.gz && \
    cd opensips-${OPENSIPS_VERSION} && cp /templates/Makefile.conf /usr/src/opensips-${OPENSIPS_VERSION}  &&  make all && \
    make install && \
    ln -sf /usr/local/sbin/opensips /usr/sbin/opensips

# Cleanup to reduce Docker image size
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/src/opensips*

COPY ./opensips.sh /opensips.sh
RUN chmod +x /opensips.sh

# Expose ports
EXPOSE 5060/udp 5060/tcp
EXPOSE 8844/tcp

ENTRYPOINT ["/opensips.sh"]
