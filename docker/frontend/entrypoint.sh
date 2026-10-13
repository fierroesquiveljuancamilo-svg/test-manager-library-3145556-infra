#!/bin/sh
set -eu

if [ ! -f package.json ]; then
    echo "The frontend repository needs a React/Vite project with a dev script in package.json." >&2
    exit 1
fi

if [ -f package-lock.json ]; then
    npm ci --no-audit --no-fund
else
    npm install --package-lock=false --no-audit --no-fund
fi

exec npm run dev -- --host 0.0.0.0 --port 5173 --strictPort
