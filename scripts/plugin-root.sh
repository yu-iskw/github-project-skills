#!/usr/bin/env bash
# Print the plugin/repository root (directory that contains .claude-plugin/plugin.json).
set -euo pipefail
cd "$(dirname "$0")/.."
pwd
