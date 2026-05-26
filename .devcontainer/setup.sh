#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing F* (nightly) ==="
curl -fsSL https://raw.githubusercontent.com/FStarLang/FStar/master/.scripts/install-fstar.sh \
  | bash -s -- --nightly

echo "=== Cloning and building fstar-mcp ==="
git clone --depth=1 https://github.com/FStarLang/fstar-mcp ~/fstar-mcp
cd ~/fstar-mcp
cargo build --release

echo "=== Setup complete ==="
