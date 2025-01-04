#!/bin/bash

export LC_ALL="C"
set -euo pipefail
cd "$(dirname "$0")"

# Note the .. at the end, we build the directory above us (which has a .dockerignore)
docker build -f Dockerfile-step-0 -t localhost/hamronization_workflow-step-0 .. &&
docker build -f Dockerfile-step-1 -t localhost/hamronization_workflow-step-1 .. &&
docker build -f Dockerfile-step-2 -t localhost/hamronization_workflow-step-2 .. &&
docker build -f Dockerfile -t localhost/hamronization_workflow ..
