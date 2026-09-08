FROM ubuntu:24.04

LABEL org.opencontainers.image.title="Janus Gateway" \
      org.opencontainers.image.description="Pinned Janus WebRTC gateway with layered configuration" \
      org.opencontainers.image.source="https://github.com/texttechnologylab/Janus-Gateway" \
      org.opencontainers.image.licenses="GPL-3.0"

# Janus 1.4.2. Change deliberately - see docs/building.md.
ARG JANUS_COMMIT=94408ffccbc1a7c39dac82d55e5dd475c807e770
ARG JANUS_VERSION=1.4.2
ARG LIBSRTP_VERSION=2.2.0
ARG LIBWEBSOCKETS_BRANCH=v4.3-stable

LABEL org.opencontainers.image.version="${JANUS_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential git curl wget ca-certificates pkg-config libtool automake cmake meson ninja-build \
      libmicrohttpd-dev libjansson-dev libssl-dev libsofia-sip-ua-dev libglib2.0-dev \
      libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev libconfig-dev \
      libavutil-dev libavformat-dev libavcodec-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# libnice - ICE. The distro package is too old for Janus 1.4.
RUN git clone https://gitlab.freedesktop.org/libnice/libnice \
    && cd libnice && meson setup --prefix=/usr build && ninja -C build && ninja -C build install

# libwebsockets - the ws transport. Two non-default flags, both working around
# known Janus issues:
#   LWS_MAX_SMP=1            -> meetecho/janus-gateway#732
#   LWS_WITHOUT_EXTENSIONS=0 -> meetecho/janus-gateway#2476
RUN git clone https://libwebsockets.org/repo/libwebsockets \
    && cd libwebsockets && git checkout ${LIBWEBSOCKETS_BRANCH} && mkdir build && cd build \
    && cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
    && make && make install

# usrsctp - WebRTC data channels. Without it the textroom plugin and every other
# data channel silently does nothing while audio and video keep working.
RUN git clone https://github.com/sctplab/usrsctp \
    && cd usrsctp && ./bootstrap \
    && ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 \
    && make && make install

RUN wget -q https://github.com/cisco/libsrtp/archive/v${LIBSRTP_VERSION}.tar.gz \
    && tar xf v${LIBSRTP_VERSION}.tar.gz && rm v${LIBSRTP_VERSION}.tar.gz \
    && cd libsrtp-${LIBSRTP_VERSION} && ./configure --prefix=/usr --enable-openssl \
    && make shared_library && make install

# --enable-post-processing builds janus-pp-rec, which converts recorded .mjr
# files into playable media. Without it recordings need a second toolchain.
RUN git clone https://github.com/meetecho/janus-gateway.git \
    && cd janus-gateway && git checkout ${JANUS_COMMIT} \
    && sh autogen.sh && ./configure --prefix=/opt/janus --enable-post-processing \
    && make && make install && make configs \
    && rm -rf /app

# Stock defaults now live in /opt/janus/etc/janus. Overrides are layered on top
# from this directory at startup.
RUN mkdir -p /etc/janus.d /mnt/recordings

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /opt/janus

# Documentation only: run with network_mode host for ICE. See docs/configuration.md.
EXPOSE 8088 8188

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/opt/janus/bin/janus", "-F", "/opt/janus/etc/janus"]
