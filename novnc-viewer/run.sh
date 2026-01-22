#!/usr/bin/with-contenv bashio

# English: Fetch configuration from Home Assistant UI using bashio
DEFAULT_HOST=$(bashio::config 'vnc_host')
DEFAULT_PORT=$(bashio::config 'vnc_port')
FILE_NAME=$(bashio::config 'config_file_name')
CONFIG_PATH="/share/$FILE_NAME"

# English: Function to clean and extract the target from the file
get_target_from_file() {
    if [ -f "$CONFIG_PATH" ]; then
        # Strip all whitespace and newlines for stability
        sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$CONFIG_PATH"
    else
        echo "${DEFAULT_HOST}:${DEFAULT_PORT}"
    fi
}

# English: Initial setup
CURRENT_TARGET=$(get_target_from_file)
bashio::log.info "Starting noVNC Bridge with target: [${CURRENT_TARGET}]"

# English: Start websockify in background (Port 8080 is required for Ingress)
/usr/bin/websockify --web /usr/share/novnc --heartbeat 30 8080 "${CURRENT_TARGET}" &
BRIDGE_PID=$!

# English: Monitor loop for dynamic switching without restarting the addon
while true; do
    sleep 2
    NEW_TARGET=$(get_target_from_file)

    if [ "$NEW_TARGET" != "$CURRENT_TARGET" ]; then
        bashio::log.info "New target detected in $FILE_NAME: [${NEW_TARGET}]. Restarting bridge..."
        
        kill $BRIDGE_PID
        wait $BRIDGE_PID 2>/dev/null
        
        CURRENT_TARGET=$NEW_TARGET
        /usr/bin/websockify --web /usr/share/novnc --heartbeat 30 8080 "${CURRENT_TARGET}" &
        BRIDGE_PID=$!
    fi
done
