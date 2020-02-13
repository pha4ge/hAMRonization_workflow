#!/bin/bash
# stop on errors
set -o errexit

# install blast, ariba, groot in a conda environment to prepare those databases
#conda create -y -n db_install -c bioconda blast ariba groot

# get abricate ncbi db
mkdir -p ncbi
curl https://raw.githubusercontent.com/tseemann/abricate/35f5ea86fce565dd6861f79cbc578b7cc4c3d604/db/ncbi/sequences --output ncbi/sequences
makeblastdb -in ncbi/sequences -title ncbi -dbtype nucl 

# get resfinder for srst2
curl https://raw.githubusercontent.com/katholt/srst2/fe027e55848318e2bec8a32ceea32dcfc94728fa/data/ResFinder.fasta --output ResFinder.fasta

# get and prepare ariba db
ariba getref card ariba_card
ariba prepareref -f ariba_card.fa -m ariba_card.tsv ariba_card.prepareref 

# get amrfinder database
mkdir -p amrfinder2020-01-22.1
wget -nH --cut-dirs=6 -P amrfinder2020-01-22.1 --ftp-password="AMRFinder@ncbi" --ftp-user="anonymous" -m ftp://ftp.ncbi.nlm.nih.gov/pathogen/Antimicrobial_resistance/AMRFinderPlus/database/3.6/2020-01-22.1/ 

# get groot index
groot get
groot index -i arg-annot.90 -o groot-index-100 -l 100
#groot index -i arg-annot.90 -o groot-index-250 -l 250

# get rgi database
mkdir -p card
curl https://card.mcmaster.ca/download/0/broadstreet-v3.0.7.tar.gz --output card/card.tar.gz
tar -C card -xvf card/card.tar.gz

# get resfams
curl http://dantaslab.wustl.edu/resfams/Resfams-full.hmm.gz | gunzip > Resfams-full.hmm
