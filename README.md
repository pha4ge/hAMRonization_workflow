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
* DeepARG
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

Clone this repository:

    git clone https://github.com/pha4ge/hAMRonization_workflow

Create the Conda environment:

    cd hAMRonization_workflow
    conda env create -n hamronization_workflow --file envs/hamronization_workflow.yaml

This may considerably speed up conda environment creation and create a more predictable outcome

    conda activate hamronization_workflow
    conda config --env --set channel_priority strict

Run a smoke test (note this takes a while as Snakemake pulls in all the tools and databases upon its first run):

    ./run_test.sh

Running it again should seconds and report "Nothing to be done"

## Running

To execute the pipeline with your isolates, navigate to the cloned repository and edit or copy the provided configuration file (`config/config.yaml`) and isolate list (`config/isolate_list.tsv`).

Remember to activate the Conda environment:

    conda activate hamronization_workflow

Run the configured workflow (change the job count according to your compute capacity):

    snakemake --configfile config/config.yaml --use-conda --jobs 2

Docker / Podman / Singularity
-----------------------------

**NOTE the Docker container for the latest version of hAMRonization is not yet available for download but a build script is available in the `docker` directory.**

Alternatively, the workflow can be run using a pre-built OCI image that contains all the tools and their databases.  Given the collective quirks of the bundled tools this is probably easier for most users.

To get the container (replace `docker` by `podman`, `singularity`, or `apptainer` if that is what you use):

    docker pull docker://finlaymaguire/hamronization_workflow:1.1.0

To run the workflow on your isolates, the container needs access to (1a) a workflow configuration (`config.yaml`) and (1b) isolate list (`isolates.tsv`), (2) the actual data (FASTA/FASTQ files), and (3) a `results` directory to write the its output in. (A `logs` directory in case things fail will also be helpful.)

We suggest starting with this setup:

 * Create a new empty directory which will serve as your workspace
 * Inside the workspace create four directories: `config`, `inputs`, `results`, and `logs`
 * Copy your FASTA/FASTQ files into the `inputs` directory (possibly organised in subdirectories)
 * In the `config` directory create a file `isolates.tsv` (take `../test/test_data.tsv` as an example)
 * In `config/isolates.tsv` add a line for each isolate and (this is the important bit) _make sure their file paths start with `inputs/`_ because this is where the container will see them.
 * In the `config` directory create a file `config.yaml` (again take `../test/test_config.yaml` as an example)
 * In `config/config.yaml` change _only one setting_: `samples: "config/isolates.tsv"` (again, this is where the container will see the isolates file).

You are ready to run the container.  While in the workspace directory:

    # Works identically for podman (just use 'podman' instead of 'docker')
    docker run -ti --rm --tmpfs /.cache --tmpfs /tmp --tmpfs /run \
        -v $PWD/inputs:/inputs:ro -v $PWD/config:/config:ro -v $PWD/results:/results -v $PWD/tlogs:/logs \
        run finlaymaguire/hamronization_workflow:1.1.0 \
        snakemake --configfile config/config.yaml --use-conda --cores 6

    # Singularity/apptainer makes life easy: no hassle with mounts!
    ./hamronization_workflow.sif snakemake --configfile config/config.yaml --use-conda --cores 6

If the workflow runs successfully, results will be in `./results`.  In case of an error, check the most recent file in `./logs`.

You are not bound to the above setup: you can mount any host directory in the container, at any mountpoint you like **except for the output directory which must be mounted at `/results`**.  (If you don't mount anything on `/results`, the results get written _inside_ the container.)  Just remember that the file paths in your isolate list are interpreted from _within_ the container (and relative to `/`).


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

