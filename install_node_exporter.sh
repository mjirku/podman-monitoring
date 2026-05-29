#!/bin/bash
# Simple node_exporter installation for Raspberry Pi

set -e

echo "Installing node_exporter..."

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
  ARCH_ASSET="arm64"
elif [ "$ARCH" = "armv7l" ] || [ "$ARCH" = "armv6l" ]; then
  ARCH_ASSET="armv7"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

echo "Detected architecture: $ARCH ($ARCH_ASSET)"

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq wget tar

# Download latest release
echo "Downloading latest node_exporter..."
LATEST=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep -oP '"tag_name": "\K[^"]+')
echo "Latest version: $LATEST"

URL="https://github.com/prometheus/node_exporter/releases/download/${LATEST}/node_exporter-${LATEST#v}.linux-${ARCH_ASSET}.tar.gz"
echo "URL: $URL"

wget -q "$URL" -O /tmp/node_exporter.tar.gz
tar -xzf /tmp/node_exporter.tar.gz -C /tmp

# Find the extracted directory
EXTRACTED_DIR=$(find /tmp -maxdepth 1 -type d -name "node_exporter-*" | head -1)
if [ -z "$EXTRACTED_DIR" ]; then
  echo "ERROR: Could not find extracted node_exporter directory"
  exit 1
fi

echo "Extracted to: $EXTRACTED_DIR"

# Copy binary
sudo cp "$EXTRACTED_DIR/node_exporter" /usr/local/bin/
sudo chmod +x /usr/local/bin/node_exporter

# Create user
sudo useradd --no-create-home --shell /usr/sbin/nologin node_exporter || true

# Create systemd service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<'EOF'
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --path.procfs /proc --path.sysfs /sys
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Verify
echo ""
echo "Installation complete! Checking status..."
sudo systemctl status node_exporter --no-pager

echo ""
echo "Testing metrics endpoint:"
curl -s http://localhost:9100/metrics | head -n 10

echo ""
echo "Done! Node exporter is running on port 9100"
