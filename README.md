hAMRonization - Harmonization of output file formats of antimicrobial resistance detection tools 
=======================================
Description
-----------
hAMRonization is a project aiming at the harmonizatino of output file formats of antimicrobial resistance detection tools. 
The selected AMR detection tools are currently included (scored out tools are in development):
* abricate
* AMRfinder
* ariba
* Groot
* RGI
* SRST2
* staramr
* mykrobe
* resfams
* staramr
* ~~ReMatCh~~ 
* ~~Resfinder~~ 
* ~~KmerResistance~~
* ~~DeepARG~~
* ~~sraX~~
* ~~pointfinder~~ 
* ~~ARGS-OAP~~
* ~~SSTAR~~
* ~~SEAR~~
* ~~shortBRED~~
* ~~AMRplusplus~~

Not included:

* ARG-ANNOT (no longer downloadable)
* RAST (not easily runnable on CLI)
* PATRIC (not easily runnable on CLI)
* Single organism/or resistance tools (e.g. LREfinder, SSCmec Finder, U-CARE, ARGO)

To generate comparable result files, all tools are being run in a Snakemake pipeline installing fixed versions of the tools from conda on execution.

Installation 
------------

This pipeline depends on Snakemake and Conda. If you have conda installed, please run 

`conda create --name hamronization snakemake` 

and 

`conda activate hamronization`

Afterwards, clone this repository:

`git clone https://github.com/pha4ge/hAMRonization.git`

All further dependencies will be installed via conda on execution.

Databases can be downloaded by going to the `data/dbs` directory and running:

`bash get_dbs.sh`

Execution
---------

To execute the pipeline, go to the main folder of the cloned repository, adapt the sample sheet as well as the config file to your needs and call with the number of jobs you want to run.

`snakemake --configfile config/config.yaml --use-conda --jobs 2`


Testing
-------

If you want to test the pipeline locally on a single TB isolate you can use the
`run_test.sh` script to create a clean conda instance, download the dbs, and download
the test data. 

If you've already downloaded the test data you can just run to execute the pipeline:

`snakemake --configfile config/test_config.yaml --use-conda --jobs 2`


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
 * Simon H. Tausch <Simon.Tausch (at) bfr.bund.de> 
 * Finlay Maguire <finlaymaguire (at) gmail.com> 
 

