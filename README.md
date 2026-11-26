# docker-borgbackup

A Borg backup server over SSH. SSH accepts public-key authentication only;
password and keyboard-interactive authentication are disabled. Root login is
allowed only with a key, and SSH forwarding is disabled.

## Usage

Set `AUTHORIZED_KEYS` to the public keys allowed to connect, and mount storage
for your Borg repositories. A host-key volume is optional but recommended:

```sh
docker run -d --name borgbackup \
  -p 2222:22 \
  -e "AUTHORIZED_KEYS=$(cat ./authorized_keys)" \
  -v borg-host-keys:/host-keys \
  -v borg-data:/backup \
  ghcr.io/kapoko/docker-borgbackup:latest
```

Use only public keys for trusted backup clients. `AUTHORIZED_KEYS` supports multiple entries in OpenSSH
`authorized_keys` format, separated by newlines or literal `\n` sequences
(useful for single-line environment fields in TrueNAS). Environment variables may be visible to
users with access to container configuration. Persist `/host-keys` to avoid
changing the server fingerprint when the container is recreated; verify the
fingerprint through a trusted channel before connecting.

For example, initialize a repository with
`borg init --encryption=repokey ssh://root@HOST:2222/backup/myrepo`.
Anyone with an authorized key has root shell access and full access to the
container's mounted data; restrict keys with a Borg `serve` forced command and
repository path restrictions when appropriate.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `SSH_PORT` | `22` | Port on which sshd listens inside the container. Adjust the container side of `-p` if changed. |
| `AUTHORIZED_KEYS` | unset | SSH public keys and optional authorized-keys restrictions, separated by newlines or literal `\n`. |

## Migration

`ROOT_PASSWORD` and password login are no longer supported. Set
`AUTHORIZED_KEYS` to a client public key before upgrading. The server host
key is now stored in `/host-keys/ssh_host_ed25519_key`, so existing clients
will see a changed host fingerprint; verify and update their `known_hosts`.
