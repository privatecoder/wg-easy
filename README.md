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

- `PORT`: Required by wg-easy (`WG_ENV.PORT`) and also picked up by Nitro for the UI port.
- `NITRO_HOST`: Sets the UI bind address (e.g., `0.0.0.0` or `127.0.0.1`).
- `INSECURE`: Controls HTTP/HTTPS assumptions and cookie security in the app.
- `INIT_ENABLED`: If `true`, the app will apply the `INIT_*` values on first setup.
- `INIT_DEVICE`: Sets the default uplink interface in the initial config (e.g., `ens3`).
- `INIT_USERNAME`, `INIT_PASSWORD`, `INIT_HOST`, `INIT_PORT`: Only when `INIT_ENABLED=true`, and only on the first setup run.
- `DISABLE_IPV6`: Disables IPv6 and updates hooks accordingly.

Notes:

- The Web UI listens on `PORT`.
- WireGuard listens on `INIT_PORT`.
- `INIT_*` values are applied only once (first setup).

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
