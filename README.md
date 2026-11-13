# Docker-VHDX-Cleaner
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-5391FE?style=flat-square&logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011%20(WSL2)-0078D6?style=flat-square&logo=windows&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-22C55E?style=flat-square)

A lightweight PowerShell diagnostic and cleanup utility for reclaiming disk space consumed by **Docker Desktop WSL2 virtual disks (`docker_data.vhdx`)** and residual configuration folders on Windows.

## Problem Background
When using Docker Desktop with the WSL2 backend on Windows, container images, OverlayFS layer snapshots (`desktop-containerd`), SHA256 content blobs, and VM ISO caches accumulate inside:

%LOCALAPPDATA%\Docker\wsl\disk\docker_data.vhdx

Even after deleting containers or uninstalling Docker Desktop, this virtual hard disk (`.vhdx`) and related directories can continue occupying tens of gigabytes on the `C:\` drive.

## Features
**Safe Read-Only Analysis (`-Mode Analyze`)**: Scans common Docker Desktop installation, cache, and WSL2 data paths without modifying or deleting any files.
**Automated Process & WSL2 Teardown (`-Mode Clean`)**: Gracefully terminates running Docker processes, shuts down `docker-desktop` / `docker-desktop-data` WSL distributions, and runs `wsl --unmount` on `docker_data.vhdx`.
**Configurable Deep Cleanup (`-IncludeUserConfig`)**: Optionally purges user-level configuration folders (`%APPDATA%\Docker` and `%USERPROFILE%\.docker`).
**Real-Time Free Space Reporting**: Displays available `C:\` drive space before and after execution.

## Prerequisites
**Windows 10 / 11** with **WSL2** enabled
**PowerShell 5.1** or **PowerShell 7+**
**Administrator privileges** (required for `wsl --unmount` and cleaning protected directories)

## Usage
1. Open **PowerShell as Administrator**.
2. If script execution is restricted on your system, allow local scripts for the current session:
   powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
3. Run the utility in your desired mode:

## 1. Analyze Disk Usage (Default — No Changes Made)
powershell
.\Docker-VHDX-Clean.ps1 -Mode Analyze

## 2. Clean WSL2 VHDX & Docker Local Data
powershell
.\Docker-VHDX-Clean.ps1 -Mode Clean

## 3. Full Deep Clean (Including User Configs)
powershell
.\Docker-VHDX-Clean.ps1 -Mode Clean -IncludeUserConfig

## Inspected & Cleaned Paths
Path  Default (`Analyze`)  `Clean`  `Clean -IncludeUserConfig`
`%LOCALAPPDATA%\Docker` (includes `docker_data.vhdx`)  Scanned  **Removed**  **Removed**
`%LOCALAPPDATA%\Docker Desktop` Scanned  **Removed** **Removed** 
`%APPDATA%\Docker`  Scanned  Preserved  **Removed** 
`%USERPROFILE%\.docker`  Scanned  Preserved  **Removed** 
`%ProgramData%\Docker` & `DockerDesktop`  Scanned  Preserved  Preserved 
`C:\Program Files\Docker`  Scanned Preserved  Preserved

## Warning
Running `-Mode Clean` permanently deletes `docker_data.vhdx`, including **all local Docker images, stopped containers, build caches, and volumes** stored inside Docker Desktop's WSL2 backend. Back up any persistent volumes or export critical images (`docker save`) before running in `Clean` mode.

## License
This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.