# obsidian-remote

This docker image allows you to run obsidian in docker as a container and access it via your web browser.

Use `http://localhost:8080/` to access it locally, do not expose this to the web unless you secure it and know what you are doing!!

## Using Container

To run a interactive version to test it out.

```PowerShell
docker run --rm -it -v D:/repos/obsidian/vaults:/vaults -p 8080:8080 ghcr.io/sytone/obsidian-remote:latest
```

To run it as a daemon.

```PowerShell
docker run -v D:/repos/obsidian/vaults:/vaults -p 8080:8080 ghcr.io/sytone/obsidian-remote:latest
```

## Building locally

To build and use it locally run the following commands:

```PowerShell
docker --debug --log-level debug build --progress plain --pull --rm -f "DockerFile" -t obsidian-remote:latest "."
```

To run the localy build image:

```PowerShell
docker run --rm -it -v D:/repos/obsidian/vaults:/vaults -p 8080:8080 obsidian-remote:latest bash
```
