#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/michaelkoch51/shvirtd-example-python2102.git"
WORK_DIR="/opt/practicprim-docker"

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

git clone "$REPO_URL" . || git pull

if [ ! -f .env ]; then
  echo "ERROR: .env not found. Create it manually."
  exit 1
fi

docker compose up -d
