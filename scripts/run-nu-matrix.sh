#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
LANE=${1:-ENV-NU-1}
case "$LANE" in
  ENV-NU-1)
    nu --version
    bash "$ROOT/scripts/test-nu-plugin.sh"
    ;;
  ENV-NU-2|ENV-NU-3)
    echo "$LANE is a placeholder smoke lane in this initial implementation pass"
    nu --version
    ;;
  *)
    echo "unknown lane: $LANE" >&2
    exit 1
    ;;
esac
