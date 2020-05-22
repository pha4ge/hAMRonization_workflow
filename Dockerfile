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
RUN apt-get update && apt-get install -y --no-install-recommends curl wget git build-essential squashfs-tools libtool autotools-dev automake autoconf libarchive-dev bzip2

# add conda 
#RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda.sh && \
#    /bin/bash /miniconda.sh -b -p /opt/conda && \
#        rm /miniconda.sh && \
#       /opt/conda/bin/conda clean -tipsy && \
#       ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#       echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#       echo "conda activate base" >> ~/.bashrc && conda init bash
# install singularity
RUN export VERSION=2.5.2 && \
    wget https://github.com/singularityware/singularity/releases/download/$VERSION/singularity-$VERSION.tar.gz && \
    tar xvf singularity-$VERSION.tar.gz && \
    cd singularity-$VERSION && \
    ./configure --prefix=/usr/local && make && make install

# clone the repo
RUN git clone https://github.com/pha4ge/hamronization

# create the db conda env
RUN conda create -n db -y -c bioconda blast ariba=2.14.4=py36he1b5a44_0 groot=0.8.3=1 ncbi-amrfinderplus=3.6.10=hf18293b_0 bwa kma unzip 

# get and format datatabses
WORKDIR /hamronization/data/dbs
RUN conda run -n db bash get_dbs.sh

# get and format test data
WORKDIR /hamronization/data/test
RUN conda run -n db bash get_test_data.sh

# build the run environment
RUN conda create -n hamronization -y -c bioconda -c conda-forge snakemake kma bwa 

# install non-conda deps
WORKDIR /hamronization/data/non_conda_deps
RUN conda run -n hamronization bash install_non_conda_deps.sh

# run workflow on test data
WORKDIR /hamronization
RUN conda run -n hamronization snakemake --configfile config/test_config.yaml --use-conda --jobs 1 --use-singularity --singularity-args "-B $PWD:/data"
