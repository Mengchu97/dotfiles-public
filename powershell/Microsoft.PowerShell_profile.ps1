# ================================================================= #
#           PowerShell Profile - Windows Desktop Configuration       #
# ================================================================= #
# Source of truth: ~/.dotfiles/powershell/Microsoft.PowerShell_profile.ps1
# Auto-synced by sync-dotfiles.ps1 on startup.

# --- Section 0: PATH Setup ---
# -----------------------------------------------------------------

$openCodeDir = "$env:LOCALAPPDATA\OpenCode"
if ((Test-Path $openCodeDir) -and ($env:Path -notlike "*$openCodeDir*")) {
    $env:Path = "$openCodeDir;$env:Path"
}

$userBin = "$HOME\.local\bin"
if ((Test-Path $userBin) -and ($env:Path -notlike "*$userBin*")) {
    $env:Path = "$userBin;$env:Path"
}


# --- Section 1: Dotfiles Management & Sync ---
# -----------------------------------------------------------------

function dotpush {
    Push-Location "$HOME\.dotfiles"
    try {
        git add .
        if ($args.Count -gt 0) { $msg = $args -join ' ' } else { $msg = 'update dotfiles' }
        if (git commit -m $msg) {
            Write-Host "Pushing changes..." -ForegroundColor Cyan
            git push origin main
        } else {
            Write-Host "No changes to push." -ForegroundColor Green
        }
    } finally {
        Pop-Location
    }
}

function dotpull {
    Push-Location "$HOME\.dotfiles"
    try {
        git pull origin main
    } finally {
        Pop-Location
    }
}

function Sync-Dotfiles {
    $dotfilesDir = "$HOME\.dotfiles"
    $marker = '# >>> dotfiles >>>'

    # Self-heal: ensure $PROFILE has the dot-source marker (don't overwrite the whole file)
    $profileSource = "$dotfilesDir\powershell\Microsoft.PowerShell_profile.ps1"
    if ((Test-Path $profileSource) -and (Test-Path $PROFILE)) {
        $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
        if (-not ($profileContent -and $profileContent.Contains($marker))) {
            @"
$marker
. "$profileSource"
# <<< dotfiles <<<
"@ | Add-Content $PROFILE -Encoding UTF8
            Write-Host "PowerShell profile: added dotfiles source line." -ForegroundColor Green
        }
    }

    # Self-heal: ensure ~/.gitconfig has the include directive (don't overwrite the whole file)
    $gitTarget = "$HOME\.gitconfig"
    $gitSource = "$dotfilesDir\git\gitconfig"
    if (Test-Path $gitSource) {
        if (Test-Path $gitTarget) {
            $gitContent = Get-Content $gitTarget -Raw -ErrorAction SilentlyContinue
            if (-not ($gitContent -and $gitContent.Contains($marker))) {
                @"

$marker
[include]
    path = $gitSource
# <<< dotfiles <<<
"@ | Add-Content $gitTarget -Encoding UTF8
                Write-Host "Git config: added dotfiles include." -ForegroundColor Green
            }
        }
    }

    # Sync OpenCode config files (these are standalone configs, not appended-to files)
    $opencodeConfigDir = "$HOME\.config\opencode"
    if ((Test-Path $opencodeConfigDir) -and (Test-Path "$dotfilesDir\opencode")) {
        @('opencode.json', 'oh-my-openagent.json') | ForEach-Object {
            $src = "$dotfilesDir\opencode\$_"
            $tgt = "$opencodeConfigDir\$_"
            if (Test-Path $src) {
                $srcHash = (Get-FileHash $src -Algorithm SHA256).Hash
                $tgtHash = if (Test-Path $tgt) { (Get-FileHash $tgt -Algorithm SHA256).Hash } else { '' }
                if ($srcHash -ne $tgtHash) {
                    Copy-Item $src $tgt -Force
                }
            }
        }
    }
}

Sync-Dotfiles


# --- OpenCode Profile Switcher ---
# Tracks active profile via ~/.config/opencode/.omo-profile
function Get-OmoProfile {
    $marker = "$HOME\.config\opencode\.omo-profile"
    if (Test-Path $marker) { Get-Content $marker } else { "unknown" }
}

function Switch-OmoProfile {
    param([string]$Profile)
    $src = "$HOME\.dotfiles\opencode\oh-my-openagent-${Profile}.json"
    $tgt = "$HOME\.config\opencode\oh-my-openagent.json"
    $dotfile = "$HOME\.dotfiles\opencode\oh-my-openagent.json"
    if (-not (Test-Path $src)) {
        Write-Host "Profile not found: $src" -ForegroundColor Red
        return
    }
    Copy-Item $src $tgt -Force
    Copy-Item $src $dotfile -Force
    Set-Content -Path "$HOME\.config\opencode\.omo-profile" -Value $Profile
    Write-Host "Switched to ${Profile} profile (restart opencode to apply)" -ForegroundColor Green
}

function omo-budget  { Switch-OmoProfile "budget" }
function omo-premium { Switch-OmoProfile "premium" }
function omo-manual  { Switch-OmoProfile "manual" }
function omo-status {
    $profile = Get-OmoProfile
    Write-Host "Active oh-my-openagent profile: $profile"
    if ($profile -eq "budget") {
        Write-Host "  -> Z.AI workhorse, GPT-5.4 for oracle/prometheus/ultrabrain/deep"
    } elseif ($profile -eq "premium") {
        Write-Host "  -> GPT-5.4 for all reasoning, Gemini 3.1 Pro for writing"
    }
}


# --- Section 2: Navigation & Listing ---
# -----------------------------------------------------------------

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -Colors @{
    Command          = 'Yellow'
    Parameter        = 'Green'
    String           = 'DarkCyan'
    Comment          = 'DarkGray'
}

if ($PSVersionTable.PSVersion.Major -ge 7) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}

Remove-Item Alias:ls -ErrorAction SilentlyContinue
Remove-Item Alias:dir -ErrorAction SilentlyContinue
Remove-Item Alias:cat -ErrorAction SilentlyContinue

if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza --icons --group-directories-first @args }
    function ll { eza -alF --icons --group-directories-first @args }
    function la { eza -a --icons --group-directories-first @args }
    function l { eza -F --icons --group-directories-first @args }
    function tree { eza --tree --icons @args }
} elseif (Get-Command lsd -ErrorAction SilentlyContinue) {
    function ls { lsd @args }
    function ll { lsd -alF @args }
    function la { lsd -a @args }
} else {
    function ll { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force -Hidden @args }
}

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
    Set-Alias -Name cd -Value z -ErrorAction SilentlyContinue
}


# --- Section 3: Proxy Management ---
# -----------------------------------------------------------------

function proxy_on {
    $env:all_proxy = 'socks5://127.0.0.1:12334'
    $env:http_proxy = 'http://127.0.0.1:12334'
    $env:https_proxy = 'http://127.0.0.1:12334'
    Write-Host "Proxy ON (12334)" -ForegroundColor Green
}

function proxy_off {
    Remove-Item Env:\all_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:\http_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:\https_proxy -ErrorAction SilentlyContinue
    Write-Host "Proxy OFF" -ForegroundColor Red
}


# --- Section 4: Git Aliases ---
# -----------------------------------------------------------------

if (Get-Command git -ErrorAction SilentlyContinue) {
    Set-Alias g git
    function gs { git status -s @args }
    function ga { git add @args }
    function gaa { git add -A @args }
    function gc { git commit -m ($args -join ' ') }
    function gca { git commit -a -m ($args -join ' ') }
    function gpl { git pull --prune --tags @args }
    function gps { git push --follow-tags @args }
    function gl { git log --oneline --graph --decorate --all @args }
    function gd { git diff @args }
    function gco { git checkout @args }
    function gb { git branch @args }
    function gst { git status @args }
    function grv { git remote -v @args }
}


# --- Section 5: Development Tools ---
# -----------------------------------------------------------------

if (Get-Command uv -ErrorAction SilentlyContinue) {
    function upy {
        if ($args[0] -match '\.py$') {
            $target = $args[0]
            if ($target.StartsWith('.\')) { $target = $target.Substring(2) }
            $module = $target -replace '\.py$', '' -replace '[\\/]', '.'
            Write-Host "Auto-detected script, running as module: $module" -ForegroundColor Cyan
            uv run python -m $module @($args | Select-Object -Skip 1)
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Module run failed, falling back to direct script execution..." -ForegroundColor Yellow
                uv run python @args
            }
        } else {
            uv run python @args
        }
    }

    function uvnew {
        if (-not (Test-Path '.git')) {
            Write-Host "Git init..." -ForegroundColor Cyan
            git init
            if (-not (Test-Path '.gitignore')) {
                ".venv/", "__pycache__/", "*.pyc" | Set-Content .gitignore
            }
        }
        Write-Host "UV init & venv..." -ForegroundColor Cyan
        uv init; uv venv
        Write-Host "Done. Use 'code .' to start." -ForegroundColor Green
    }
}

if (Get-Command code -ErrorAction SilentlyContinue) {
    Set-Alias c code
}


# --- Section 6: File & Directory Operations ---
# -----------------------------------------------------------------

function mkcd { param([string]$Path) New-Item -ItemType Directory -Path $Path -Force | Set-Location }
function bak { param([string]$File) Copy-Item $File "$File`_$(Get-Date -Format 'yyyyMMdd_HHmmss').bak" }

function extract {
    param([string]$File)
    if (-not (Test-Path $File)) { Write-Host "'$File' is not a valid file" -ForegroundColor Red; return }
    switch -Regex ($File) {
        '\.tar\.bz2$' { tar xjf $File }
        '\.tar\.gz$'  { tar xzf $File }
        '\.bz2$'      { bunzip2 $File }
        '\.gz$'       { gunzip $File }
        '\.tar$'      { tar xf $File }
        '\.zip$'      { Expand-Archive -Path $File -DestinationPath . }
        '\.7z$'       { 7z x $File }
        default       { Write-Host "'$File' cannot be extracted via extract()" -ForegroundColor Yellow }
    }
}


# --- Section 7: System Tools ---
# -----------------------------------------------------------------

function myip {
    try {
        return (Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 5)
    } catch {
        try {
            return (Invoke-RestMethod -Uri 'https://ipinfo.io/ip' -TimeoutSec 5)
        } catch {
            Write-Host "Could not determine external IP." -ForegroundColor Red
        }
    }
}
function reload { . $PROFILE; Write-Host "PowerShell profile reloaded." -ForegroundColor Green }
function ports { netstat -ano | Select-String 'LISTENING' }
Set-Alias -Name which -Value Get-Command -ErrorAction SilentlyContinue

function gbash {
    $gitBash = "${env:ProgramFiles}\Git\bin\bash.exe"
    if (Test-Path $gitBash) {
        & $gitBash -l
    } else {
        Write-Host "Git Bash not found at $gitBash" -ForegroundColor Red
    }
}

function update {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget upgrade --all
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop update *
    } else {
        Write-Host "No supported package manager found (winget/scoop)." -ForegroundColor Red
    }
}


# --- Section 8: Gemini CLI ---
# -----------------------------------------------------------------

function gresume {
    if ($args.Count -eq 0) {
        Write-Host "Usage: gresume <session-id>" -ForegroundColor Red
        return 1
    }

    $projectId = (Get-Location | Split-Path -Leaf).ToLower() -replace '_', '-'
    $rootDir = "$env:USERPROFILE\.gemini\tmp\$projectId"
    $rootFile = "$rootDir\.project_root"

    if (-not (Test-Path $rootDir)) { New-Item -ItemType Directory -Path $rootDir -Force | Out-Null }
    (Get-Location).Path | Out-File -FilePath $rootFile -Encoding utf8 -NoNewline

    gemini --resume @args
}


# --- Section 9: OpenCode CLI ---
# -----------------------------------------------------------------

if (Get-Command opencode -ErrorAction SilentlyContinue) {
    Set-Alias oc opencode
}


# --- Section 10: Oh My Posh Prompt ---
# -----------------------------------------------------------------
# Oh My Posh prompt engine. Falls back to a simple prompt if not installed.
# Theme: ~/.dotfiles/oh-my-posh/theme.omp.json

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $ompConfig = "$HOME\.dotfiles\oh-my-posh\theme.omp.json"
    if (Test-Path $ompConfig) {
        oh-my-posh init pwsh --config $ompConfig | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
} else {
    function prompt {
        $path = Get-Location
        $gitBranch = ''
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            if ($LASTEXITCODE -eq 0) { $gitBranch = " ($branch)" }
        }
        Write-Host -NoNewline -ForegroundColor Green "$env:USERNAME"
        Write-Host -NoNewline "@"
        Write-Host -NoNewline -ForegroundColor Green "$env:COMPUTERNAME"
        Write-Host -NoNewline ":"
        Write-Host -NoNewline -ForegroundColor Blue "$path"
        if ($gitBranch) { Write-Host -NoNewline -ForegroundColor Yellow "$gitBranch" }
        Write-Host ""
        return "> "
    }
}
