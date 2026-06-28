#!/usr/bin/env bash
# Memory-safe coverage: run each test dir in its own batch (bounded memory),
# save its lcov, then merge all saved lcovs into coverage/lcov.info.
# Usage:
#   tool/cov.sh <name> <test-path...>   # run one batch, save .covstore/<name>.info
#   tool/cov.sh --merge                 # merge all .covstore/*.info -> coverage/lcov.info
set -uo pipefail
mkdir -p .covstore

if [ "${1:-}" = "--merge" ]; then
  args=()
  for f in .covstore/*.info; do [ -s "$f" ] && args+=(-a "$f"); done
  lcov "${args[@]}" -o coverage/lcov.info >/tmp/lcov_merge.log 2>&1
  echo "merged $(ls .covstore/*.info 2>/dev/null | wc -l | tr -d ' ') batches"
  exit 0
fi

name="$1"; shift
flutter test --coverage --concurrency=2 --timeout 90s "$@" >/tmp/cov_$name.log 2>&1
rc=$?
pass=$(grep -oE "\+[0-9]+" /tmp/cov_$name.log | tail -1)
fail=$(grep -oE "\-[0-9]+" /tmp/cov_$name.log | tail -1)
echo "$name: exit=$rc pass=${pass:-?} fail=${fail:-0}"
if [ $rc -eq 0 ] || [ $rc -eq 1 ]; then
  cp coverage/lcov.info .covstore/$name.info
else
  echo "  WARN: $name exit=$rc (likely OOM/timeout) — lcov NOT saved"
fi
