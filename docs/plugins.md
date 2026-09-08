# Plugins and Transports

Janus's standard set is built. Nothing is removed, so the image suits uses beyond
the one it was written for.

## Plugins

| Plugin | Purpose |
|---|---|
| `janus.plugin.videoroom` | SFU video conferencing. The usual starting point |
| `janus.plugin.audiobridge` | Server-side audio mixing |
| `janus.plugin.textroom` | Text and structured messages over WebRTC data channels |
| `janus.plugin.streaming` | One-to-many streaming mountpoints |
| `janus.plugin.recordplay` | Record and replay sessions |
| `janus.plugin.videocall` | Simple peer-to-peer video calls |
| `janus.plugin.sip` / `nosip` | SIP integration, and SDP-only signalling |
| `janus.plugin.echotest` | Echoes media back. **The fastest way to isolate a client-side media problem** |

Each is configured by `janus.plugin.<name>.jcfg` - see
[Configuration](configuration.md).

!!! tip "`echotest` before anything else"
    When a client cannot establish media, point it at `echotest` first. If that
    fails too, the problem is the client or the network path, not your room
    logic or plugin configuration.

### videoroom and textroom together

A common pattern - and the one [InterView](https://texttechnologylab.github.io/InterView/)
uses - is attaching **two** handles to the same room: `videoroom` for media and
`textroom` as a control channel for application messages.

!!! danger "These two fail independently"
    `textroom` needs working **data channels** (`usrsctp`); `videoroom` does not.
    A data channel fault therefore produces a session where audio and video are
    perfect while every control message silently vanishes.

    That selectivity is diagnostic: if media works and only the data channel
    fails, stop looking at the network and check SCTP.

    ```bash
    docker compose logs janus | grep -i sctp
    ```

## Transports

| Transport | Port | Stock |
|---|---|---|
| WebSockets | 8188 | enabled |
| HTTP | 8088 | enabled |
| Admin WebSockets | 7188 | disabled |
| Admin HTTP | 7088 | disabled |
| Unix sockets (`pfunix`) | - | available |

WebSockets is what most clients use; HTTP is convenient for debugging
(`/janus/info`).

!!! note "The admin API is disabled by default"
    Enable it in `janus.transport.http.jcfg` or
    `janus.transport.websockets.jcfg` if you need runtime introspection - and do
    not expose it publicly. It can enumerate and manipulate live sessions.

## Event handlers

| Handler | Purpose |
|---|---|
| `sampleevh` | POSTs events to an HTTP endpoint |
| `wsevh` | Pushes events over WebSocket |
| `gelfevh` | Emits GELF for Graylog |

Disabled by default. Enable in the matching `janus.eventhandler.*.jcfg` to stream
session statistics out for monitoring.
