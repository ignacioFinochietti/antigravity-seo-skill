# Antigravity SEO Installer for Windows
# PowerShell installation script for Google Antigravity & Gemini Agent

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "|   Antigravity SEO - Installer        |" -ForegroundColor Cyan
Write-Host "|   Google Antigravity SEO Suite       |" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

function Resolve-Python {
    $candidates = @(
        @{ Exe = 'py'; Args = @('-3') },
        @{ Exe = 'python3'; Args = @() },
        @{ Exe = 'python'; Args = @() }
    )

    foreach ($candidate in $candidates) {
        $resolved = Test-PythonCandidate -Exe $candidate.Exe -Args $candidate.Args
        if ($null -ne $resolved) {
            return $resolved
        }
    }

    return $null
}

function Invoke-External {
    param(
        [Parameter(Mandatory = $true)][string]$Exe,
        [Parameter(Mandatory = $true)][string[]]$Args,
        [switch]$Quiet
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $hasNativePreference = $null -ne (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue)
    if ($hasNativePreference) {
        $previousNativePreference = $PSNativeCommandUseErrorActionPreference
    }

    try {
        $ErrorActionPreference = 'Continue'
        if ($hasNativePreference) {
            $PSNativeCommandUseErrorActionPreference = $false
        }

        $output = & $Exe @Args 2>&1 | ForEach-Object { $_.ToString() }
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
        if ($hasNativePreference) {
            $PSNativeCommandUseErrorActionPreference = $previousNativePreference
        }
    }

    if (-not $Quiet -and $null -ne $output -and $output.Count -gt 0) {
        $output | ForEach-Object { Write-Host $_ }
    }

    return @{ ExitCode = $exitCode; Output = $output }
}

function Test-PythonCandidate {
    param(
        [Parameter(Mandatory = $true)][string]$Exe,
        [Parameter(Mandatory = $true)][string[]]$Args
    )

    $pythonCmd = Get-Command -Name $Exe -ErrorAction SilentlyContinue
    if ($null -eq $pythonCmd) {
        return $null
    }

    $verResult = Invoke-External -Exe $Exe -Args @($Args + @('-c', 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')) -Quiet
    if ($verResult.ExitCode -ne 0 -or $verResult.Output.Count -eq 0) {
        return $null
    }

    $verStr = $verResult.Output[0].Trim()
    $parts = $verStr.Split('.')
    if ($parts.Count -lt 2) {
        return $null
    }

    $major = [int]$parts[0]
    $minor = [int]$parts[1]

    if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 10)) {
        return $null
    }

    return @{ Exe = $Exe; Args = $Args; Version = $verStr }
}

$python = Resolve-Python

if ($null -eq $python) {
    Write-Host "[x] Python 3.10+ is required but not found." -ForegroundColor Red
    Write-Host "    Install from https://www.python.org/downloads/ or via winget:" -ForegroundColor Gray
    Write-Host "    winget install Python.Python.3.12" -ForegroundColor Gray
    exit 1
}

try {
    git --version | Out-Null
    Write-Host "[+] Git detected" -ForegroundColor Green
} catch {
    Write-Host "[x] Git is required but not installed." -ForegroundColor Red
    exit 1
}

# Antigravity paths
$AntigravityBase = Join-Path $env:USERPROFILE ".gemini\config"
$SkillsDir = Join-Path $AntigravityBase "skills"
$RulesDir = Join-Path $AntigravityBase "rules"
$RepoUrl = "https://github.com/ignacioFinochietti/antigravity-seo"

New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
New-Item -ItemType Directory -Force -Path $RulesDir | Out-Null

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check if running inside cloned repo or remote
$IsLocal = Test-Path (Join-Path $ScriptDir "skills\seo")

if ($IsLocal) {
    $SourceDir = $ScriptDir
    Write-Host "=> Installing from local directory: $SourceDir" -ForegroundColor Yellow
} else {
    $TempDir = Join-Path $env:TEMP "antigravity-seo-install"
    if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir }
    Write-Host "=> Downloading Antigravity SEO..." -ForegroundColor Yellow
    $clone = Invoke-External -Exe 'git' -Args @('clone', '--depth', '1', $RepoUrl, $TempDir) -Quiet
    if ($clone.ExitCode -ne 0) {
        throw "git clone failed. Output:`n$($clone.Output -join "`n")"
    }
    $SourceDir = $TempDir
}

try {
    Write-Host "=> Installing Antigravity SEO skills into: $SkillsDir" -ForegroundColor Yellow

    # Copy all skills (orchestrator and 24 sub-skills)
    $AllSkills = Join-Path $SourceDir "skills"
    if (Test-Path $AllSkills) {
        Get-ChildItem -Directory $AllSkills | ForEach-Object {
            $dest = Join-Path $SkillsDir $_.Name
            New-Item -ItemType Directory -Force -Path $dest | Out-Null
            Copy-Item -Recurse -Force "$($_.FullName)\*" $dest
            Write-Host "  [+] Skill installed: $($_.Name)" -ForegroundColor Green
        }
    }

    # Copy schema, data, pdf, scripts to main seo skill folder
    $MainSeo = Join-Path $SkillsDir "seo"
    foreach ($folder in @('schema', 'data', 'pdf', 'scripts', 'bin', 'hooks')) {
        $srcPath = Join-Path $SourceDir $folder
        if (Test-Path $srcPath) {
            $dstPath = Join-Path $MainSeo $folder
            New-Item -ItemType Directory -Force -Path $dstPath | Out-Null
            Copy-Item -Recurse -Force "$srcPath\*" $dstPath
        }
    }

    # Copy extensions skills if present
    $ExtPath = Join-Path $SourceDir "extensions"
    if (Test-Path $ExtPath) {
        Get-ChildItem -Directory $ExtPath | ForEach-Object {
            $subSkills = Join-Path $_.FullName "skills"
            if (Test-Path $subSkills) {
                Get-ChildItem -Directory $subSkills | ForEach-Object {
                    $target = Join-Path $SkillsDir $_.Name
                    New-Item -ItemType Directory -Force -Path $target | Out-Null
                    Copy-Item -Recurse -Force "$($_.FullName)\*" $target
                    Write-Host "  [+] Extension skill installed: $($_.Name)" -ForegroundColor Green
                }
            }
        }
    }

    # Setup Python environment
    Write-Host "=> Setting up Python runtime for SEO tools..." -ForegroundColor Yellow
    $runtimeScript = Join-Path $MainSeo "scripts\runtime.py"
    if (Test-Path $runtimeScript) {
        $runtime = Invoke-External -Exe $python.Exe -Args @($python.Args + @($runtimeScript, 'setup'))
        if ($runtime.ExitCode -ne 0 -and $runtime.ExitCode -ne 10) {
            Write-Host "  [!] Python optional dependencies installation had warnings (runtime can still operate in lightweight mode)." -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "[+] Antigravity SEO installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage in Google Antigravity:" -ForegroundColor Cyan
    Write-Host "  Type in chat:  /seo audit <url>"
    Write-Host "                 /seo schema <url>"
    Write-Host "                 /seo geo <url>"
    Write-Host "                 /seo content-brief <topic>"
    Write-Host ""
} finally {
    if (-not $IsLocal -and (Test-Path $TempDir)) {
        Remove-Item -Recurse -Force $TempDir
    }
}
