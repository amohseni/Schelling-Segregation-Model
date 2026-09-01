#!/usr/bin/env bash
# Install NetLogo Desktop on macOS. Needed only to open ComplexSegregation.nlogo
# in NetLogo itself; index.html runs the same model in a browser with nothing installed.
set -euo pipefail

VERSION="${NETLOGO_VERSION:-6.4.0}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script targets macOS. On Linux/Windows, download from:"
  echo "  https://ccl.northwestern.edu/netlogo/${VERSION}/"
  exit 1
fi

if command -v brew >/dev/null 2>&1; then
  echo "Installing NetLogo ${VERSION} via Homebrew..."
  brew install --cask netlogo
  echo
  echo "Done. Open the model with:"
  echo "  open -a NetLogo \"$(cd "$(dirname "$0")" && pwd)/ComplexSegregation.nlogo\""
  exit 0
fi

echo "Homebrew not found. Either install it from https://brew.sh and re-run,"
echo "or download the macOS installer directly:"
echo "  https://ccl.northwestern.edu/netlogo/${VERSION}/"
exit 1
