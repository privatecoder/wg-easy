---
title: Getting Started
hide:
    - navigation
---

This page explains how to get started with `wg-easy` on Ubuntu 24.04 without Docker.

## Preliminary Steps

Before you can get started with deploying your own VPN, there are some requirements to be met:

1. You need to have a host that you can manage
2. You need to have a domain name or a public IP address
3. You need a supported architecture (x86_64, arm64)

## Install

From the project root, run:

```shell
sudo bash scripts/install-ubuntu-24.04.sh
```

The installer will build `wg-easy`, deploy it to `/opt/wg-easy`, and create the systemd service `wg-easy`.

## Next Steps

1. Open the Web UI at `http://<server-ip>:51821`
2. If you are not using HTTPS, keep `INSECURE=true` in `/etc/wg-easy/wg-easy.env`
3. Verify the outbound interface in **Settings** (default is often `eth0`)
4. Allow UDP `51820` and TCP `51821` in your firewall
