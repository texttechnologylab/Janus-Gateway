# Recordings

Janus records to `.mjr`, its own container format. `janus-pp-rec` is compiled
into this image to convert them.

## Enabling

Recording is usually toggled **at runtime** by the application - for the
videoroom plugin, via the `enable_recording` request - rather than being switched
on in configuration. Set `record` and `rec_dir` in
`janus.plugin.videoroom.jcfg` only if you want it always on.

Mount somewhere with real capacity:

```yaml
volumes:
  - /srv/janus/recordings:/mnt/recordings
```

## File layout

One file **per media track, per participant**:

```
videoroom-<room>-user-<userid>-<timestamp>-audio-0.mjr
videoroom-<room>-user-<userid>-<timestamp>-video-1.mjr
```

## Converting

```bash
docker compose exec janus janus-pp-rec /mnt/recordings/<file>-audio-0.mjr /mnt/recordings/audio.opus
docker compose exec janus janus-pp-rec /mnt/recordings/<file>-video-1.mjr /mnt/recordings/video.webm
```

Then combine one participant's tracks:

```bash
ffmpeg -i video.webm -i audio.opus -c copy participant.webm
```


`janus-pp-rec` can also print a file's header without converting it, which is the
quickest way to check a recording is intact:

```bash
docker compose exec janus janus-pp-rec --header /mnt/recordings/<file>.mjr
```

## Checking a session immediately

```bash
ls -la /srv/janus/recordings/
```

Expect one file per track per participant, all non-empty. A zero-byte file means that
track never started - worth catching while the participants are still there.
