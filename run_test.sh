#!/bin/bash
# test runner script

# preparing a clean conda install and install dependencies
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
bash miniconda.sh -b -p miniconda
source "miniconda/etc/profile.d/conda.sh"
conda update -y conda 

conda create -n db -y -c bioconda blast ariba=2.14.4=py36he1b5a44_0 groot=0.8.3=1 ncbi-amrfinderplus=3.6.10=hf18293b_0 bwa kma unzip 
conda activate db 

# get and format databases
cd data/dbs
bash get_dbs.sh
cd ../..

# get and format test data
cd data/test
bash get_test_data.sh
cd ../..

conda create -n harmonization -y -c bioconda -c conda-forge snakemake=5.10.0 kma bwa 
conda activate harmonization

# install non conda dependencies
cd data/non_conda_deps
bash install_non_conda_deps.sh 
cd ../..

# run snakemake on this trivial test-case, no snakemake support for singularity args for individual repos
snakemake --configfile config/test_config.yaml --use-conda --jobs 1 --use-singularity --singularity-args "-B $PWD:/data"
