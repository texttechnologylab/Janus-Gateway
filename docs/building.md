# Building

```bash
git clone https://github.com/texttechnologylab/Janus-Gateway.git
cd Janus-Gateway
docker compose build
```

The build compiles Janus and four dependencies from source and takes roughly
**30 minutes**. Layers are cached, so a failed build resumes rather than
restarting.

!!! failure "If the build fails partway"
    Almost always a transient network error fetching one of the source
    dependencies. Re-run it.

## Why from source

The distribution packages are too old for Janus 1.4, and - more importantly - the
build must include `usrsctp` for data channels and `--enable-post-processing` for
`janus-pp-rec`. Both are easy to omit and unpleasant to discover missing later.

## Pinned versions

Build arguments in the `Dockerfile`:

| Argument | Default | |
|---|---|---|
| `JANUS_COMMIT` | `94408ffccbc1a7c39dac82d55e5dd475c807e770` | Janus 1.4.2 |
| `JANUS_VERSION` | `1.4.2` | Label only |
| `LIBSRTP_VERSION` | `2.2.0` | |
| `LIBWEBSOCKETS_BRANCH` | `v4.3-stable` | |

`libnice` and `usrsctp` build from their current default branches.

## Changing the Janus version

```bash
docker compose build --build-arg JANUS_COMMIT=<sha> --build-arg JANUS_VERSION=<x.y.z>
```

For a permanent change, edit the `Dockerfile` defaults so the pin is recorded in
version control - that is the point of pinning.

Verify what you built:

```bash
docker run --rm ghcr.io/texttechnologylab/janus-gateway:1.4.2 /opt/janus/bin/janus --version
```


## libwebsockets flags

Two non-default flags exist to prevent known upstream issues.

| Flag | Reason |
|---|---|
| `-DLWS_MAX_SMP=1` | [meetecho/janus-gateway#732](https://github.com/meetecho/janus-gateway/issues/732) |
| `-DLWS_WITHOUT_EXTENSIONS=0` | [meetecho/janus-gateway#2476](https://github.com/meetecho/janus-gateway/issues/2476) |


## Publishing

`.github/workflows/docker-publish.yml` builds and pushes to GitHub Container
Registry on a tag or a manual run. Tag releases to match the Janus version
(`1.4.2`) so the image tag states what is inside it.
