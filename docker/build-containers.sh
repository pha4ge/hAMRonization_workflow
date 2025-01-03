#!/bin/bash

export LC_ALL="C"
set -euo pipefail
cd "$(dirname "$0")/.."

docker build -f docker/Dockerfile-step-1 -t hamronization_workflow-step-1 . &&
docker build -f docker/Dockerfile-step-2 -t hamronization_workflow-step-2 . &&
docker build -f docker/Dockerfile -t hamronization_workflow .
