# base image 
FROM continuumio/miniconda

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

# get some system essentials
RUN apt-get update && apt-get install -y --no-install-recommends curl wget git build-essential squashfs-tools libtool autotools-dev automake autoconf libarchive-dev bzip2 unzip

# install singularity
RUN export VERSION=3.5.3 && \
    wget https://github.com/hpcng/singularity/releases/download/$VERSION/singularity-$VERSION.tar.gz && \
    tar xvf singularity-$VERSION.tar.gz && \
    cd singularity-$VERSION && \
    ./configure --prefix=/usr/local && make && make install

# clone the repo
RUN git clone https://github.com/pha4ge/hamronization

# build the run environment
WORKDIR /hamronization
RUN bash run_test.sh
#RUN conda run -n hamronization snakemake --configfile config/test_config.yaml --use-conda --jobs 1 --use-singularity --singularity-args "-B $PWD:/data"
