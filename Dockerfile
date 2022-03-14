FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal

# set version label
ARG BUILD_DATE=unknown
ARG IMAGE_VERSION
ARG OBSIDIAN_VERSION=0.13.31

LABEL org.opencontainers.image.authors="github@sytone.com"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.source="https://github.com/sytone/obsidian-remote"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.title="Container hosted Obsidian MD"
LABEL org.opencontainers.image.description="Hosted Obsidian instance allowing access via web browser"

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
    https://github.com/obsidianmd/obsidian-releases/releases/download/v$OBSIDIAN_VERSION/Obsidian-$OBSIDIAN_VERSION.AppImage \
    -L \
    -o obsidian.AppImage

RUN \
    echo "**** extract obsidian ****" && \
    chmod +x /obsidian.AppImage && \
    /obsidian.AppImage --appimage-extract

ENV \
    CUSTOM_PORT="8080" \
    GUIAUTOSTART="true" \
    HOME="/vaults"

# add local files
COPY root/ /

EXPOSE 8080
VOLUME ["/config","/vaults"]


