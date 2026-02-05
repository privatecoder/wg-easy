# wg-easy (Ubuntu 24.04, no Docker)

This repository runs `wg-easy` directly on Ubuntu 24.04 using systemd. Docker support has been removed.

## Requirements

- Ubuntu 24.04 (x86_64 or arm64)
- Root access
- Public IP or domain name

## Install

```shell
sudo bash scripts/install-ubuntu-24.04.sh
```

The installer builds the app, deploys it to `/opt/wg-easy`, and creates the `wg-easy` systemd service.

## Configure

Edit `/etc/wg-easy/wg-easy.env` and restart:

```shell
sudo systemctl restart wg-easy
```

Data is stored in `/etc/wireguard` (including `wg-easy.db`).

Key settings:

- `INSECURE=true` if you access the UI over plain HTTP
- `PORT` to change the UI port (default `51821`)
- `NITRO_HOST` to change the UI bind address (default `0.0.0.0`)
- `INIT_ENABLED=true` with `INIT_*` to pre-seed initial setup values
- `INIT_DEVICE` to set the default uplink interface (e.g. `ens3`)
- `INIT_HOST` / `INIT_PORT` to set the public WireGuard endpoint stored in configs
- `DISABLE_IPV6=true` to disable IPv6

Notes:

- The Web UI listens on `PORT`.
- WireGuard listens on `INIT_PORT`.

## Start / Stop

```shell
sudo systemctl status wg-easy
sudo systemctl restart wg-easy
sudo systemctl stop wg-easy
```

## Firewall

Allow:

- UDP `51820` (WireGuard)
- TCP `51821` (Web UI)

## Upgrade

Re-run the installer and restart:

```shell
sudo bash scripts/install-ubuntu-24.04.sh
sudo systemctl restart wg-easy
```

## Backup / Restore

- Use the Web UI backup to download `wg0.json`.
- The database lives at `/etc/wireguard/wg-easy.db`.

## CLI

Run:

```shell
sudo wg-easy-cli
```

## Uninstall

```shell
sudo systemctl disable --now wg-easy
sudo rm -f /etc/systemd/system/wg-easy.service
sudo systemctl daemon-reload
sudo rm -rf /opt/wg-easy /etc/wg-easy
```

If you want to remove all data, also delete `/etc/wireguard`.
