#!/usr/bin/env bash
# Run the whole suite in memory-bounded batches, saving each lcov, then merge.
set -uo pipefail
cd "$(dirname "$0")/.."

# non-feature batches
for d in app core data domain router src; do
  tool/cov.sh "top_$d" "test/$d"
done
# per-feature batches
for f in auth cart chat checkout home notifications onboarding orders product profile reels search sell settings; do
  tool/cov.sh "feat_$f" "test/feature/$f"
done

tool/cov.sh --merge
echo "ALL DONE"
