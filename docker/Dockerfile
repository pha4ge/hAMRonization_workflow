# base image 
FROM continuumio/miniconda3

# metadata
LABEL base.image="miniconda3"
LABEL version="1"
LABEL software="hAMRonization"
LABEL software.version="1.0.0"
LABEL description="Workflow for running many AMR tools on a set of reads/contigs"
LABEL website="https://github.com/pha4ge/hamronization"
LABEL documentation="https://github.com/pha4ge/hamronization_workflow"
LABEL license="https://github.com/pha4ge/hAMRonization/blob/master/LICENSE.txt"
LABEL tags="Genomics"

# maintainer
MAINTAINER Finlay Maguire <finlaymaguire@gmail.com>

# get the system essentials
RUN apt-get -qq update --fix-missing && \
    apt-get -qq install apt-utils && \
    dpkg --configure -a && \
    apt-get -qq install --no-install-recommends git build-essential curl wget unzip bzip2 gnupg zlib1g-dev file jq vim \
    && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

# Stop container's bash from leaving .bash_histories everywhere and add convenience aliases for interactive use
RUN echo "unset HISTFILE" >>/etc/bash.bashrc && \
    echo "alias ls='ls --color=auto' l='ls -CF' la='l -a' ll='l -l' lla='ll -a'" >>/etc/bash.bashrc

# system-wide set strict priority
RUN conda config --system --set channel_priority strict

# we install in root (weird but makes rules with mounts work)
WORKDIR /

# install the setup
COPY envs envs
COPY rules rules
COPY test test
COPY Snakefile .

# install our Snakemake core straight in base (so conda activate needed by end user)
RUN conda env update -n base -f envs/hamronization_workflow.yaml

# make Snakemake install all conda environments (but not the non-conda binary deps or databases)
RUN snakemake --configfile test/test_config.yaml --use-conda --jobs 1 --conda-create-envs-only

# make Snakemake install the the non-conda binary deps (but not the databases)
RUN snakemake --configfile test/test_config.yaml --use-conda --jobs 1 bindeps/resistomeanalyzer/resistome bindeps/rarefactionanalyzer/rarefaction bindeps/snpfinder/snpfinder

# this maiden run pulls all databases in, thus finalising the self-contained image
RUN snakemake --configfile test/test_config.yaml --use-conda --jobs 1 && \
    rm -rf results
