# ================================================================= #
#           Vim Configuration Installer (Windows)                    #
# ================================================================= #
# Creates ~/_vimrc (or ~/.vimrc) that sources the dotfiles vimrc.
#
# Usage: . "$HOME\.dotfiles\vim\install.ps1" [-Restore]

param(
    [switch]$Restore
)

$ErrorActionPreference = 'Stop'

$DOTFILES_DIR = "$HOME\.dotfiles"
$VIM_DIR = "$DOTFILES_DIR\vim"
$BACKUP_DIR = "$HOME\.dotfiles_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

function Find-LatestBackup {
    Get-ChildItem "$HOME\.dotfiles_backup_*" -Directory -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

if ($Restore) {
    $latest = Find-LatestBackup
    if (-not $latest) {
        Write-Host "Error: No backup found." -ForegroundColor Red
        exit 1
    }
    Write-Host "Restoring vim config from: $($latest.FullName)" -ForegroundColor Cyan
    foreach ($name in @('_vimrc', '.vimrc')) {
        $backup = Join-Path $latest.FullName $name
        if (Test-Path $backup) {
            Copy-Item $backup "$HOME\$name" -Force
            Write-Host "  Restored $name" -ForegroundColor Green
        }
    }
    exit 0
}

Write-Host ""
Write-Host "Vim Configuration Setup" -ForegroundColor Cyan
Write-Host "======================="

# Windows Vim typically uses ~/_vimrc, but ~/.vimrc works too
$vimTarget = "$HOME\_vimrc"
if (Test-Path "$HOME\.vimrc") { $vimTarget = "$HOME\.vimrc" }

$vimMarker = "' >>> dotfiles >>>"

if (Test-Path $vimTarget) {
    $vimContent = Get-Content $vimTarget -Raw -ErrorAction SilentlyContinue
    if ($vimContent -and $vimContent.Contains($vimMarker)) {
        Write-Host "  Already configured, skipping." -ForegroundColor DarkGray
    } else {
        if (-not (Test-Path $BACKUP_DIR)) { New-Item $BACKUP_DIR -ItemType Directory -Force | Out-Null }
        Copy-Item $vimTarget $BACKUP_DIR -Force
        Write-Host "  Backed up to $BACKUP_DIR" -ForegroundColor DarkGray
        @"
$vimMarker
source $VIM_DIR\vimrc
' <<< dotfiles <<<
"@ | Add-Content $vimTarget -Encoding UTF8
        Write-Host "  Configured to source $VIM_DIR\vimrc" -ForegroundColor Green
    }
} else {
    @"
$vimMarker
source $VIM_DIR\vimrc
' <<< dotfiles <<<
"@ | Set-Content $vimTarget -Encoding UTF8
    Write-Host "  Created $vimTarget sourcing $VIM_DIR\vimrc" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
