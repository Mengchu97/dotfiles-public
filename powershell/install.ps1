# ================================================================= #
#           PowerShell Profile Installer                             #
# ================================================================= #
# Sets up a dot-source line in $PROFILE to load the dotfiles PS config.
#
# Usage: . "$HOME\.dotfiles\powershell\install.ps1" [-Restore]

param(
    [switch]$Restore
)

$ErrorActionPreference = 'Stop'

$DOTFILES_DIR = "$HOME\.dotfiles"
$PS_DIR = "$DOTFILES_DIR\powershell"
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
    Write-Host "Restoring PowerShell profile from: $($latest.FullName)" -ForegroundColor Cyan
    $psProfileDir = Split-Path $PROFILE
    Get-ChildItem $latest.FullName -Filter 'Microsoft.PowerShell_profile.ps1' -File | ForEach-Object {
        Copy-Item $_.FullName $PROFILE -Force
        Write-Host "  Restored PowerShell profile." -ForegroundColor Green
    }
    exit 0
}

Write-Host ""
Write-Host "PowerShell Profile Setup" -ForegroundColor Cyan
Write-Host "========================="

$marker = "# >>> dotfiles >>>"
$psProfileSource = "$PS_DIR\Microsoft.PowerShell_profile.ps1"

if (-not (Test-Path $psProfileSource)) {
    Write-Host "  No PowerShell profile found in dotfiles, skipping." -ForegroundColor DarkGray
    exit 0
}

if (Test-Path $PROFILE) {
    $content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($content -and $content.Contains($marker)) {
        Write-Host "  Already configured, skipping." -ForegroundColor DarkGray
        exit 0
    }
    if (-not (Test-Path $BACKUP_DIR)) { New-Item $BACKUP_DIR -ItemType Directory -Force | Out-Null }
    Copy-Item $PROFILE $BACKUP_DIR -Force
    Write-Host "  Backed up to $BACKUP_DIR" -ForegroundColor DarkGray
}

$targetDir = Split-Path $PROFILE
if (-not (Test-Path $targetDir)) { New-Item $targetDir -ItemType Directory -Force | Out-Null }

@"
$marker
. "$psProfileSource"
# <<< dotfiles <<<
"@ | Add-Content $PROFILE -Encoding UTF8
Write-Host "  Configured to source $psProfileSource" -ForegroundColor Green
Write-Host ""
Write-Host "Done! Restart PowerShell or run '. `$PROFILE'." -ForegroundColor Green
