# Janus Gateway

A pinned, reproducible container build of the
[Janus WebRTC Server](https://janus.conf.meetecho.com/) with **layered
configuration**.

📖 **[Documentation](https://texttechnologylab.github.io/Janus-Gateway/)**

- **Janus:** 1.4.2 (commit `94408ff`) · **Base:** Ubuntu 24.04

## Why

| | |
|---|---|
| **Pinned** | Janus and every source dependency are fixed to exact versions. Images that track `master` build a different gateway every time - untenable when you must state which software produced a dataset. |
| **Layered config** | Stock Janus configs ship inside the image. You mount only the files you change, instead of vendoring 40 KB of defaults into every project. |
| **Complete** | Data channels (`usrsctp`) and recording post-processing (`janus-pp-rec`) are compiled in. Both are easy to leave out and painful to discover missing. |

## Quick start

```bash
docker run -d --network host \
    -v "$PWD/conf.d:/etc/janus.d:ro" \
    ghcr.io/texttechnologylab/janus-gateway:1.4.2

curl -s http://localhost:8088/janus/info | head -c 200
```

With an empty `conf.d`, that runs stock Janus.

> **Host networking is not required but highly recommended.** ICE must see the real interface to gather
> usable candidates. Bridge networking gives you a gateway that negotiates
> successfully and then carries no media.

## Changing configuration

The image ships Janus's stock configs. Anything you place in `/etc/janus.d` is
copied over the matching default at startup, so you carry only what you change.

```bash
# 1. extract the default
docker run --rm ghcr.io/texttechnologylab/janus-gateway:1.4.2 \
    cat /opt/janus/etc/janus/janus.jcfg > conf.d/janus.jcfg

# 2. edit it, then restart
docker compose restart janus
docker compose logs janus | grep "applied override"
```

> **An override replaces a whole file - it does not merge.** Janus config files
> have no include mechanism, so always start from the shipped default rather than
> writing a fragment.

Full reference, including every setting that usually needs changing:
**[Configuration](https://texttechnologylab.github.io/Janus-Gateway/configuration/)**.

## Building

```bash
docker compose build      # ~30 min, compiles from source
./test-entrypoint.sh      # config-layering self-check
```

See [Building](https://texttechnologylab.github.io/Janus-Gateway/building/).

## Used by

[InterView](https://github.com/texttechnologylab/InterView) - a VR interview
platform - consumes this image and supplies two override files.

## Licence

Packaging in this repository is AGPL-3.0 (`LICENSE`). Janus itself is
[GPL-3.0](https://github.com/meetecho/janus-gateway) and is compiled from
upstream source during the image build.
