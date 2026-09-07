#!/usr/bin/env bash
# Antigravity SEO Uninstaller for Unix / macOS / Linux
set -euo pipefail

SKILLS_DIR="${HOME}/.gemini/config/skills"

echo "→ Uninstalling Antigravity SEO..."

removed_skills=0
shopt -s nullglob

if [ -d "${SKILLS_DIR}/seo" ]; then
    rm -rf "${SKILLS_DIR}/seo"
    echo "  Removed: ${SKILLS_DIR}/seo"
    removed_skills=$((removed_skills + 1))
fi

for skill_path in "${SKILLS_DIR}"/seo-*; do
    if [ -d "${skill_path}" ]; then
        rm -rf "${skill_path}"
        echo "  Removed: ${skill_path}"
        removed_skills=$((removed_skills + 1))
    fi
done

shopt -u nullglob

if [ "${removed_skills}" -eq 0 ]; then
    echo "  Nothing to remove. Antigravity SEO does not appear to be installed."
    exit 0
fi

echo "✓ Antigravity SEO uninstalled (${removed_skills} skill directories removed)."
