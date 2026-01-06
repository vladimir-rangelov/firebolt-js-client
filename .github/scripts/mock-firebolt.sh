#!/usr/bin/env bash
set -e

echo "Building Mock-Firebolt..."
git clone --depth 1 --branch main https://github.com/rdkcentral/mock-firebolt.git "$MOCK_PATH"
cd "$MOCK_PATH"
git fetch --shallow-since=2025-11-01
git checkout "$MOCK_SHA1SUM"
git apply "$MOCK_PATCH"

cd server
npm install --no-audit --no-fund

cp "$GITHUB_WORKSPACE/.github/mock-firebolt/config.json" \
   "$MOCK_PATH/server/src/.mf.config.json"

npm start > mock-firebolt.log 2>&1 &
echo $! > mock-firebolt.pid

for i in {1..20}; do
  if grep -q "Welcome to Mock Firebolt" mock-firebolt.log; then
    echo "Mock-Firebolt is ready!"
    exit 0
  fi
  sleep 1
done

echo "Mock-Firebolt startup timed out"
exit 1
