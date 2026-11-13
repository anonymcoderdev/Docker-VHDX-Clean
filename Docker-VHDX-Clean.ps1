<#
.SYNOPSIS
    Docker Desktop WSL2 (docker_data.vhdx) Disk Analysis and Cleanup Script
.DESCRIPTION
    Analyzes disk space occupied by Docker Desktop WSL2 virtual disks (docker_data.vhdx)
    and leftover directories on the C:\ drive, and safely stops Docker processes,
    unmounts VHDX images, and cleans up residual data when run in Clean mode.
.PARAMETER Mode
    Execution mode: 'Analyze' (default, read-only scan) or 'Clean' (stops Docker, unmounts VHDX, removes directories).
.PARAMETER IncludeUserConfig
    Also removes user-level Docker configuration directories ($env:APPDATA\Docker and $env:USERPROFILE\.docker).
.EXAMPLE
    .\Docker-VHDX-Clean.ps1 -Mode Analyze
.EXAMPLE
    .\Docker-VHDX-Clean.ps1 -Mode Clean
.EXAMPLE
    .\Docker-VHDX-Clean.ps1 -Mode Clean -IncludeUserConfig
#>

param(
    [ValidateSet("Analyze", "Clean")]
    [string]$Mode = "Analyze",
    [switch]$IncludeUserConfig
)

$ErrorActionPreference = "SilentlyContinue"

function Get-FreeSpaceGB {
    return [math]::Round((Get-PSDrive C).Free / 1GB, 2)
}

Write-Host "" -ForegroundColor Cyan
Write-Host " Docker WSL2 VHDX Diagnostic & Cleanup Utility" -ForegroundColor Cyan
Write-Host " Mode: $Mode | Current C:\ Free Space: $(Get-FreeSpaceGB) GB" -ForegroundColor Yellow
Write-Host "`n" -ForegroundColor Cyan

$dockerPaths = @(
    "$env:LOCALAPPDATA\Docker",
    "$env:LOCALAPPDATA\Docker Desktop",
    "$env:APPDATA\Docker",
    "$env:ProgramData\Docker",
    "$env:ProgramData\DockerDesktop",
    "$env:USERPROFILE\.docker",
    "C:\Program Files\Docker"
)

# 1. Analyze existing directories and VHDX files
Write-Host "[1/3] Scanning system for Docker directories..." -ForegroundColor Green
foreach ($path in $dockerPaths) {
    if (Test-Path $path) {
        $sizeBytes = (Get-ChildItem $path -Recurse -File | Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($sizeBytes / 1GB, 2)
        Write-Host ("  [FOUND] {0,-45} -> {1,6} GB" -f $path, $sizeGB) -ForegroundColor White
    }
}

$vhdxPath = "$env:LOCALAPPDATA\Docker\wsl\disk\docker_data.vhdx"
if (Test-Path $vhdxPath) {
    $vhdxSize = [math]::Round((Get-Item $vhdxPath).Length / 1GB, 2)
    Write-Host "`n  [*] Primary VHDX Disk: $vhdxPath ($vhdxSize GB)" -ForegroundColor Magenta
}

if ($Mode -eq "Analyze") {
    Write-Host "`n[INFO] Analysis complete (no files modified). To clean up, run: .\Docker-VHDX-Cleaner.ps1 -Mode Clean" -ForegroundColor Cyan
    exit 0
}

# 2. Clean Mode: Stop processes and unmount VHDX
Write-Host "`n[2/3] Terminating Docker processes and detaching WSL2 virtual disks..." -ForegroundColor Yellow
Get-Process "*Docker*" | Stop-Process -Force
wsl --terminate docker-desktop 2>$null
wsl --terminate docker-desktop-data 2>$null

if (Test-Path $vhdxPath) {
    wsl --unmount $vhdxPath 2>$null
    Write-Host "  [+] VHDX disk unmounted successfully." -ForegroundColor Green
}

# 3. Remove residual directories
Write-Host "`n[3/3] Cleaning up Docker data directories..." -ForegroundColor Yellow
$targetsToRemove = @("$env:LOCALAPPDATA\Docker", "$env:LOCALAPPDATA\Docker Desktop")
if ($IncludeUserConfig) {
    $targetsToRemove += @("$env:APPDATA\Docker", "$env:USERPROFILE\.docker")
}

foreach ($target in $targetsToRemove) {
    if (Test-Path $target) {
        Remove-Item $target -Recurse -Force
        Write-Host "  [-] Removed: $target" -ForegroundColor Green
    }
}

Write-Host "" -ForegroundColor Cyan
Write-Host " Cleanup complete! Updated C:\ Free Space: $(Get-FreeSpaceGB) GB" -ForegroundColor Green
Write-Host "" -ForegroundColor Cyan
