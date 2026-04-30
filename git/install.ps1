# ================================================================= #
#           Git Configuration Installer (Windows)                    #
# ================================================================= #
# Sets up [include] directive in ~/.gitconfig to load dotfiles gitconfig.
#
# Usage: . "$HOME\.dotfiles\git\install.ps1" [-Restore]

param(
    [switch]$Restore
)

$ErrorActionPreference = 'Stop'

$DOTFILES_DIR = "$HOME\.dotfiles"
$GIT_DIR = "$DOTFILES_DIR\git"
# Git's [include] path requires forward slashes — backslashes are treated as escape characters
$gitIncludePath = ($GIT_DIR -replace '\\', '/') + '/gitconfig'
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
    Write-Host "Restoring git config from: $($latest.FullName)" -ForegroundColor Cyan
    $gitBackup = Join-Path $latest.FullName '.gitconfig'
    if (Test-Path $gitBackup) {
        Copy-Item $gitBackup "$HOME\.gitconfig" -Force
        Write-Host "  Restored .gitconfig" -ForegroundColor Green
    }
    exit 0
}

Write-Host ""
Write-Host "Git Configuration Setup" -ForegroundColor Cyan
Write-Host "======================="

$gitTarget = "$HOME\.gitconfig"
$gitMarker = "# >>> dotfiles >>>"

if (Test-Path $gitTarget) {
    $gitContent = Get-Content $gitTarget -Raw -ErrorAction SilentlyContinue
    if ($gitContent -and $gitContent.Contains($gitMarker)) {
        Write-Host "  Already configured, skipping." -ForegroundColor DarkGray
    } else {
        if (-not (Test-Path $BACKUP_DIR)) { New-Item $BACKUP_DIR -ItemType Directory -Force | Out-Null }
        Copy-Item $gitTarget $BACKUP_DIR -Force
        Write-Host "  Backed up original .gitconfig to $BACKUP_DIR" -ForegroundColor DarkGray
        @"
$gitMarker
[include]
    path = $gitIncludePath
# <<< dotfiles <<<
"@ | Add-Content $gitTarget -Encoding UTF8
        Write-Host "  Configured git to include $gitIncludePath" -ForegroundColor Green
    }
} else {
    @"
$gitMarker
[include]
    path = $gitIncludePath
# <<< dotfiles <<<
"@ | Set-Content $gitTarget -Encoding UTF8
    Write-Host "  Created .gitconfig with include for $gitIncludePath" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
