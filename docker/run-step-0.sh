#!/bin/bash

export LC_ALL="C"
set -euo pipefail
cd "$(dirname "$0")"

podman --version >/dev/null 2>&1 && CMD=podman || CMD=docker
exec $CMD run -it --rm --tmpfs /.cache --tmpfs /run --tmpfs /tmp 'localhost/hamronization_workflow-step-0' "${@:-bash}"
