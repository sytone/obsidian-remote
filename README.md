# obsidian-remote

This docker image allows you to run obsidian in docker as a container and access it via your web browser.

Use `http://localhost:8080/` to access it locally, do not expose this to the web unless you secure it and know what you are doing!!

## Using Container

To run a interactive version to test it out. This is using windows based path, update for the OS you are running on.

```PowerShell
docker run --rm -it `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config/.config/obsidian `
  -p 8080:8080 `
  ghcr.io/sytone/obsidian-remote:latest
```

To run it as a daemon.

```PowerShell
docker run -d `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config/.config/obsidian `
  -p 8080:8080 `
  ghcr.io/sytone/obsidian-remote:latest
```

## Setting PUID and PGID

To set PUID and PGID use the follow environment variables on the command line, by default the IDs are 911/911 

```PowerShell
docker run --rm -it `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config/.config/obsidian `
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

## Building locally

To build and use it locally run the following commands:

```PowerShell
docker build --pull --rm --build-arg `
  BUILD_DATE=$(date -uformat +"%Y%m%d") `
  -f "Dockerfile" `
  -t obsidian-remote:latest `
  "."
```

To run the localy build image:

```PowerShell
docker run --rm -it `
  -v D:/ob/vaults:/vaults `
  -v D:/ob/config:/config/.config/obsidian `
  -p 8080:8080 `
  obsidian-remote:latest bash
```

## Using Docker Compose

```YAML
version: '3.8'
services:
  obsidian:
    image: 'ghcr.io/sytone/obsidian-remote:latest'
    container_name: obsidian-remote
    restart: unless-stopped
    ports:
      - 8585:8080
    volumes:
      - /home/obsidian/vaults:/vaults
      - /home/obsidian/config:/config/.config/obsidian

```
