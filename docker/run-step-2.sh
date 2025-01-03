#!/bin/bash

export LC_ALL="C"
set -euo pipefail
cd "$(dirname "$0")"

# would use -u "$(id -u):$(id -g)" but the container can't be readonly and files inside are root-owned
exec docker run -it --rm --tmpfs /.cache --tmpfs /run --tmpfs /tmp -v "$PWD/../data:/data:ro" -v "$PWD/inputs:/inputs:ro" -v "$PWD/results:/results" hamronization_workflow-step-2 "$@"
