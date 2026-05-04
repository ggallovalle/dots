#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../" && pwd)"
CONFIG_DIR="${HOME}/.config/chezmoi"

MACHINE="${1:-}"
if [ -z "$MACHINE" ]; then
    echo "Usage: $0 <machine-name>" >&2
    echo "  e.g.: $0 wsl-arch" >&2
    exit 1
fi

MACHINE_DIR="${SCRIPT_DIR}/${MACHINE}"

if [ ! -d "$MACHINE_DIR" ]; then
    echo "Error: Machine config not found: ${MACHINE_DIR}" >&2
    exit 1
fi

echo "Setting up dotfiles..."
echo "  Machine: ${MACHINE}"
echo "  Machine dir: ${MACHINE_DIR}"
echo "  Config dir: ${CONFIG_DIR}"

rm -rf "${CONFIG_DIR}"
ln -sf "${MACHINE_DIR}" "${CONFIG_DIR}"

echo "Done!"
