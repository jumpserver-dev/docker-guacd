FROM debian:trixie-slim AS builder
WORKDIR /opt
ENV LC_ALL=C.UTF-8

ARG PREFIX_DIR=/opt/guacamole

ARG BUILD_DIR=/tmp/guacamole-server

ARG FREERDP_VERSION=3

ARG WITH_OPENSSL='OpenSSL_1(\_\d+\w*)+'
ARG WITH_FREERDP="${FREERDP_VERSION}(\.\d+)+"
ARG WITH_LIBSSH2='libssh2-\d+(\.\d+)+'
ARG WITH_LIBTELNET='\d+(\.\d+)+'
ARG WITH_LIBVNCCLIENT='LibVNCServer-\d+(\.\d+)+'
ARG WITH_LIBWEBSOCKETS='v\d+(\.\d+)+'

ARG OPENSSL_OPTS=""

ARG FREERDP_OPTS="\
    -DBUILTIN_CHANNELS=OFF \
    -DCHANNEL_URBDRC=OFF \
    -DWITH_ALSA=OFF \
    -DWITH_CAIRO=ON \
    -DWITH_CHANNELS=ON \
    -DWITH_CLIENT=ON \
    -DWITH_CUPS=OFF \
    -DWITH_DIRECTFB=OFF \
    -DWITH_FFMPEG=OFF \
    -DWITH_FUSE=OFF \
    -DWITH_GSM=OFF \
    -DWITH_GSSAPI=OFF \
    -DWITH_IPP=OFF \
    -DWITH_JPEG=ON \
    -DWITH_KRB5=ON \
    -DWITH_LIBSYSTEMD=OFF \
    -DWITH_MANPAGES=OFF \
    -DWITH_OPENH264=OFF \
    -DWITH_OPENSSL=ON \
    -DWITH_OSS=OFF \
    -DWITH_PCSC=OFF \
    -DWITH_PKCS11=OFF \
    -DWITH_PULSE=OFF \
    -DWITH_SERVER=OFF \
    -DWITH_SERVER_INTERFACE=OFF \
    -DWITH_SHADOW_MAC=OFF \
    -DWITH_SHADOW_X11=OFF \
    -DWITH_SWSCALE=OFF \
    -DWITH_WAYLAND=OFF \
    -DWITH_X11=OFF \
    -DWITH_X264=OFF \
    -DWITH_XCURSOR=ON \
    -DWITH_XEXT=ON \
    -DWITH_XI=OFF \
    -DWITH_XINERAMA=OFF \
    -DWITH_XKBFILE=ON \
    -DWITH_XRENDER=OFF \
    -DWITH_XTEST=OFF \
    -DWITH_XV=OFF \
    -DWITH_ZLIB=ON"

ARG GUACAMOLE_SERVER_OPTS="\
    --disable-guaclog"

ARG LIBSSH2_OPTS="\
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_SHARED_LIBS=ON"

ARG LIBTELNET_OPTS="\
    --disable-static \
    --disable-util"

ARG LIBVNCCLIENT_OPTS=""

ARG LIBWEBSOCKETS_OPTS="\
    -DDISABLE_WERROR=ON \
    -DLWS_WITHOUT_SERVER=ON \
    -DLWS_WITHOUT_TESTAPPS=ON \
    -DLWS_WITHOUT_TEST_CLIENT=ON \
    -DLWS_WITHOUT_TEST_PING=ON \
    -DLWS_WITHOUT_TEST_SERVER=ON \
    -DLWS_WITHOUT_TEST_SERVER_EXTPOLL=ON \
    -DLWS_WITH_STATIC=OFF"

ARG BUILD_DEPENDENCIES="          \
        autoconf                  \
        automake                  \
        build-essential           \
        cmake                     \
        gcc                       \
        g++                       \
        libcairo2-dev             \
        libcunit1-dev             \
        libjpeg62-turbo-dev       \
        libjson-c-dev             \
        libkrb5-dev               \
        libsdl2-dev               \
        libsdl2-ttf-dev           \
        libssl-dev                \
        libtool                   \
        libwebkit2gtk-4.1-dev     \
        libwebp-dev               \
        make"

ARG TOOLS="                       \
        ca-certificates           \
        ccache                    \
        curl                      \
        git                       \
        wget"

ARG DEBIAN_FRONTEND=noninteractive

ENV USE_CCACHE=1 \
    PATH=/usr/lib/ccache:${PATH}

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -ex \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && apt-get update \
    && apt-get install -y --no-install-recommends $BUILD_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $TOOLS \
    && apt-get install -y --no-install-recommends gcc-multilib || true \
    && echo "no" | dpkg-reconfigure dash

ARG VERSION=main

RUN set -ex \
    && git clone -b ${VERSION} --depth=1 https://github.com/apache/guacamole-server ${BUILD_DIR} \
    && rm -f ${BUILD_DIR}/src/guacd-docker/bin/build-all.sh \
    && wget -O ${BUILD_DIR}/src/guacd-docker/bin/build-all.sh https://github.com/wojiushixiaobai/guacamole-server/raw/4f2704ce642d3a8a31d0d92878a92e94a92187dc/src/guacd-docker/bin/build-all.sh \
    && wget -O ${BUILD_DIR}/src/guacd-docker/bin/list-dependencies.sh https://github.com/wojiushixiaobai/guacamole-server/raw/601ee1f81945fd5c1be935a200035c09bbaa9123/src/guacd-docker/bin/list-dependencies.sh \
    && sed -i 's@make check && @@g' ${BUILD_DIR}/src/guacd-docker/bin/build-all.sh \
    && chmod 755 ${BUILD_DIR}/src/guacd-docker/bin/*.sh

ENV PATH=/usr/lib/ccache:${PATH}

RUN --mount=type=cache,target=/root/.cache/ccache \
    ${BUILD_DIR}/src/guacd-docker/bin/build-all.sh

ARG FREERDP_LIB_PATH=${PREFIX_DIR}/lib/freerdp${FREERDP_VERSION}

RUN ${BUILD_DIR}/src/guacd-docker/bin/list-dependencies.sh \
        ${PREFIX_DIR}/sbin/guacd               \
        ${PREFIX_DIR}/lib/libguac-client-*.so  \
        ${FREERDP_LIB_PATH}/*guac*.so   \
        > ${PREFIX_DIR}/DEPENDENCIES

FROM debian:trixie-slim

ARG PREFIX_DIR=/opt/guacamole

ENV LANG="en_US.UTF-8"
ENV LD_LIBRARY_PATH=${PREFIX_DIR}/lib
ENV GUACD_LOG_LEVEL=info

ARG RUNTIME_DEPENDENCIES="            \
        ca-certificates               \
        netcat-openbsd"

ARG DEBIAN_FRONTEND=noninteractive
COPY --from=builder ${PREFIX_DIR} ${PREFIX_DIR}

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends $RUNTIME_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES) \
    && echo "no" | dpkg-reconfigure dash

HEALTHCHECK --interval=5m --timeout=5s CMD nc -z 127.0.0.1 4822 || exit 1

ARG UID=1000
ARG GID=1000
RUN groupadd --gid $GID guacd
RUN useradd --system --create-home --shell /usr/sbin/nologin --uid $UID --gid $GID guacd

USER guacd

EXPOSE 4822

CMD /opt/guacamole/sbin/guacd -b 0.0.0.0 -L $GUACD_LOG_LEVEL -f