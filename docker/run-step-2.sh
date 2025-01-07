#!/bin/bash

export LC_ALL="C"
set -euo pipefail
cd "$(dirname "$0")"

podman --version >/dev/null 2>&1 && CMD=podman || CMD=docker
exec $CMD run -it --rm --tmpfs /.cache --tmpfs /run --tmpfs /tmp -v "$PWD/../data:/data:ro" -v "$PWD/inputs:/inputs:ro" -v "$PWD/results:/results" 'localhost/hamronization_workflow-step-2' "${@:-bash}"
