#!/bin/bash
# test runner script

# preparing a clean conda install and install dependencies
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
bash miniconda.sh -b -p miniconda
source "miniconda/etc/profile.d/conda.sh"
conda update -y conda 
source "/bioinf/anaconda3/etc/profile.d/conda.sh"

## get and format test data
popd data/test
bash get_test_data.sh
pushd

conda env create -n hamronization --file envs/hamronization.yaml
conda activate harmonization

# run snakemake on this trivial test-case, no snakemake support for singularity args for individual repos
snakemake --configfile config/test_config.yaml --use-conda --jobs 1 --use-singularity --singularity-args "-B $PWD:/data"
