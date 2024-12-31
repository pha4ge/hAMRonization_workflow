#!/bin/bash

export LC_ALL="C"
set -euo pipefail
cd "$(dirname "$0")/.."

docker build -f docker/Dockerfile.snake-only -t hamronization_workflow-snake . &&
docker build -f docker/Dockerfile.with-envs -t hamronization_workflow-almost .
