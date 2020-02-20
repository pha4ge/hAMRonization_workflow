import pandas as pd
import os
shell.executable("bash")

workdir: os.getcwd()

samples = pd.read_table(config["samples"], index_col="biosample", sep="\t")
samples.index = samples.index.astype('str', copy=False) # in case samples are integers, need to convert them to str

def _get_seq(wildcards,seqs):
    return samples.loc[(wildcards.sample), [seqs]].dropna()[0]

def _get_seqdir(wildcards):
    return os.path.dirname(samples.loc[(wildcards.sample), ["assembly"]].dropna()[0])

rule all:
    input:
        "pipeline_finished.txt"

rule cleanup:
    input:
        #expand("results/{sample}/rgi/rgi.json", sample=samples.index),
        #expand("results/{sample}/staramr/resfinder.tsv", sample=samples.index),
        #expand("results/{sample}/ariba/report.tsv", sample=samples.index),
        #expand("results/{sample}/abricate/report.tsv", sample=samples.index),
        #expand("results/{sample}/amrfinder/report.tsv", sample=samples.index),
        #expand("results/{sample}/srst2/srst2__fullgenes__ResFinder__results.txt", sample=samples.index),
        #expand("results/{sample}/groot/report.tsv", sample=samples.index),
        #expand("results/{sample}/resfams/resfams.tblout", sample=samples.index),
        #expand("results/{sample}/mykrobe/report.json", sample=samples.index)
        expand("results/{sample}/resfinder/data_resfinder.json", sample=samples.index),
        expand("results/{sample}/kmerresistance/results.KmerRes", sample=samples.index),
        expand("results/{sample}/srax/Results/sraX_analysis.html", sample=samples.index)
    output:
        "pipeline_finished.txt"
    shell:
        """
        rm -r results/*/staramr/hits/ results/*/ariba/*.gz results/*/srst2/*.bam results/*/srst2/*.pileup || echo "tempfiles already absent"
        touch pipeline_finished.txt
        """

#include: "rules/abricate.smk"
#include: "rules/amrfinder.smk"
#include: "rules/ariba.smk"
#include: "rules/groot.smk"
#include: "rules/mykrobe.smk"
#include: "rules/rgi.smk"
#include: "rules/srst2.smk" 
#include: "rules/staramr.smk"
#include: "rules/resfams.smk"
include: "rules/resfinder.smk" 
include: "rules/kmerresistance.smk" 
include: "rules/srax.smk" 
