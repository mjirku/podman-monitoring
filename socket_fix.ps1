# Requires: Podman installed and available in PATH as podman or podman.exe

$podmanCmd = "podman.exe"
if (-not (Get-Command $podmanCmd -ErrorAction SilentlyContinue)) {
  $podmanCmd = "podman"
}

Write-Host "🔐 Enabling socket..."
& $podmanCmd machine ssh "systemctl --user enable --now podman.socket" | Out-Host

Write-Host "🔐 Setting socket access..."
& $podmanCmd machine ssh "chmod 666 /run/podman/podman.sock && echo '✅ Socket set to 666'" | Out-Host

Write-Host "🚀 Done. Exporter should now have access to Podman API."
