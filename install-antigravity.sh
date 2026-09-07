#!/usr/bin/env bash
# Antigravity SEO Installer for Unix / macOS / Linux
set -euo pipefail

SKILLS_DIR="${HOME}/.gemini/config/skills"
RULES_DIR="${HOME}/.gemini/config/rules"
REPO_URL="https://github.com/ignacioFinochietti/antigravity-seo"

echo "════════════════════════════════════════"
echo "║   Antigravity SEO - Installer        ║"
echo "║   Google Antigravity SEO Suite       ║"
echo "════════════════════════════════════════"
echo ""

command -v git >/dev/null 2>&1 || { echo "✗ Git is required but not installed."; exit 1; }

mkdir -p "${SKILLS_DIR}"
mkdir -p "${RULES_DIR}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "${SCRIPT_DIR}/skills/seo" ]; then
    SOURCE_DIR="${SCRIPT_DIR}"
    echo "→ Installing from local directory..."
else
    TEMP_DIR=$(mktemp -d)
    cleanup() { rm -rf -- "${TEMP_DIR}"; }
    trap cleanup EXIT
    echo "↓ Downloading Antigravity SEO..."
    git clone --depth 1 "${REPO_URL}" "${TEMP_DIR}/antigravity-seo" 2>/dev/null
    SOURCE_DIR="${TEMP_DIR}/antigravity-seo"
fi

echo "→ Installing skills to ${SKILLS_DIR}..."
if [ -d "${SOURCE_DIR}/skills" ]; then
    for skill_path in "${SOURCE_DIR}/skills"/*/; do
        skill_name=$(basename "${skill_path}")
        target="${SKILLS_DIR}/${skill_name}"
        mkdir -p "${target}"
        cp -r "${skill_path}"* "${target}/"
        echo "  [+] Installed skill: ${skill_name}"
    done
fi

MAIN_SEO="${SKILLS_DIR}/seo"
for folder in schema data pdf scripts bin hooks; do
    if [ -d "${SOURCE_DIR}/${folder}" ]; then
        mkdir -p "${MAIN_SEO}/${folder}"
        cp -r "${SOURCE_DIR}/${folder}/"* "${MAIN_SEO}/${folder}/"
    fi
done

echo ""
echo "✓ Antigravity SEO installed successfully!"
echo "Usage in Google Antigravity:"
echo "  /seo audit <url>"
echo "  /seo schema <url>"
echo "  /seo geo <url>"
