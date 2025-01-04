#!/bin/bash

# Run the final container with the ../test/test_config.yaml, write results and logs to /tmp

export LC_ALL="C"
set -euo pipefail

# Full path to the 'test' directory that has config and isolates
TEST_DIR="$(realpath "$(dirname "$0")/../test")"

# Use a system mktemp directory for the outputs
TMP_DIR="$(mktemp -d)"
mkdir -p "$TMP_DIR/logs" "$TMP_DIR/results"

# Would rather use -u "$(id -u):$(id -g)" to run the container as the invoking user, but it can't be readonly
# (snakemake chokes on that), and the files inside are root-owned, so our output will be root-owned unless
# the Docker daemon was set up with user namespaces.  Time to move on to Podman or Singularity.

docker run -it --rm --tmpfs /.cache --tmpfs /run --tmpfs /tmp \
     -v "$TEST_DIR:/test:ro" -v "$TMP_DIR/results:/results" -v "$TMP_DIR/logs:/logs" \
     'hamronization_workflow' \
     snakemake --configfile 'test/test_config.yaml' --use-conda --cores $(nproc) || true

printf '
--------------------------------
Container test outputs are here:
 - logs: %s/logs
 - results: %s/results
--------------------------------
' "$TMP_DIR" "$TMP_DIR"
