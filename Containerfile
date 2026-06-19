FROM debian:12-slim AS build

ARG PJSIP_VERSION=2.17

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    wget \
    pkg-config \
    libssl-dev \
    libopus-dev \
    libspeexdsp-dev \
    libasound2-dev \
    ffmpeg \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

RUN wget https://github.com/pjsip/pjproject/archive/refs/tags/${PJSIP_VERSION}.tar.gz -O pjproject.tar.gz \
 && tar xzf pjproject.tar.gz

WORKDIR /usr/src/pjproject-${PJSIP_VERSION}

RUN ./configure \
      --prefix=/usr/local \
      --enable-shared \
      --with-ssl \
      --with-opus \
      --disable-video \
 && make dep \
 && make -j"$(nproc)" \
 && make install \
 && cp pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /usr/local/bin/pjsua \
 && chmod 0755 /usr/local/bin/pjsua


FROM debian:12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    libopus0 \
    libspeexdsp1 \
    libasound2 \
    ffmpeg \
    netcat-openbsd \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local /usr/local

RUN ldconfig

ENTRYPOINT ["/usr/local/bin/pjsua"]
