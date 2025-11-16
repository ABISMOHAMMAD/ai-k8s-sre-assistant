#!/usr/bin/env bash
set -euo pipefail


# Minimal installer wrapper for Ollama (works on many Linux x86_64 runners)
# See https://ollama.com/docs for official instructions and platform-specific notes.


if command -v ollama >/dev/null 2>&1; then
echo "ollama already installed: $(ollama --version 2>/dev/null || echo 'unknown')"
exit 0
fi


echo "Installing ollama..."
# The official install script is provided by Ollama; this wrapper calls it.
curl -fsSL https://ollama.com/install.sh | sh


echo "Installation finished. Run 'ollama pull llama3' to download a model (Llama 3)."
