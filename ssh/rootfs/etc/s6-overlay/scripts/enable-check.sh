#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Enable optional services based on the add-on configuration
# ==============================================================================

# Disable the SSH daemon when no SSH port is exposed
if ! bashio::var.has_value "$(bashio::addon.port 22)"; then
    bashio::log.info \
        "No network port is defined in the configuration so access" \
        "will only be available via the web interface."
    rm -f /etc/s6-overlay/s6-rc.d/user/contents.d/sshd
fi
