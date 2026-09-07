# Antigravity SEO Uninstaller for Windows
# Removes installed Antigravity SEO skills from ~/.gemini/config/skills

$ErrorActionPreference = "Stop"

$SkillsDir = Join-Path $env:USERPROFILE ".gemini\config\skills"

Write-Host "=== Uninstalling Antigravity SEO ===" -ForegroundColor Cyan
Write-Host ""

$removedSkills = 0

if (Test-Path $SkillsDir -PathType Container) {
    # Remove orchestrator
    $orchestratorPath = Join-Path $SkillsDir "seo"
    if (Test-Path $orchestratorPath -PathType Container) {
        Remove-Item -Recurse -Force $orchestratorPath
        Write-Host "  Removed: $orchestratorPath" -ForegroundColor Green
        $removedSkills++
    }

    # Remove sub-skills
    foreach ($subSkill in @(Get-ChildItem -Path $SkillsDir -Directory -Filter "seo-*" -ErrorAction SilentlyContinue)) {
        Remove-Item -Recurse -Force $subSkill.FullName
        Write-Host "  Removed: $($subSkill.FullName)" -ForegroundColor Green
        $removedSkills++
    }
}

Write-Host ""
if ($removedSkills -eq 0) {
    Write-Host "Nothing to remove. Antigravity SEO does not appear to be installed." -ForegroundColor Yellow
} else {
    Write-Host "=== Antigravity SEO uninstalled ($removedSkills skill directories removed) ===" -ForegroundColor Cyan
}
