#!/bin/bash
set -o pipefail
if [[ ! -z "$CODECHECKER_ACTION_DEBUG" ]]; then
  set -x
fi

set -e

mkdir -p CodeChecker
python3 -m venv CodeChecker/venv
source CodeChecker/venv/bin/activate

if [ "master" = "$IN_VERSION" ]; then
  echo "::group::Installing CodeChecker (latest) from PyPI"
  pip3 install codechecker
else
  echo "::group::Installing CodeChecker ($IN_VERSION) from PyPI"
  pip3 install "codechecker==$IN_VERSION"
fi

pip3 show codechecker
echo "::endgroup::"

which CodeChecker
CodeChecker analyzer-version
CodeChecker web-version

echo "PATH=$(dirname $(which CodeChecker))" >> "$GITHUB_OUTPUT"
echo "VERSION=$(CodeChecker analyzer-version | grep 'Base package' | cut -d'|' -f 2 | tr -d ' ')" >> "$GITHUB_OUTPUT"
echo "GITSEVEN=$(CodeChecker analyzer-version | grep 'Git commit' | cut -d'|' -f 2 | cut -c 2-8)" >> "$GITHUB_OUTPUT"

deactivate
