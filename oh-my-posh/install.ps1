# ================================================================= #
#           Oh My Posh Installer (Windows)                           #
# ================================================================= #
# Installs Oh My Posh prompt engine and optionally a Nerd Font.
#
# Usage: . "$HOME\.dotfiles\oh-my-posh\install.ps1" [-WithFont] [-Restore]

param(
    [switch]$WithFont,
    [switch]$Restore
)

$ErrorActionPreference = 'Stop'

$DOTFILES_DIR = "$HOME\.dotfiles"
$OMP_DIR = "$DOTFILES_DIR\oh-my-posh"

if ($Restore) {
    Write-Host "Oh My Posh: Restore not needed (no user config files modified by installer)." -ForegroundColor DarkGray
    exit 0
}

Write-Host ""
Write-Host "Oh My Posh Setup" -ForegroundColor Cyan
Write-Host "================"

# --- Install Oh My Posh ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Write-Host "  Already installed: $(oh-my-posh --version)" -ForegroundColor DarkGray
} else {
    Write-Host "  Installing Oh My Posh..." -ForegroundColor Yellow
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $ompTmp = "$env:TEMP\oh-my-posh-install.msix"
        Invoke-WebRequest -Uri "https://cdn.ohmyposh.dev/releases/latest/install-x64.msix" -OutFile $ompTmp -UseBasicParsing
        Add-AppxPackage -Path $ompTmp
        Write-Host "  Installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "  Failed to install automatically. Install manually:" -ForegroundColor Red
        Write-Host "    winget install JanDeDobbeleer.OhMyPosh --source winget" -ForegroundColor DarkGray
        Write-Host "  Or visit: https://ohmyposh.dev/docs/installation/windows" -ForegroundColor DarkGray
    }
}

# --- Install Nerd Font ---
if ($WithFont) {
    Write-Host ""
    Write-Host "  Installing MesloLGM Nerd Font..." -ForegroundColor Yellow
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh font install meslo
        Write-Host "  Font installed." -ForegroundColor Green
        Write-Host ""
        Write-Host "  IMPORTANT: Configure Windows Terminal to use 'MesloLGM Nerd Font':" -ForegroundColor Cyan
        Write-Host "    Settings > Defaults > Appearance > Font > 'MesloLGM Nerd Font'" -ForegroundColor DarkGray
        Write-Host "    VS Code: terminal.integrated.fontFamily = 'MesloLGM Nerd Font'" -ForegroundColor DarkGray
    } else {
        Write-Host "  Cannot install font: oh-my-posh not found." -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "  Tip: Install the recommended font with:" -ForegroundColor DarkGray
    Write-Host "    oh-my-posh font install meslo" -ForegroundColor DarkGray
    Write-Host "    Or re-run with -WithFont flag" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Done! Theme file: $OMP_DIR\theme.omp.json" -ForegroundColor Green
