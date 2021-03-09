#!/bin/bash
# test runner script

# preparing a clean conda install and install dependencies
# wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
# bash miniconda.sh -b -p miniconda
# source "miniconda/etc/profile.d/conda.sh"
# conda update -y conda 
CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh

## get and format test data
conda env create -n hamronization_workflow --file envs/hamronization_workflow.yaml
conda activate hamronization_workflow

# run snakemake on this trivial test-case, no snakemake support for singularity args for individual repos
snakemake --conda-frontend mamba --configfile test/test_config.yaml --use-conda --jobs 1 --use-singularity --singularity-args "-B $PWD:/data"
