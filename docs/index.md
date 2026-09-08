# Janus Gateway

A pinned, reproducible container build of the
[Janus WebRTC Server](https://janus.conf.meetecho.com/) with **layered
configuration**.

- **Janus:** 1.4.2 (commit `94408ff`)
- **Base:** Ubuntu 24.04

## Why this image

<div class="grid cards" markdown>

-   :material-pin: **Pinned**

    Janus and every source dependency are fixed to exact versions. Images that
    track `master` produce a different gateway on each rebuild - untenable when
    you need to state which software produced a dataset.

-   :material-layers: **Layered configuration**

    Stock Janus configs ship in the image; you mount only the files you change.
    No baked-in deployment config, no 40 KB of vendored defaults per project.

-   :material-check-decagram: **Complete**

    Data channels (`usrsctp`) and recording post-processing (`janus-pp-rec`) are
    compiled in - both are easy to omit and painful to discover missing.

</div>

## Quick start

```bash
docker run -d --network host \
    -v "$PWD/conf.d:/etc/janus.d:ro" \
    ghcr.io/texttechnologylab/janus-gateway:1.4.2
```

With an empty `conf.d`, this runs stock Janus. Drop in a modified `janus.jcfg` to
change something - see **[Configuration](configuration.md)**.

```bash
curl -s http://localhost:8088/janus/info | head -c 200
```

!!! warning "Host networking is recommended"
    ICE must see the real network interface to gather usable candidates, and the
    RTP range would otherwise need publishing port by port. Bridge networking
    produces a gateway that negotiates successfully and then carries no media.

## What is compiled in

| Component | Provides | If missing |
|---|---|---|
| `libnice` | ICE | No connectivity at all |
| `libwebsockets` | WebSocket API (8188) | The transport most clients use |
| **`usrsctp`** | **Data channels** | Audio and video work; every data channel silently does nothing |
| `libsrtp` | Media encryption | No media |
| `libmicrohttpd` | HTTP API (8088) | No admin or debug access |
| `janus-pp-rec` | `.mjr` → playable media | Recordings need a separate toolchain |

Plugins, transports and event handlers are Janus's standard set - see
[Plugins](plugins.md).

## Documentation

| Page | Covers |
|---|---|
| [Configuration](configuration.md) | **How to change settings** - the layering model, which settings matter |
| [Plugins](plugins.md) | Available plugins and transports |
| [Recordings](recordings.md) | Recording and converting `.mjr` files |
| [Building](building.md) | Rebuilding, changing the Janus version |

## Used by

[InterView](https://texttechnologylab.github.io/InterView/) - a VR interview
platform - consumes this image and supplies two override files.

## Licence

The packaging in this repository is AGPL-3.0. Janus itself is
[GPL-3.0](https://github.com/meetecho/janus-gateway) and is built from upstream
source at image build time.
