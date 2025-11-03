FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

LABEL maintainer="github@sytone.com" \
      org.opencontainers.image.authors="github@sytone.com" \
      org.opencontainers.image.source="https://github.com/sytone/obsidian-remote" \
      org.opencontainers.image.title="Container hosted Obsidian MD" \
      org.opencontainers.image.description="Hosted Obsidian instance allowing access via web browser"

# Set version label
ARG OBSIDIAN_VERSION=1.8.10

# Update and install extra packages
RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl libnss3 zlib1g-dev dbus-x11 uuid-runtime \
    libfuse2 libatk1.0-0 libatk-bridge2.0-0 libcups2 libgtk-3-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Download and install Obsidian
ARG TARGETARCH
ARG FLAG=${TARGETARCH#amd64}
RUN echo "**** download obsidian ****" && \
    curl -L -o ./obsidian.AppImage \
        "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}${FLAG:+-arm64}.AppImage" && \
    chmod +x ./obsidian.AppImage && \
    # strip magic bytes for binfmt_misc
    # https://github.com/AppImage/AppImageKit/issues/965
    dd if=/dev/zero bs=1 count=3 seek=8 conv=notrunc of=obsidian.AppImage && \
    ./obsidian.AppImage --appimage-extract && \
    rm ./obsidian.AppImage

# Environment variables
ENV CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8443" \
    CUSTOM_USER="" \
    PASSWORD="" \
    SUBFOLDER="" \
    TITLE="Obsidian v$OBSIDIAN_VERSION" \
    FM_HOME="/vaults"

# Add local files
COPY root/ /

# Expose ports and volumes
EXPOSE 8080 8443
VOLUME ["/config","/vaults"]

# Define a healthcheck
HEALTHCHECK CMD /bin/sh -c 'if [ -z "$CUSTOM_USER" ] || [ -z "$PASSWORD" ]; then curl --fail http://localhost:"$CUSTOM_PORT"/ || exit 1; else curl --fail --user "$CUSTOM_USER:$PASSWORD" http://localhost:"$CUSTOM_PORT"/ || exit 1; fi'
