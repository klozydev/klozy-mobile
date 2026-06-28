#!/usr/bin/env bash
#
# Run the test suite with coverage, strip generated code, and emit an HTML report.
#
# Generated files (JSON serialization, DI, routes, asset constants, generated
# localizations) are excluded so the coverage percentage reflects hand-written
# code only.
#
# Usage:
#   ./scripts/coverage.sh          # run tests + filter + html report
#   ./scripts/coverage.sh --no-test  # re-filter an existing coverage/lcov.info
#
set -euo pipefail

cd "$(dirname "$0")/.."

# Patterns for generated code that should never count toward coverage.
EXCLUDE=(
  'lib/l10n/app_localizations*.dart'  # flutter gen-l10n output
  'lib/gen/*'                         # fluttergen asset constants
  '*.g.dart'                          # json_serializable
  '*.gr.dart'                         # auto_route
  '*.config.dart'                     # injectable DI
  '*.gen.dart'                        # asset / misc generators
  '*.freezed.dart'                    # freezed
  '*.mocks.dart'                      # mockito codegen
)

if [[ "${1:-}" != "--no-test" ]]; then
  echo "==> Running tests with coverage"
  flutter test --coverage
fi

if [[ ! -f coverage/lcov.info ]]; then
  echo "coverage/lcov.info not found — run without --no-test first." >&2
  exit 1
fi

echo "==> Stripping generated code from coverage"
lcov --remove coverage/lcov.info "${EXCLUDE[@]}" \
  -o coverage/lcov.info \
  --ignore-errors unused

echo "==> Coverage summary (generated code excluded)"
lcov --summary coverage/lcov.info

if command -v genhtml >/dev/null 2>&1; then
  echo "==> Generating HTML report at coverage/html/index.html"
  genhtml coverage/lcov.info -o coverage/html --quiet
fi
