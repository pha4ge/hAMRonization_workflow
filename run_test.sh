#!/bin/bash

# Reproducible bash
export LC_ALL="C"
set -euo pipefail

# Execute in directory of this script
cd "$(dirname "$0")"

# Change this if you prefer a different Conda environment name
ENV_NAME=hamronization_workflow

# Activate the Conda environment
CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda activate $ENV_NAME

# And run the pipeline
exec snakemake --configfile test/test_config.yaml --use-conda --jobs 1
