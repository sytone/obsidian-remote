FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye

RUN \
    echo "**** install packages ****" && \
        # Update and install extra packages.
        apt-get update && \
        apt-get install -y --no-install-recommends \
            # Packages needed to download and extract obsidian.
            curl \
            libgtk-3-0 \
            libnotify4 \
            libatspi2.0-0 \
            libsecret-1-0 \
            libnss3 && \
    echo "**** cleanup ****" && \
        apt-get autoclean && \
        rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# set version label
ARG OBSIDIAN_VERSION=1.1.16

RUN dl_url="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb" && \
    curl --location --output obsidian.deb "$dl_url" && \
    dpkg -i obsidian.deb

ENV \
    CUSTOM_PORT="8080" \
    TITLE="Obsidian v$OBSIDIAN_VERSION" \
    FM_HOME="/vaults"

# add local files
COPY /root /

EXPOSE 8080
EXPOSE 27123
EXPOSE 27124
VOLUME ["/config","/vaults"]

