# Docker-VHDX-Clean
A simple PowerShell script to check how much space Docker Desktop's WSL2 virtual disk (`docker_data.vhdx`) is eating up on Windows. It lets you safely scan your Docker folders first or automatically stop Docker, unmount the VHDX, and clean out leftover files to free up `C:\` drive space.
