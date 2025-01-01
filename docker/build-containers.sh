#!/bin/bash

export LC_ALL="C"
set -euo pipefail
cd "$(dirname "$0")/.."

docker build -f docker/Dockerfile.snake-only -t hamronization_workflow-snake-only . &&
docker build -f docker/Dockerfile.no-data -t hamronization_workflow-no-data . &&
docker build -f docker/Dockerfile -t hamronization_workflow .
