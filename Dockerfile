#Testing changes

FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal

LABEL org.opencontainers.image.authors="michael@maldonado.tech"
LABEL org.opencontainers.image.source="https://github.com/punchy98/obsidian-remote"
LABEL org.opencontainers.image.title="Containerized Obsidian instance"
LABEL org.opencontainers.image.description="Containerized Obsidian instance"

RUN \
    echo "**** install packages ****" && \
        # Update and install extra packages.
        apt-get update && \
        apt-get install -y --no-install-recommends \
            # Packages needed to download and extract obsidian.
            curl \
            libnss3 \
            # Install Chrome dependencies.
            dbus-x11 \
            uuid-runtime && \
    echo "**** cleanup ****" && \
        apt-get autoclean && \
        rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# set version label
#ARG OBSIDIAN_VERSION=0.1.0

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
    HOME="/vaults" \
    TITLE="Obsidian v$OBSIDIAN_VERSION"

# add local files
COPY root/ /

EXPOSE 8080
EXPOSE 27123
EXPOSE 27124
VOLUME ["/config","/vaults"]


