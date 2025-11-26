#!/bin/sh

set -e

LINK_SCRIPT="/opt/guacamole/bin/link-freerdp-plugins.sh"

# Ensure FreeRDP plugins live in the expected directory before starting guacd.
if [ -x "$LINK_SCRIPT" ] && [ -w /opt/guacamole/lib ]; then
    "$LINK_SCRIPT"
fi

# Warn about deprecated GUACD_LOG_LEVEL.
if [ -n "$GUACD_LOG_LEVEL" ]; then
    echo "WARNING: The GUACD_LOG_LEVEL environment variable has been deprecated in favor of the LOG_LEVEL environment variable. Please migrate your configuration when possible." >&2
fi

exec /opt/guacamole/sbin/guacd -f -b 0.0.0.0 -L "${LOG_LEVEL:-${GUACD_LOG_LEVEL:-info}}" "$@"

