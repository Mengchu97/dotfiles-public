#!/usr/bin/env pwsh
# ================================================================= #
#       OpenCode + Oh-My-OpenAgent / Oh-My-OpenCode-Slim Setup      #
# ================================================================= #
# Run this on a new Windows machine to install OpenCode and restore
# your opencode/omo/oms config tracked in your dotfiles repo.
#
# Usage:
#   . "$HOME\.dotfiles\opencode\install-opencode.ps1"
#
# Note: Uses copy (not symlinks) for Windows compatibility.

$ErrorActionPreference = 'Stop'

$DOTFILES_DIR = "$HOME\.dotfiles"
$OPENCODE_DIR = "$DOTFILES_DIR\opencode"
$CONFIG_DIR = "$HOME\.config\opencode"

Write-Host ""
Write-Host "OpenCode + Oh-My-OpenAgent / Oh-My-OpenCode-Slim Setup" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Check if OpenCode is installed
$opencodePath = Get-Command opencode -ErrorAction SilentlyContinue
if ($opencodePath) {
    $version = & opencode --version 2>&1
    Write-Host "OpenCode $version already installed" -ForegroundColor Green
} else {
    Write-Host "OpenCode not found. Please install it first:" -ForegroundColor Yellow
    Write-Host "   https://opencode.ai/docs" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Press Enter after installing OpenCode, or Ctrl+C to abort"
    $opencodePath = Get-Command opencode -ErrorAction SilentlyContinue
    if (-not $opencodePath) {
        Write-Host "OpenCode still not found. Exiting." -ForegroundColor Red
        exit 1
    }
}

# Ensure config directory exists
if (-not (Test-Path $CONFIG_DIR)) {
    New-Item $CONFIG_DIR -ItemType Directory -Force | Out-Null
}

function Sync-Config {
    param(
        [string]$Source,
        [string]$Target,
        [string]$Name
    )

    if (Test-Path $Source) {
        $same = $false
        if (Test-Path $Target) {
            $srcHash = (Get-FileHash $Source -Algorithm SHA256).Hash
            $tgtHash = (Get-FileHash $Target -Algorithm SHA256).Hash
            if ($srcHash -eq $tgtHash) { $same = $true }
        }
        if (-not $same) {
            Copy-Item $Source $Target -Force
        }
        Write-Host "   $Name synced" -ForegroundColor Green
    } else {
        Write-Host "   $Name not found at $Source" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "Syncing config files..." -ForegroundColor Yellow
Sync-Config "$OPENCODE_DIR\opencode.json" "$CONFIG_DIR\opencode.json" "opencode.json"
Sync-Config "$OPENCODE_DIR\oh-my-openagent.json" "$CONFIG_DIR\oh-my-openagent.json" "oh-my-openagent.json"
Sync-Config "$OPENCODE_DIR\oh-my-opencode-slim.json" "$CONFIG_DIR\oh-my-opencode-slim.json" "oh-my-opencode-slim.json"

Write-Host ""
Write-Host "Installing oh-my-opencode-slim plugin..." -ForegroundColor Yellow
$bunxPath = Get-Command bunx -ErrorAction SilentlyContinue
$bunPath = Get-Command bun -ErrorAction SilentlyContinue
if ($bunxPath -or $bunPath) {
    try {
        & bunx oh-my-opencode-slim@latest install --no-config
        Write-Host "   Plugin installed." -ForegroundColor Green
    } catch {
        Write-Host "   Plugin install failed (you may need to run manually)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "   bun not found. Install bun first: https://bun.sh" -ForegroundColor DarkGray
    Write-Host "   Then run: bunx oh-my-opencode-slim@latest install" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Done! Run 'opencode' to start." -ForegroundColor Green
Write-Host "   Profile switchers:"
Write-Host "     omo-glm / omo-gpt / omo-manual  - switch oh-my-openagent profile"
Write-Host "     oms-glm / oms-gpt / oms-manual  - switch oh-my-opencode-slim profile"
Write-Host "     omo-status / oms-status          - show active profile"