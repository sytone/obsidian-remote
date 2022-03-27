# obsidian-remote

This docker image allows you to run obsidian in docker as a container and access it via your web browser.

Use `http://localhost:8080/` to access it locally, do not expose this to the web unless you secure it and know what you are doing!!

## Using the Container

To run a interactive version to test it out. This is using windows based path, update for the OS you are running on.

```PowerShell
docker run --rm -it `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config `
  -p 8080:8080 `
  ghcr.io/sytone/obsidian-remote:latest
```

To run it as a daemon in the background.

```PowerShell
docker run -d `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config `
  -p 8080:8080 `
  ghcr.io/sytone/obsidian-remote:latest
```

### Ports

| Port  | Description                             |
| ----- | --------------------------------------- |
| 8080  | Obsidian Web Interface                  |
| 27123 | Local REST API Plugin HTTP Server Port  |
| 27124 | Local REST API Plugin HTTPS Server Port |

### Mapped Volumes

| Path      | Description                                                               |
| --------- | ------------------------------------------------------------------------- |
| `/vaults` | The location on the host for your Obsidian Vaults                         |
| `/config` | The location to store Obsidan configuration and ssh data for obsidian-git |

### Environment Variables

| Environment Variable | Description                                                                                                                                                                                            |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| PUID                 | Set the user ID for the container user. `911` by default.                                                                                                                                              |
| PGID                 | Set the group ID for the continer user. `911` by default.                                                                                                                                              |
| TZ                   | Set the Time Zone for the container, should match your TZ. `Etc/UTC` by default. See [List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for valid options. |
| DOCKER_MODS          | Use to add mods to the container like git. E.g. `DOCKER_MODS=linuxserver/mods:universal-git` See [Docker Mods](https://github.com/linuxserver/docker-mods) for details.                                |

## Using Docker Compose

```YAML
version: '3.8'
services:
  obsidian:
    image: 'ghcr.io/sytone/obsidian-remote:latest'
    container_name: obsidian-remote
    restart: unless-stopped
    ports:
      - 8080:8080
    volumes:
      - /home/obsidian/vaults:/vaults
      - /home/obsidian/config:/config
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Los_Angeles
      - DOCKER_MODS=linuxserver/mods:universal-git
```

## Enabling GIT for the obsidian-git plugin

This container uses the base images from linuxserver.io. This means you can the linuxserver.io mods. To add support for git add the `DOCKER_MODS` environment variable like so `DOCKER_MODS=linuxserver/mods:universal-git`.

### Docker CLI example

```PowerShell
docker run -d `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config `
  -p 8080:8080 `
  -e DOCKER_MODS=linuxserver/mods:universal-git `
  ghcr.io/sytone/obsidian-remote:latest
```

## Reloading Obsidan in the Browser

If you make changes to plugins or do updates that need to have obsidian restarted, instead of having to stop and start the docker container you can just close the Obsidian UI and right click to show the menus and reopen it. Here is a short clip showing how to do it.

![Reloading Obsidian in the Browser](./assets/ReloadExample.gif)

## Setting PUID and PGID

To set PUID and PGID use the follow environment variables on the command line, by default the IDs are 911/911

```PowerShell
docker run --rm -it `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config `
  -e PUID=1000 `
  -e PGID=1000 `
  -p 8080:8080 `
  ghcr.io/sytone/obsidian-remote:latest
```

Or, if you use docker-compose, add them to the environment: section:

```yaml
environment:
  - PUID=1000
  - PGID=1000
```

It is most likely that you will use the id of yourself, which can be obtained by running the command below. The two values you will be interested in are the uid and gid.

```powershell
id $user
```

## Hosting behind a reverse proxy

If you whish to do that **please make sure you are securing it in some way!**. You also need to ensure **websocket** support is enabled.

### Example nginx configuration

This is an example, I recommend a SSL based proxy and some sort of authentication.

```
server {
  set $forward_scheme http;
  set $server         "10.10.10.10";
  set $port           8080;

  listen 80;
  server_name ob.mycooldomain.com;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection $http_connection;
  proxy_http_version 1.1;
  access_log /data/logs/ob_access.log proxy;
  error_log /data/logs/ob_error.log warn;
  location / {
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    proxy_http_version 1.1;
    # Proxy!
    add_header       X-Served-By $host;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Scheme $scheme;
    proxy_set_header X-Forwarded-Proto  $scheme;
    proxy_set_header X-Forwarded-For    $remote_addr;
    proxy_set_header X-Real-IP          $remote_addr;
    proxy_pass       $forward_scheme://$server:$port$request_uri;
  }
}
```

## Building locally

To build and use it locally run the following commands:

```PowerShell
docker build --pull --rm `
  -f "Dockerfile" `
  -t obsidian-remote:latest `
  "."
```

To run the localy build image:

```PowerShell
docker run --rm -it `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config `
  -p 8080:8080 `
  obsidian-remote:latest bash
```
