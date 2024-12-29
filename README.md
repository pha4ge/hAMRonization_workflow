# hAMRonization workflow

## Description

hAMRonization is a project aiming at the harmonization of output file formats of antimicrobial resistance detection tools.
This is a workflow acting as a proof of concept test-case for the [hAMRonization](https://github.com/pha4ge/hAMRonization) parsers.

Specifically, this runs a set of AMR gene detection tools against a set of contigs/reads and uses `hAMRonization` to collate the results in a single unified report.

The following tools are currently included:
* abricate
* AMRFinderPlus
* ariba
* Groot
* RGI (for complete and draft genomes)
* RGI BWT (for metagenomes)
* staramr
* resfams
* staramr
* Resfinder (including PointFinder)
* sraX
* DeepARG (requires singularity)
* CSSTAR
* AMRplusplus
* SRST2
* KmerResistance

Excluded tools:
* mykrobe (needs variant specification to be parseable)
* SEAR, ARG-ANNOT (no longer downloadable)
* RAST/PATRIC (not easily runnable on CLI)
* Single organism/or resistance tools (e.g. Kleborate, LREfinder, SSCmec Finder, U-CARE, ARGO)
* shortBRED, ARGS-OAP (rely on usearch which isn't open-source)

## Installation

Installation from source requires Conda or Miniconda to be installed.

> Note: if you have Docker, Podman or Singularity, then the pre-built Docker container (see [below](#docker)) may be the easier way to go.

Install prerequisites for building this pipeline (on Ubuntu):

    sudo apt install build-essential git zlib1g-dev curl wget file unzip jq

You need Singularity if you want to run `DeepARG`:

    sudo apt install singularity-container

Clone this repository:

    git clone https://github.com/pha4ge/hAMRonization_workflow

Create the Conda environment:

    cd hAMRonization_workflow
    conda env create -n hamronization_workflow --file envs/hamronization_workflow.yaml

Run a smoke test (note this takes a while as Snakemake pulls in all the tools and databases upon its first run):

    ./run_test.sh

Running it again should seconds and report "Nothing to be done"

## Running

To execute the pipeline with your isolates, navigate to the cloned repository and edit or copy the provided configuration file (`config/config.yaml`) and isolate list (`config/isolate_list.tsv`).

Remember to activate the Conda environment:

    conda activate hamronization_workflow

Run the configured workflow (change the job count according to your compute capacity, omit the singularity args if you don't have Singularity):

    snakemake --configfile config/config.yaml --use-conda --jobs 2 --use-singularity --singularity-args "-B $PWD:/data"

Docker
------

Alternatively, the workflow can be run using Docker (and probably Podman and Singularity).  Given the collective quirks of the bundled tools this will probably be easier for most users.

Because DeepARG runs as a container inside the Docker container, the Docker container must be run with `docker run --privileged`.

If you are unable to run docker in privileged mode then you can just comment out the deeparg targets in the main `Snakefile`.

First get the docker container:

    docker pull finlaymaguire/hamronization:1.0.1

You can execute it in a couple of ways but the easiest is to just mount the folder containing your reads and run it interactively:

    docker run -it --privileged -v $HOST_FOLDER_CONTAINING_ISOLATES:/data finlaymaguire/hamronization:1.0.1 /bin/bash

If our isolate data is in `~/isolates` the command to interactively run this container and get a bash terminal would be:

    docker run -it --privileged -v ~/isolates:/data finlaymaguire/hamronization:1.0.1 /bin/bash

Then point your `sample_table.tsv` to that folder, entries for this example would be:

```
species biosample       assembly        read1   read2
Mycobacterium tuberculosis      SAMN02599008    /data/SAMN02599008/GCF_000662585.1.fna  /data/SAMN02599008/SRR1180160_R1.fastq.gz       /data/SAMN02599008/SRR1180160_R2.fastq.gz
Mycobacterium tuberculosis      SAMN02599009    /data/SAMN02599009/GCF_000662586.1.fna  /data/SAMN02599009/SRR1180161_R1.fastq.gz       /data/SAMN02599009/SRR1180161_R2.fastq.gz
```

Then specify your `config.yaml` to use this `sample_table.tsv` and execute the pipeline from bash in the container by activating the top-level environment:

    conda activate hamronization_workflow

Then the workflow:

    snakemake --configfile config/config.yaml --use-conda --cores 6 --use-singularity --singularity-args "-B $PWD:/data"

*WARNING* You will have to extract your results folder (e.g. `cp results /data` for the example mounted volume) from the container if you wish to use them elsewhere.

Note: kma/kmerresistance fails without explanation in the container (possibly zlib related, although adding the zlib headers didn't solve this). It is commented out for now.


Initial Run
-----------

### Run Data

Following datasets are currently used for result file generation:
```
organism    Biosample   Assembly    Run
Salmonella enterica SAMN13012778    GCA_009009245.1 SRR10258315
Salmonella enterica SAMN13064234    GCA_009239915.1 SRR10313698
Salmonella enterica SAMN10872197    GCA_007657735.1 SRR8528923
Salmonella enterica SAMN13064249    GCA_009239785.1 SRR10313716
Salmonella enterica SAMN07255713    GCA_009439415.1 SRR5921214
Salmonella enterica SAMN03098832    GCA_006629605.1 SRR1616829
Klebsiella pneumoniae   SAMN02927805    GCA_004302785.1 SRR1561295
Salmonella enterica SAMEA6058467    GCA_009625195.1 ERR3581801
E. coli SAMN05980528    GCA_004268245.1 SRR4897319
Mycobacterium tuberculosis  SAMN02599008    GCA_000662585.1 SRR1182980 SRR1180160
Mycobacterium tuberculosis  SAMN02599179    GCA_000665745.1 SRR1172848 SRR1172873
Mycobacterium tuberculosis  SAMN02599095    GCA_000706105.1 SRR1173728 SRR1173217
Mycobacterium tuberculosis  SAMN02599061    GCA_000663625.1 SRR1175151 SRR1172938
Mycobacterium tuberculosis  SAMN02598983    GCA_000654735.1 SRR1174279 SRR1173257
```
Links to data and corresponding metadata need to be stored in a tab separated sample sheet with the following columns:
`species biosample       assembly        reads   read1   read2`


### Results

The results generated on the aforementioned datasets can be retrieved [here](https://databay.bfrlab.de/d/c937ce66a7f2406e9a0f/).

Contact
-------
Please consult the [PHA4GE project website](https://github.com/pha4ge) for questions.

For technical questions, please feel free to consult:
 * Finlay Maguire <finlaymaguire (at) gmail.com>
 * Simon H. Tausch <Simon.Tausch (at) bfr.bund.de>

