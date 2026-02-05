# wg-easy Ubuntu 24.04 (no Docker) changes

Purpose: Track deviations from upstream (docker-based) so future merges are straightforward.

## Removed

- Docker runtime and build files:
  - Dockerfile
  - Dockerfile.dev
  - docker-compose.yml
  - docker-compose.dev.yml
  - .dockerignore
- Docker image build workflows:
  - .github/workflows/deploy.yml
  - .github/workflows/deploy-pr.yml
  - .github/workflows/deploy-development.yml
  - .github/workflows/deploy-edge.yml
- Docker-focused docs/tutorials:
  - docs/content/examples/tutorials/basic-installation.md
  - docs/content/examples/tutorials/docker-run.md
  - docs/content/examples/tutorials/podman-nft.md
  - docs/content/examples/tutorials/traefik.md
  - docs/content/examples/tutorials/caddy.md
  - docs/content/examples/tutorials/reverse-proxyless.md
  - docs/content/examples/tutorials/adguard.md
  - docs/content/examples/tutorials/auto-updates.md
  - docs/content/examples/tutorials/routed.md
- Project-level docs removed:
  - contributing.md
  - CHANGELOG.md

## Added

- Ubuntu 24.04 installer:
  - scripts/install-ubuntu-24.04.sh
- CLI wrapper:
  - /usr/local/bin/wg-easy-cli (installed by script)
- Docs updated for non-Docker install:
  - docs/content/examples/tutorials/dockerless.md
  - docs/content/getting-started.md
  - docs/content/index.md
  - docs/content/guides/cli.md
  - docs/content/contributing/general.md
- README simplified to describe current state, install, config, ops.

## Code changes

- Added INIT_DEVICE support for initial setup:
  - src/server/utils/config.ts (WG_INITIAL_ENV.DEVICE)
  - src/server/database/sqlite.ts (apply device during initial setup)

## Runtime assumptions

- Systemd service runs node: /opt/wg-easy/server/index.mjs
- Data lives in /etc/wireguard (including wg-easy.db)
- UI bind address via NITRO_HOST
- UI port via PORT (default 51821)
- WireGuard endpoint stored via INIT_HOST / INIT_PORT

## If merging upstream later

Likely conflict areas:

- Dockerfile / compose / GitHub workflows will reappear upstream. Decide whether to keep removal or reintroduce.
- README and docs will diverge: keep Ubuntu 24.04 no-Docker framing or merge with upstream docs structure.
- If upstream changes initial setup or env handling, re-apply INIT_DEVICE support.
- If upstream introduces new migrations or CLI changes, ensure installer still copies migrations and installs libsql.

## Installer details

- Builds with pnpm from src/ and deploys /opt/wg-easy
- Installs: nodejs 20 (if missing), wireguard-tools, wireguard-go, build deps
- Creates systemd service: /etc/systemd/system/wg-easy.service
- Writes env file: /etc/wg-easy/wg-easy.env
- Enables forwarding via /etc/sysctl.d/99-wg-easy.conf
 - Service is enabled but not auto-started (user starts after setting INIT_*)
 - Env template no longer includes HOST (legacy)

## Other notable changes

- Root package.json scripts now run local dev/cli without Docker and set PORT/INSECURE defaults.
- README expanded with config key semantics, ops sections (upgrade, backup, CLI, uninstall).
- Docs refreshed for Ubuntu 24.04 (no Docker), including migration, CLI, and local docs preview guidance.
