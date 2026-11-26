FROM alpine:latest

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22

RUN apk add --no-cache openssh borgbackup \
  && passwd -d root \
  && mkdir -p /root/.ssh /host-keys \
  && chmod 700 /root/.ssh \
  && printf '%s\n' \
    'HostKey /host-keys/ssh_host_ed25519_key' \
    'PermitRootLogin prohibit-password' \
    'PubkeyAuthentication yes' \
    'PasswordAuthentication no' \
    'KbdInteractiveAuthentication no' \
    'PermitEmptyPasswords no' \
    'AllowTcpForwarding no' \
    'AllowAgentForwarding no' \
    'AllowStreamLocalForwarding no' \
    'X11Forwarding no' \
    'PermitTunnel no' \
    > /etc/ssh/sshd_config
