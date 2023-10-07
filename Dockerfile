FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

LABEL maintainer="github@sytone.com" \
      org.opencontainers.image.authors="drdada" \
      org.opencontainers.image.source="https://github.com/drdada/obsidian-remote" \
      org.opencontainers.image.title="Container hosted Obsidian MD" \
      org.opencontainers.image.description="Hosted Obsidian instance allowing access via web browser"

# Update and install extra packages.
RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl nextcloud-desktop-cmd libgtk-3-0 libnotify4 libatspi2.0-0 libsecret-1-0 libnss3 desktop-file-utils fonts-noto-color-emoji git ssh-askpass && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Set version label
ARG OBSIDIAN_REMOTE_RELEASE=1.0

# Download and install Obsidian
RUN echo "**** download obsidian ****" && \
    file_url=$(curl -s "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest" | grep "browser_download_url.*deb" | cut -d : -f 2,3 | tr -d \") && \
    curl --location --output obsidian.deb $file_url && \
    dpkg -i obsidian.deb

# Environment variables
ENV CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8443" \
    CUSTOM_USER="" \
    PASSWORD="" \
    SUBFOLDER="" \
    TITLE="Obsidian Remote v${OBSIDIAN_REMOTE_RELEASE}" \
    FM_HOME="/vaults"

# Add local files
COPY root/ /
EXPOSE 8080 8443
VOLUME ["/config","/vaults"]

# Define a healthcheck
HEALTHCHECK CMD curl --fail http://localhost:8080/ || exit 1
