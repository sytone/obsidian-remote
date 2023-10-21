# obsidian-remote

This docker image allows you to run the latest version of [obsidian](https://obsidian.md/) in docker as a container and access it via your web browser.

Use `http://localhost:8080/` to access it locally, do not expose this to the web unless you secure it and know what you are doing!!

**Note :** This is a fork of *sytone/obsidian-remote* project and i missed some features like Nextcloud Sync or auto downloading the latest obsidian version during build. Feel free to use the original if you don't need such feature.


- [Using the Container](#using-the-container)
  - [Ports](#ports)
  - [Mapped Volumes](#mapped-volumes)
  - [Environment Variables](#environment-variables)
- [Using Docker Compose](#using-docker-compose)
- [Enabling GIT for the obsidian-git plugin](#enabling-git-for-the-obsidian-git-plugin)
  - [Docker CLI example](#docker-cli-example)
- [Reloading Obsidan in the Browser](#reloading-obsidan-in-the-browser)
- [Nextcloud](#nextcloud)
- [Setting PUID and PGID](#setting-puid-and-pgid)
- [Adding missing fonts](#adding-missing-fonts)
  - [Map font file using Docker CLI](#map-font-file-using-docker-cli)
  - [Map font file using Docker Compose](#map-font-file-using-docker-compose)
- [Hosting behind a reverse proxy](#hosting-behind-a-reverse-proxy)
  - [Example nginx configuration](#example-nginx-configuration)
- [Hosting behind Nginx Proxy Manager (NPM)](#hosting-behind-nginx-proxy-manager-npm)
- [Updating Obsidian](#updating-obsidian)
- [Building locally](#building-locally)
- [Copy/Paste From External Source](#copypaste-from-external-source)
- [Credits](#Credits)

## Using the Container

To run a interactive version to test it out. This is using windows based path, update for the OS you are running on.

```PowerShell
docker run --rm -it `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config `
  -p 8080:8080 `
  ghcr.io/drdada/obsidian-remote:latest
```

Copy and fill the env file

```PowerShell
cp .env.example .env.local
```

To run it as a daemon in the background, i recommand to do it via docker-compose (see below)

The ARM container is not available, feel free to use the sytone build.

### Ports

| Port  | Description                             |
| ----- | --------------------------------------- |
| 8080  | HTTP Obsidian Web Interface             |
| 8443  | HTTPS Obsidian Web Interface            |

### Mapped Volumes

| Path      | Description                                                               |
| --------- | ------------------------------------------------------------------------- |
| `/vaults` | The location on the host for your Obsidian Vaults                         |
| `/config` | The location to store Obsidan configuration and ssh data for obsidian-git |

### Environment Variables

| Environment Variable | Description                                                                                                                                                                                                                         |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PUID                 | Set the user ID for the container user. `911` by default.                                                                                                                                                                           |
| PGID                 | Set the group ID for the continer user. `911` by default.                                                                                                                                                                           |
| TZ                   | Set the Time Zone for the container, should match your TZ. `Etc/UTC` by default. See [List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for valid options.                              |
| DOCKER_MODS          | Use to add mods to the container like git. E.g. `DOCKER_MODS=linuxserver/mods:universal-git` See [Docker Mods](https://github.com/linuxserver/docker-mods) for details.                                                             |
| KEYBOARD             | Used to se the keyboard being used for input. E.g. `KEYBOARD=en-us-qwerty` or `KEYBOARD=de-de-qwertz` a list of other possible values (not tested) can be found at <https://github.com/linuxserver/docker-digikam#keyboard-layouts> |
| CUSTOM_PORT          | Internal port the container listens on for http if it needs to be swapped from the default 3000.                                                                                                                                    |
| CUSTOM_HTTPS_PORT    | Internal port the container listens on for https if it needs to be swapped from the default 3001.                                                                                                                                   |
| CUSTOM_USER          | HTTP Basic auth username, abc is default.                                                                                                                                                                                           |
| PASSWORD             | HTTP Basic auth password, abc is default. If unset there will be no auth                                                                                                                                                            |
| SUBFOLDER            | Subfolder for the application if running a subfolder reverse proxy, need both slashes IE `/subfolder/`                                                                                                                              |
| TITLE                | The page title displayed on the web browser, default "KasmVNC Client".                                                                                                                                                              |
| FM_HOME              | This is the home directory (landing) for the file manager, default "/config".                                                                                                                                                       |
| NC_USER              | Username for Nextcloud                                                                                                                                                       |
| NC_PASS              | Password for Nextcloud                                                                                                                                                       |
| NC_HOST              | Domain name of your Nextcloud instance (without protocol - https://) E.g. nextcloud.mydomain.net                                                                                                                                                       |
| NC_PATH              | Path where you store your md file on Nextcloud E.g. /Obsidian                                                                                                                                                       |

## Using Docker Compose (Recommanded)

```YAML
version: '3.6'
services:
  obsidian-remote:
    image: 'ghcr.io/drdada/obsidian-remote:latest'
    env_file:
      - .env.local
    ports:
      - 8080
      - 443
    restart: unless-stopped
    volumes:
      - ./vaults:/vaults
      - ./config:/config
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
  ghcr.io/drdada/obsidian-remote:latest
```

## Reloading Obsidan in the Browser

If you make changes to plugins or do updates that need to have obsidian restarted, instead of having to stop and start the docker container you can just close the Obsidian UI and right click to show the menus and reopen it. Here is a short clip showing how to do it.

![Reloading Obsidian in the Browser](./assets/ReloadExample.gif)

## Nextcloud

If you wish to store your MD files on your nextcloud instance, you can trigger a sync script.

Please make sure to copy the .env.local file

Now edit your .env file and fill your Nextcloud credentials and informations.

When starting your docker container, you'll have to mention en env-file

```PowerShell
docker run -d `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config `
  -p 8080:8080 `
  --env-file .env.local `
  ghcr.io/drdada/obsidian-remote:latest
```

### Trigger Sync

The synchronization with Nextcloud is not automated because Obsidian frequently performs file save, which could result in frequent and potentially unnecessary synchronizations. To avoid network overload and minimize unnecessary traffic, the synchronization with Nextcloud is left to the user's discretion and must be done manually.

This approach allows the user to control when the synchronization should take place, choosing appropriate moments when your work are done.

You can trigger sync via right cliking on the desktop and choosing **Nextcloud Sync**

## Setting PUID and PGID

To set PUID and PGID use the follow environment variables on the command line, by default the IDs are 911/911

```PowerShell
docker run --rm -it `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config `
  -e PUID=1000 `
  -e PGID=1000 `
  -p 8080:8080 `
  ghcr.io/drdada/obsidian-remote:latest
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

## Adding missing fonts

Thanks to @aaron-jang for this example.

Download the font of the language that you want to use in Obsidian and add it to the volume as shown below.

### Map font file using Docker CLI

```PowerShell
  -v {downloaded font directory}:/usr/share/fonts/truetype/{font name}
```

### Map font file using Docker Compose

```PowerShell
    volumes:
      - {downloaded font directory}:/usr/share/fonts/truetype/{font name}
```

## Hosting behind a reverse proxy

This is a danger zone ! Exposing this instance on the internet (even without a reverse proxy) increase security risk for your server.
If you wish to do that **please make sure you are securing it in some way!**. You also need to ensure **websocket** support is enabled.
Even if you can set auth to reach the container, it's always a good practice to secure auth to the higher level. So it's better to set password auth via the reverse proxy rather than here.

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

## Hosting behind Nginx Proxy Manager (NPM)

Thanks to @fahrenhe1t for this example.

If you install obsidian-remote in Docker, you can proxy it through [Nginx Proxy Manager](https://nginxproxymanager.com/) (NPM - running on the same Docker instance), and use an access list to provide user authentication. The obsidian-remote container would have to be on the same network as Nginx Proxy Manager. If you don't expose the IP external to the container, authentication would be forced through NPM:

```yaml
services:
  obsidian:
    image: 'ghcr.io/drdada/obsidian-remote:latest'
    container_name: obsidian-remote
    restart: unless-stopped
    ports:
      - 8080 #only exposes port internally to the container
    volumes:
      - /home/obsidian/vaults:/vaults
      - /home/obsidian/config:/config
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Los_Angeles
      - DOCKER_MODS=linuxserver/mods:universal-git
networks:
  default:
    name: <your nginx proxy manager network>
    external: true
```

Create a proxy host in NPM pointing to the "obsidian-remote:8080" container, choose your domain name, use a LetsEncrypt SSL certificate, enable WebSockets. This video talks about it: [Nginx Proxy Manager - ACCESS LIST protection for internal services](https://www.youtube.com/watch?v=G9voYZejH48)

## Updating Obsidian

When creating the container it download the latest version of obsidian.

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


## Copy/Paste From External Source

Open the KasmVNC menu on the middle right and select clipboard

## Credits

Thanks to the original author @sytone


