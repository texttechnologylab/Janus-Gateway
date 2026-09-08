#!/bin/sh
# Layered Janus configuration.
#
# The image ships Janus's stock configs in /opt/janus/etc/janus. Any .jcfg file
# mounted into /etc/janus.d is copied over the matching default before Janus
# starts, so a deployment only has to carry the files it actually changes.
#
# Janus config files have no include mechanism: an override replaces a whole
# file, it does not merge into one. Copy the default and edit it.
set -e

JANUS_CONF_DIR="${JANUS_CONF_DIR:-/opt/janus/etc/janus}"
JANUS_OVERRIDE_DIR="${JANUS_OVERRIDE_DIR:-/etc/janus.d}"

if [ -d "$JANUS_OVERRIDE_DIR" ]; then
    for override in "$JANUS_OVERRIDE_DIR"/*.jcfg; do
        [ -e "$override" ] || continue
        name="$(basename "$override")"
        if [ ! -e "$JANUS_CONF_DIR/$name" ]; then
            echo "janus-entrypoint: WARNING '$name' matches no shipped config - Janus will ignore it unless the name is correct" >&2
        fi
        cp "$override" "$JANUS_CONF_DIR/$name"
        echo "janus-entrypoint: applied override $name"
    done
fi

exec "$@"
