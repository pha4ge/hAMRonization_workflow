#!/bin/bash

# Reproducible bash
export LC_ALL="C"
set -euo pipefail

# Execute in directory of this script
cd "$(dirname "$0")"

# Change this if you prefer a different Conda environment name
ENV_NAME=hamronization_workflow

# Uncomment to force Singularity to be used (1) or not used (0); by default we try detect it
#USE_SINGULARITY=0

# Activate the Conda environment
CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda activate $ENV_NAME

# Unless invoker has set "USE_SINGULARITY" to overrule, try detect it under its various forking guises
[ -z "${USE_SINGULARITY:-}" ] && [ -z "$(singularity version 2>/dev/null)" ] && [ -z "$(apptainer version 2>/dev/null)" ] &&
    USE_SINGULARITY=0 ||
    USE_SINGULARITY=${USE_SINGULARITY:-1}

# Run snakemake on this trivial test-case (we omit --conda-frontend=mamba as it currently bugs out)
if (( USE_SINGULARITY )); then
    exec snakemake --configfile test/test_config.yaml --use-conda --jobs 1 --use-singularity --singularity-args "-B '$PWD:/data'"
else
    exec snakemake --configfile test/test_config.yaml --use-conda --jobs 1
fi
