Raspberry Pi — node_exporter install

This document shows two ways to run Prometheus node_exporter on Raspberry Pi: native systemd binary and container (podman).

1) Using systemd (recommended)

# On the Raspberry Pi
sudo apt update && sudo apt install -y wget tar jq

ARCH="$(uname -m)"
if [ "$ARCH" = "aarch64" ]; then ARCH_ASSET="linux-arm64"; else ARCH_ASSET="linux-armv7"; fi

VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r .tag_name)
URL="https://github.com/prometheus/node_exporter/releases/download/${VERSION}/node_exporter-${VERSION}.${ARCH_ASSET}.tar.gz"

wget -O /tmp/node_exporter.tar.gz "$URL"
tar -xzf /tmp/node_exporter.tar.gz -C /tmp
sudo cp /tmp/node_exporter-*/node_exporter /usr/local/bin/

sudo useradd --no-create-home --shell /usr/sbin/nologin node_exporter || true

sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<SERVICE
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --path.procfs /proc --path.sysfs /sys

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

# Verify:
curl -s http://localhost:9100/metrics | head -n 20

2) Using Podman (container)

# On the Raspberry Pi (if Podman installed)
podman run -d --name node_exporter --net=host --restart=always \
  -v /proc:/host/proc:ro -v /sys:/host/sys:ro \
  quay.io/prometheus/node-exporter:latest \
  --path.procfs /host/proc --path.sysfs /host/sys

# Verify from Prometheus host:
curl -s http://<rpi_ip>:9100/metrics | head -n 20

3) Prometheus side (this repository)
- Add Raspberry Pi IPs/hostnames to prometheus.yml under `node_exporter_rpis` (example target present).
- Reload Prometheus: `curl -X POST http://localhost:9090/-/reload` or restart the container.

Notes:
- Node exporter listens on TCP/9100. Ensure firewall allows access from Prometheus.
- Replace example IPs with real addresses or DNS names.
