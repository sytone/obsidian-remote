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
    libfuse2 libatk1.0-0 libatk-bridge2.0-0 libcups2 libgtk-3-0 squashfs-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Download and install Obsidian
# AppImages are self-extracting archives containing a squashfs filesystem.
# When cross-building, we can't execute the binary, so we extract manually
# by finding the squashfs magic bytes ('hsqs') and using unsquashfs.
ARG TARGETARCH
ARG FLAG=${TARGETARCH#amd64}
RUN echo "**** download obsidian ****" && \
    curl -L -o ./obsidian.AppImage \
        "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}${FLAG:+-arm64}.AppImage" && \
    chmod +x ./obsidian.AppImage && \
    (./obsidian.AppImage --appimage-extract || \
     (echo "Extracting AppImage manually..." && \
      offset=$(LC_ALL=C grep -aob 'hsqs' ./obsidian.AppImage | tail -1 | cut -d: -f1) && \
      test -n "$offset" && \
      tail -c +$((offset + 1)) ./obsidian.AppImage > obsidian.squashfs && \
      unsquashfs -d squashfs-root obsidian.squashfs && \
      rm obsidian.squashfs)) && \
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
