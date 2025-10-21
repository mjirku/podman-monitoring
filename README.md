# Podman/Docker Monitoring Stack

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://docs.docker.com/compose/)
[![Grafana](https://img.shields.io/badge/Grafana-7.0+-orange.svg)](https://grafana.com/)
[![Prometheus](https://img.shields.io/badge/Prometheus-2.0+-red.svg)](https://prometheus.io/)

A complete **Grafana + Prometheus + Podman Exporter** monitoring stack for tracking running containers in Podman environments.

Podman Exporter runs with `privileged: true` to access the unix socket `/run/podman/podman.sock`.  
Prometheus and Grafana run without privileges.

---

### 📦 What's included

- **Podman Exporter** – collects metrics from running Podman containers
- **Prometheus** – stores metrics
- **Grafana** – visualizes metrics (pre-configured dashboard for Podman)

---

### 🚀 How to run

1. Clone the repository and navigate to the folder:
   ```bash
   git clone https://github.com/mjirku/podman-monitoring.git
   cd podman-monitoring
   ```

2. Start the stack:
   ```bash
   make up
   ```

### 🌐 Available services

After starting, the services are available at:

- **Grafana** → [http://localhost:3000](http://localhost:3000)
  **User:** `admin`
  **Password:** `admin`

- **Prometheus** → [http://localhost:9090](http://localhost:9090)

- **Podman Exporter Metrics** → [http://localhost:9882/metrics](http://localhost:9882/metrics)


### 🛑 Stop the stack

```bash
make down
```

### 📊 Import dashboard to Grafana

1. Open Grafana → `+` → **Import**
2. Enter Dashboard ID: `21559`
3. Select datasource **Prometheus**
4. Click **Import** → done 🎉


### 📦 Makefile commands
```bash
make up      # Start the stack in background
make down    # Stop the stack
make logs    # Show logs of all services
```
 
### 🪟 Windows: enabling Podman socket

If you're running on Windows (Podman Desktop/Podman Machine), you need to enable the user socket inside the VM so the exporter can access the Podman API.

1. Open PowerShell
2. Navigate to the repository folder
   ```powershell
   Set-Location "C:\Users\<your_username>\working\podman-monitoring"
   ```
3. (One-time) allow execution of local scripts
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
   ```
4. Run the script
   ```powershell
   .\socket_fix.ps1
   ```
   The script will enable `podman.socket` inside the Podman VM and set permissions on `/run/podman/podman.sock`.

If PowerShell reports that `podman` is not found, verify the Podman Desktop installation and that `podman.exe` is in PATH. Alternatively, modify the `$podmanCmd` variable in `socket_fix.ps1` to the full path to `podman.exe`.

### 🍎 macOS: enabling Podman socket

On macOS you can use the equivalent script:
```bash
./socket_fix.sh
```
This will enable `podman.socket` and set access to `/run/podman/podman.sock` in Podman Machine.

## 📜 Project structure

.
├── docker-compose.yml          # Service definitions
├── prometheus.yml              # Prometheus configuration
├── Makefile                    # Easy stack management
├── README.md                   # Documentation
└── .gitignore                  # Git ignored files


### ⚠️ Notes
- Project is designed for macOS and Windows with Podman Machine.
- Podman Exporter runs with `privileged: true` due to socket access requirements.
- If you don't want to use privileged mode, you need to modify permissions on `/run/podman/podman.sock` in the VM.
