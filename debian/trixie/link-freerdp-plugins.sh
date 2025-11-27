#!/bin/sh -e

##
## Automatically creates any required symbolic links for the proper loading of
## FreeRDP plugins. If a plugin is already in the correct directory, no link
## is created.
##

PREFIX_DIR=${PREFIX_DIR:-/opt/guacamole}
FREERDP_DIR="${PREFIX_DIR}/lib"

where_is_freerdp() {
    find "$FREERDP_DIR" -maxdepth 2 -type d -name 'freerdp*' | sort -u
}

link_plugins() {
    FREERDP_PATHS="$(where_is_freerdp)"

    if [ -z "$FREERDP_PATHS" ]; then
        echo "Unable to locate FreeRDP install location under ${FREERDP_DIR}." >&2
        return 1
    fi

    echo "$FREERDP_PATHS" | while read -r DIR; do
        PLUGIN_DIR="${DIR}/freerdp2"
        [ -d "$PLUGIN_DIR" ] || mkdir -p "$PLUGIN_DIR"

        find "$DIR" -maxdepth 1 -type f -name 'lib*.so*' | while read -r LIB; do
            TARGET="${PLUGIN_DIR}/$(basename "$LIB")"
            if [ ! -e "$TARGET" ]; then
                ln -s "$LIB" "$TARGET"
            fi
        done
    done
}

link_plugins

