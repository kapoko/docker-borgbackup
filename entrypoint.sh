#!/bin/ash

set -eu

mkdir -p /run/sshd

if [ -n "${AUTHORIZED_KEYS:-}" ]; then
    umask 077
    mkdir -p /root/.ssh
    printf '%s\n' "$AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
fi

# Generate a host key if one has not been persisted.
if [ ! -f /host-keys/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /host-keys/ssh_host_ed25519_key -q -N ""
fi

# Do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e -p "${SSH_PORT:-22}" "$@"
