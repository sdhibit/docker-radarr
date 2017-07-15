FROM sdhibit/mono-media:5.4
MAINTAINER Steve Hibit <sdhibit@gmail.com>

# Install apk packages
RUN apk --update upgrade \
 && apk --no-cache add \
  ca-certificates \
  sqlite \
  sqlite-libs \
  tar \
  unrar \
 && update-ca-certificates \
 && cert-sync /etc/ssl/certs/ca-certificates.crt


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