# ================================================================= #
#           Windows Dotfiles Installation Orchestrator               #
# ================================================================= #
# Run this on a new Windows machine to initialize your environment.
# Calls component-specific installers in each subfolder.
#
# Usage:
#   . "$HOME\.dotfiles\install.ps1"
#
# Options:
#   -Restore    Restore backed up configurations instead of installing
#   -WithFont   Install MesloLGM Nerd Font (for Oh My Posh icons)

param(
    [switch]$Restore,
    [switch]$WithFont
)

# Enable script execution for current user (required for PowerShell profile)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue

$ErrorActionPreference = 'Stop'

$DOTFILES_DIR = "$HOME\.dotfiles"
$FAILED_STEPS = [System.Collections.Generic.List[string]]::new()

function Run-Step {
    param(
        [string]$Name,
        [scriptblock]$Block
    )
    Write-Host ""
    Write-Host "  Installing ${Name}..." -ForegroundColor Yellow
    try {
        & $Block
        Write-Host "   ${Name} done" -ForegroundColor Green
    } catch {
        Write-Host "   ${Name} failed (continuing...)" -ForegroundColor Red
        $FAILED_STEPS.Add($Name)
    }
}

if ($Restore) {
    Write-Host ""
    Write-Host "Restoring configurations..." -ForegroundColor Cyan
    $latestBackup = Get-ChildItem "$HOME\.dotfiles_backup_*" -Directory -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $latestBackup) {
        Write-Host "Error: No backup found to restore from." -ForegroundColor Red
        exit 1
    }
    Write-Host "Restoring from: $($latestBackup.FullName)"
    Run-Step "PowerShell (restore)" { . "$DOTFILES_DIR\powershell\install.ps1" -Restore }
    Run-Step "Git (restore)" { . "$DOTFILES_DIR\git\install.ps1" -Restore }
    Run-Step "Vim (restore)" { . "$DOTFILES_DIR\vim\install.ps1" -Restore }
    Write-Host "Restore Complete!" -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Windows Dotfiles Setup" -ForegroundColor Cyan
Write-Host "======================="

if (-not (Test-Path $DOTFILES_DIR)) {
    Write-Host "Error: Directory $DOTFILES_DIR does not exist." -ForegroundColor Red
    Write-Host "Please clone the repo first:" -ForegroundColor Yellow
    Write-Host "  git clone <repo-url> $DOTFILES_DIR"
    exit 1
}

# 1. Oh My Posh
if ($WithFont) {
    Run-Step "Oh My Posh (with font)" { . "$DOTFILES_DIR\oh-my-posh\install.ps1" -WithFont }
} else {
    Run-Step "Oh My Posh" { . "$DOTFILES_DIR\oh-my-posh\install.ps1" }
}

# 2. PowerShell Profile
Run-Step "PowerShell" { . "$DOTFILES_DIR\powershell\install.ps1" }

# 3. Git Configuration
Run-Step "Git" { . "$DOTFILES_DIR\git\install.ps1" }

# 4. Vim
Run-Step "Vim" { . "$DOTFILES_DIR\vim\install.ps1" }

# 5. OpenCode + Oh-My-OpenAgent / Oh-My-OpenCode-Slim
Run-Step "OpenCode" { . "$DOTFILES_DIR\opencode\install-opencode.ps1" }

Write-Host ""
if ($FAILED_STEPS.Count -gt 0) {
    Write-Host "Setup completed with $($FAILED_STEPS.Count) failure(s):" -ForegroundColor Yellow
    foreach ($step in $FAILED_STEPS) {
        Write-Host "   $step" -ForegroundColor Red
    }
    Write-Host ""
} else {
    Write-Host "Setup Complete!" -ForegroundColor Green
}
Write-Host "Restart PowerShell or run '. `$PROFILE' to take effect." -ForegroundColor DarkGray
Write-Host ""
Write-Host "To restore previous configurations, run:" -ForegroundColor DarkGray
Write-Host "  . `"$DOTFILES_DIR\install.ps1`" -Restore" -ForegroundColor DarkGray
