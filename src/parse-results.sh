#!/bin/bash
set -x

if [[ -z "$PROJECT_PATH" ]]; then
  echo "::error title=Internal error::environment variable 'PROJECT_PATH' missing!"
  exit 1
fi

if [[ -z "$RAW_RESULT_DIR" ]]; then
  echo "::error title=Internal error::environment variable 'RAW_RESULT_DIR' missing!"
  exit 1
fi

OUTPUT_DIR="$RAW_RESULT_DIR"_HTML
OUTPUT_LOG="$(dirname "$RAW_RESULT_DIR")"/"$(basename "$RAW_RESULT_DIR")_Diff.log"
mkdir -pv "$(dirname "$OUTPUT_DIR")"

if [[ ! -z "$IN_CONFIGFILE" ]]; then
  CONFIG_FLAG_1="--config"
  CONFIG_FLAG_2=$IN_CONFIGFILE
  echo "Using configuration file \"$IN_CONFIGFILE\"!"
fi

"$CODECHECKER_PATH"/CodeChecker parse \
  "$RAW_RESULT_DIR" \
  --export "html" \
  --output "$OUTPUT_DIR" \
  --trim-path-prefix "$PROJECT_PATH" \
  || true
echo "::set-output name=HTML_DIR::$OUTPUT_DIR"

"$CODECHECKER_PATH"/CodeChecker parse \
  "$RAW_RESULT_DIR" \
  --trim-path-prefix "$PROJECT_PATH" \
  > "$OUTPUT_LOG"
EXIT_CODE=$?

cat "$OUTPUT_LOG"
echo "::set-output name=OUTPUT_LOG::$OUTPUT_LOG"

if [[ $EXIT_CODE -eq 2 ]]; then
  echo "::set-output name=HAS_FINDINGS::true"

  # Let the jobs continue. If there were findings, the script may be breaking
  # the build in a later step. (After a potential upload to server.)
  EXIT_CODE=0
elif [[ $EXIT_CODE -eq 0 ]]; then
  echo "::set-output name=HAS_FINDINGS::false"
fi

# Exit code 1 is internal error of executing the step.

exit $EXIT_CODE
