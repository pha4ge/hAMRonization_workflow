import pandas as pd
import os
shell.executable("bash")

workdir: os.getcwd()

samples = pd.read_table(config["samples"], index_col="biosample", sep="\t")
samples.index = samples.index.astype('str', copy=False) # in case samples are integers, need to convert them to str

amrplusplus_exts = ["snp.tsv", "gene.tsv", "mech.tsv", "group.tsv", "class.tsv"]

def _get_seq(wildcards,seqs):
    return samples.loc[(wildcards.sample), [seqs]].dropna()[0]

def _get_seqdir(wildcards):
    return os.path.dirname(samples.loc[(wildcards.sample), ["assembly"]].dropna()[0])

rule all:
    input:
        expand("results/{sample}/amrplusplus/{amrplusplus_outputs}", sample=samples.index, amrplusplus_outputs=amrplusplus_exts),
        expand("results/{sample}/rgi/rgi.json", sample=samples.index),
        expand("results/{sample}/rgibwt/rgibwt.gene_mapping_data.txt", sample=samples.index),
        expand("results/{sample}/staramr/resfinder.tsv", sample=samples.index),
        expand("results/{sample}/ariba/report.tsv", sample=samples.index),
        expand("results/{sample}/abricate/report.tsv", sample=samples.index),
        expand("results/{sample}/amrfinderplus/report.tsv", sample=samples.index),
        expand("results/{sample}/groot/report.tsv", sample=samples.index),
        expand("results/{sample}/resfams/resfams.tblout", sample=samples.index),
        expand("results/{sample}/resfinder/data_resfinder.json", sample=samples.index),
        expand("results/{sample}/srax/sraX_analysis.html", sample=samples.index),
        expand("results/{sample}/csstar/report.tsv", sample=samples.index),
        expand("results/{sample}/kmerresistance/results.KmerRes", sample=samples.index),
        expand("results/{sample}/deeparg/output.mapping.ARG", sample=samples.index),
        expand("results/{sample}/srst2/srst2__fullgenes__ARGannot__results.txt", sample=samples.index),
        #expand("results/{sample}/mykrobe/report.json", sample=samples.index), need variant spec to use
        #expand("results/{sample}/pointfinder/report.tsv", sample=samples.index), need variant spec to use

include: "rules/srst2.smk" 
include: "rules/deeparg.smk"
include: "rules/abricate.smk"
include: "rules/amrfinderplus.smk"
include: "rules/ariba.smk"
include: "rules/groot.smk"
include: "rules/rgi.smk"
include: "rules/rgi_bwt.smk"
include: "rules/staramr.smk"
include: "rules/resfams.smk"
include: "rules/resfinder.smk" 
include: "rules/kmerresistance.smk" 
include: "rules/srax.smk" 
include: "rules/amrplusplus.smk"
include: "rules/csstar.smk"
#include: "rules/mykrobe.smk"
#include: "rules/pointfinder.smk"
