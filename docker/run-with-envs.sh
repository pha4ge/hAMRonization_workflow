#!/bin/bash

export LC_ALL="C"
set -euo pipefail
cd "$(dirname "$0")/.."

exec docker run -it --rm --tmpfs /.cache --tmpfs /run --tmpfs /tmp -v "$PWD/data:/data:ro" hamronization_workflow-almost "$@"
