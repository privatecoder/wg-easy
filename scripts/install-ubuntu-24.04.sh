#!/usr/bin/env bash

set -euo pipefail

log() {
  echo "==> $*"
}

if [[ ${EUID} -ne 0 ]]; then
  echo "This installer must be run as root (use sudo)." >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WG_EASY_DIR="/opt/wg-easy"
WG_EASY_ENV_DIR="/etc/wg-easy"
WG_EASY_ENV_FILE="${WG_EASY_ENV_DIR}/wg-easy.env"
WG_EASY_SERVICE_FILE="/etc/systemd/system/wg-easy.service"
SYSCTL_FILE="/etc/sysctl.d/99-wg-easy.conf"

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "24.04" ]]; then
    echo "Warning: This script targets Ubuntu 24.04. Detected: ${PRETTY_NAME:-unknown}." >&2
  fi
fi

DEFAULT_IFACE="$(ip route show default 0.0.0.0/0 2>/dev/null | awk '{print $5; exit}')"
DEFAULT_IFACE="${DEFAULT_IFACE:-eth0}"

log "Installing OS dependencies..."
apt-get update
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  build-essential \
  python3 \
  pkg-config \
  libssl-dev \
  iproute2 \
  iptables \
  nftables \
  kmod \
  wireguard-go \
  wireguard-tools

log "Loading WireGuard kernel module (if available)..."
if ! modprobe wireguard >/dev/null 2>&1; then
  echo "Warning: WireGuard kernel module not available. You may need linux-modules-extra or userspace wireguard-go." >&2
fi

log "Installing Node.js (if needed)..."
NEED_NODE_INSTALL=1
if command -v node >/dev/null 2>&1; then
  NODE_MAJOR="$(node -v | sed 's/^v//' | cut -d. -f1)"
  if [[ "${NODE_MAJOR}" -ge 20 ]]; then
    NEED_NODE_INSTALL=0
  fi
fi

if [[ "${NEED_NODE_INSTALL}" -eq 1 ]]; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi

log "Enabling corepack and pnpm..."
corepack enable
corepack prepare pnpm@10.28.2 --activate

log "Building wg-easy..."
cd "${ROOT_DIR}/src"
pnpm install --frozen-lockfile
pnpm build

log "Deploying build output..."
rm -rf "${WG_EASY_DIR}"
install -d "${WG_EASY_DIR}"
cp -a "${ROOT_DIR}/src/.output/." "${WG_EASY_DIR}/"
install -d "${WG_EASY_DIR}/server/database"
cp -a "${ROOT_DIR}/src/server/database/migrations" "${WG_EASY_DIR}/server/database/"

log "Installing libsql runtime dependency..."
cd "${WG_EASY_DIR}/server"
npm install --no-save libsql

log "Creating WireGuard config directory..."
install -d -m 700 /etc/wireguard

log "Writing sysctl settings for IP forwarding..."
cat > "${SYSCTL_FILE}" <<SYSCTL
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
SYSCTL
sysctl --system >/dev/null

log "Writing environment file..."
install -d -m 700 "${WG_EASY_ENV_DIR}"
if [[ ! -f "${WG_EASY_ENV_FILE}" ]]; then
  cat > "${WG_EASY_ENV_FILE}" <<ENV
PORT=51821
NITRO_HOST=0.0.0.0
INSECURE=true
INIT_ENABLED=false
# INIT_DEVICE=${DEFAULT_IFACE}
# INIT_USERNAME=admin
# INIT_PASSWORD=change-me
# INIT_HOST=your.public.ip
# INIT_PORT=51820
DISABLE_IPV6=false
ENV
  chmod 600 "${WG_EASY_ENV_FILE}"
fi

log "Writing systemd service..."
cat > "${WG_EASY_SERVICE_FILE}" <<SERVICE
[Unit]
Description=wg-easy
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=${WG_EASY_DIR}
Environment=NODE_ENV=production
EnvironmentFile=${WG_EASY_ENV_FILE}
ExecStart=/usr/bin/env node ${WG_EASY_DIR}/server/index.mjs
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

log "Installing CLI helper..."
cat > /usr/local/bin/wg-easy-cli <<'CLI'
#!/usr/bin/env bash
set -euo pipefail
exec /usr/bin/env node /opt/wg-easy/server/cli.mjs "$@"
CLI
chmod +x /usr/local/bin/wg-easy-cli

log "Enabling wg-easy..."
systemctl daemon-reload
systemctl enable wg-easy

log "Done."
echo "- Web UI: http://<server-ip>:51821"
echo "- Edit ${WG_EASY_ENV_FILE} for configuration and start: systemctl start wg-easy"
echo "- If you are not using HTTPS, keep INSECURE=true"
echo "- Ensure your firewall allows UDP 51820 (WireGuard) and TCP 51821 (UI)"
