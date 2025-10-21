#!/bin/bash

echo "🔐 Enabling socket..."
podman machine ssh "systemctl --user enable --now podman.socket"

echo "🔐 Setting socket access..."
podman machine ssh "chmod 666 /run/podman/podman.sock && echo '✅ Socket set to 666'"

echo "🚀 Done. Exporter should now have access to Podman API."
