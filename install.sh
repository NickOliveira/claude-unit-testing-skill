#!/usr/bin/env bash
#
# Installs the "unittesting" Claude skill and its commands into the user's
# ~/.claude folder.
#
# Usage:
#   ./install.sh            Install (or reinstall) the skill and commands
#
# Honors CLAUDE_CONFIG_DIR if set, otherwise defaults to ~/.claude.

set -euo pipefail

SKILL_NAME="unittesting"

# Resolve the directory this script lives in, so it works from any cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/skill"
COMMANDS_SOURCE_DIR="${SCRIPT_DIR}/commands"

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
SKILLS_DIR="${CLAUDE_DIR}/skills"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
TARGET_DIR="${SKILLS_DIR}/${SKILL_NAME}"

if [ ! -f "${SOURCE_DIR}/SKILL.md" ]; then
  echo "error: ${SOURCE_DIR}/SKILL.md not found; cannot install." >&2
  exit 1
fi

# --- Skill ---
mkdir -p "${SKILLS_DIR}"

if [ -d "${TARGET_DIR}" ]; then
  echo "Replacing existing skill at ${TARGET_DIR}"
  rm -rf "${TARGET_DIR}"
fi

cp -R "${SOURCE_DIR}" "${TARGET_DIR}"
echo "Installed '${SKILL_NAME}' skill to ${TARGET_DIR}"

# --- Commands ---
# Copy each command file individually so we never disturb the user's other commands.
if [ -d "${COMMANDS_SOURCE_DIR}" ]; then
  mkdir -p "${COMMANDS_DIR}"
  for cmd in "${COMMANDS_SOURCE_DIR}"/*.md; do
    [ -e "${cmd}" ] || continue
    cp "${cmd}" "${COMMANDS_DIR}/"
    echo "Installed command /$(basename "${cmd}" .md) to ${COMMANDS_DIR}"
  done
fi
