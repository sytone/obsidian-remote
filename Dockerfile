FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="github@sytone.com"

RUN \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
    curl \
    libnss3 && \
    echo "**** cleanup ****" && \
    apt-get autoclean && \
    rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

RUN \
    echo "**** download obsidian ****" && \
    curl \
    https://github.com/obsidianmd/obsidian-releases/releases/download/v0.13.31/Obsidian-0.13.31.AppImage \
    -L \
    -o obsidian.AppImage

RUN \
    echo "**** extract obsidian ****" && \
    chmod +x /obsidian.AppImage && \
    /obsidian.AppImage --appimage-extract && \
    mkdir /vaults && \
    chown -R abc:abc  /squashfs-root /vaults

ENV \
    CUSTOM_PORT="8080" \
    GUIAUTOSTART="true" \
    HOME="/vaults"

# add local files
COPY root/ /

EXPOSE 8080
VOLUME ["/config","/vaults"]


