# base image 
FROM continuumio/miniconda3

# metadata
LABEL base.image="miniconda3"
LABEL version="1"
LABEL software="hAMRonization"
LABEL software.version="1.0.0"
LABEL description="Workflow for running many AMR tools on a set of reads/contigs"
LABEL website="https://github.com/pha4ge/hamronization"
LABEL documentation="https://github.com/pha4ge/hamronization/README.md"
LABEL license="https://github.com/pha4ge/hamronization/LICENSE"
LABEL tags="Genomics"

# maintainer
MAINTAINER Finlay Maguire <finlaymaguire@gmail.com>

# set shell so conda works properly
SHELL ["/bin/bash", "-c"]

# get some system essentials
RUN apt-get update && apt-get install -y --no-install-recommends curl wget git build-essential libtool autotools-dev automake autoconf libarchive-dev bzip2 unzip libseccomp-dev pkg-config squashfs-tools cryptsetup libssl-dev uuid-dev gnupg zlib1g-dev

# install golang for singularity
RUN wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.14.4.linux-amd64.tar.gz 

# install singularity
RUN export PATH=$PATH:/usr/local/go/bin && \
    export VERSION=3.5.3 && \
    wget https://github.com/hpcng/singularity/releases/download/v$VERSION/singularity-$VERSION.tar.gz && \
    tar xvf singularity-$VERSION.tar.gz && \
    cd singularity && \
    ./mconfig && cd ./builddir && make && make install

# clone the repo
RUN git clone https://github.com/pha4ge/hamronization

# get the test data
WORKDIR /hamronization
RUN cd data/test && bash get_test_data.sh && cd ../..

# build the run env
RUN conda init bash && conda env create -n hamronization --file envs/hamronization.yaml

# install the snakemake envs
RUN source ~/.bashrc && conda activate hamronization && snakemake --configfile config/test_config.yaml --use-conda --conda-create-envs-only --jobs 1 --use-singularity --singularity-args "-B $PWD:/data"

# run on test data (needs docker run --privileged so can't be done at build)
# RUN source ~/.bashrc && conda activate hamronization && snakemake --configfile config/test_config.yaml --use-conda --jobs 1 --use-singularity --singularity-args "-B $PWD:/data"
