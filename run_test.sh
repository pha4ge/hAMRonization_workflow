#!/bin/bash
# test runner script

# preparing a clean conda install and install dependencies
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
bash miniconda.sh -b -p miniconda
source "miniconda/etc/profile.d/conda.sh"
conda install -n base -y conda=4.5.13
conda create -n harmonization -y -c bioconda snakemake blast ariba=2.14.4=py36he1b5a44_0 groot=0.8.3=1 ncbi-amrfinderplus=3.6.10=hf18293b_0 kma unzip bwa git
conda activate harmonization

# get and format databases
cd data/dbs
bash get_dbs.sh
cd ../..

# get and format test data
cd data/test
bash get_test_data.sh
cd ../..

# run snakemake on this trivial test-case
snakemake --configfile config/test_config.yaml --use-conda --jobs 1
