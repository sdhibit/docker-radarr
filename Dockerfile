FROM sdhibit/mono:5.0-glibc
MAINTAINER Steve Hibit <sdhibit@gmail.com>

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm'

ARG MEDIAINFO_VER="0.7.97"
ARG LIBMEDIAINFO_URL="https://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VER}/MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.gz"
ARG MEDIAINFO_URL="https://mediaarea.net/download/binary/mediainfo/${MEDIAINFO_VER}/MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.gz"

#Build libmediainfo
#Install build packages
RUN apk --update upgrade \
 && apk add --no-cache --virtual=build-dependencies \
        g++ \
        gcc \
        git \
        make \
 && apk --update upgrade \
 && apk add --no-cache \
    ca-certificates \
    curl \
    libcurl \
    libmms \
    sqlite \
    sqlite-libs \
    tar \
    unrar \
    xz \
    zlib \
    zlib-dev \
 && mkdir -p /tmp/libmediainfo \
 && mkdir -p /tmp/mediainfo \
 && curl -kL ${LIBMEDIAINFO_URL} | tar -xz -C /tmp/libmediainfo --strip-components=1 \
 && curl -kL ${MEDIAINFO_URL} | tar -xz -C /tmp/mediainfo --strip-components=1 \
 && cd /tmp/mediainfo \
 && ./CLI_Compile.sh \
 && cd /tmp/mediainfo/MediaInfo/Project/GNU/CLI \
 && make install \
 && cd /tmp/libmediainfo \
 && ./SO_Compile.sh \
 && cd /tmp/libmediainfo/ZenLib/Project/GNU/Library \
 && make install \
 && cd /tmp/libmediainfo/MediaInfoLib/Project/GNU/Library \
 && make install \
 && apk del --purge build-dependencies \
 && rm -rf /tmp/*

# Set Radarr Package Information
ARG PKG_NAME="Radarr"
ARG PKG_VER="0.2"
ARG PKG_BUILD="0.778"
ARG APP_BASEURL="https://github.com/Radarr/Radarr/releases/download"
ARG APP_PKGNAME="v${PKG_VER}.${PKG_BUILD}/${PKG_NAME}.develop.${PKG_VER}.${PKG_BUILD}.linux.tar.gz"
ARG APP_URL="${APP_BASEURL}/${APP_PKGNAME}"
ARG APP_PATH="/opt/radarr"

# Download & Install Radarr
RUN mkdir -p ${APP_PATH} \
 && curl -kL ${APP_URL} | tar -xz -C ${APP_PATH} --strip-components=1 

# Create user and change ownership
RUN mkdir /config \
 && addgroup -g 666 -S radarr \
 && adduser -u 666 -SHG radarr radarr \
 && chown -R radarr:radarr \
    ${APP_PATH} \
    "/config"

VOLUME ["/config"]

# Default Radarr server ports
EXPOSE 7878

WORKDIR ${APP_PATH}

# Add services to runit
ADD radarr.sh /etc/service/radarr/run
RUN chmod +x /etc/service/*/run