#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
export FORGE_BIN="${FORGE_BIN:-$ROOT/tests/stub-forge.py}"
export FORGE_STUB_LOG="${FORGE_STUB_LOG:-$ROOT/.forge/test-suite-log.jsonl}"
export FORGE_STUB_STATE="${FORGE_STUB_STATE:-$ROOT/.forge/test-suite-state.json}"

python3 "$ROOT/tests/stub-forge.py" --reset
nu -c 'use ./forgecode.nu *; print "load ok"' | grep -q 'load ok'
nu "$ROOT/tests/test_dispatch.nu"
nu "$ROOT/tests/test_actions.nu"
nu "$ROOT/tests/test_prompt.nu"
nu "$ROOT/tests/test_completion.nu"
python3 "$ROOT/tests/pty_smoke.py"
echo 'test suite passed'
