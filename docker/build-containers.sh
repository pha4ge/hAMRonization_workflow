#!/bin/bash

export LC_ALL="C"
set -euo pipefail
cd "$(dirname "$0")"

# Prefer podman over docker for rootlessness
podman --version >/dev/null 2>&1 && CMD=podman || CMD=docker

# Note the .. at the end, we build the directory above us (which has a .dockerignore)
$CMD build -f Dockerfile-step-0 -t localhost/hamronization_workflow-step-0 .. &&
$CMD build -f Dockerfile-step-1 -t localhost/hamronization_workflow-step-1 .. &&
$CMD build -f Dockerfile-step-2 -t localhost/hamronization_workflow-step-2 .. &&
$CMD build -f Dockerfile -t localhost/hamronization_workflow ..
