---
title: Ubuntu 24.04 (No Docker)
---

This guide installs `wg-easy` directly on Ubuntu 24.04 using systemd.

## Requirements

- Ubuntu 24.04 host (x86_64 or arm64)
- Root access
- A public IP or domain name

## Install

From the project root, run:

```shell
sudo bash scripts/install-ubuntu-24.04.sh
```

The installer will:

- Install OS dependencies (WireGuard tools, build tools, Node.js)
- Build the app
- Deploy to `/opt/wg-easy`
- Create a systemd service (`wg-easy`)

## Configure

Edit `/etc/wg-easy/wg-easy.env` to customize settings and restart the service:

```shell
sudo systemctl restart wg-easy
```

Important settings:

- `INSECURE=true` if you access the UI over plain HTTP
- `PORT` to change the UI port
- `INIT_DEVICE` (optional) to set the default uplink interface (e.g. `ens3`)

If you want to pre-seed settings before the first launch, set `INIT_ENABLED=true` and provide the `INIT_*` values, then restart the service.

## Start / Stop

```shell
sudo systemctl status wg-easy
sudo systemctl restart wg-easy
sudo systemctl stop wg-easy
```

## Firewall

Allow these ports on your host firewall:

- UDP `51820` (WireGuard)
- TCP `51821` (Web UI)
