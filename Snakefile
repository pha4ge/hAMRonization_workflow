import pandas as pd
shell.executable("bash")

workdir: config["workdir"]

samples = pd.read_table(config["samples"], index_col="biosample", sep="\t")
samples.index = samples.index.astype('str', copy=False) # in case samples are integers, need to convert them to str

def _get_seq(wildcards,seqs):
    return samples.loc[(wildcards.sample), [seqs]].dropna()[0]

rule all:
    input:
        expand("results/{sample}/amrfinder/report.tsv", sample=samples.index),
        #expand("results/{sample}/ariba/report.tsv", sample=samples.index),
        #expand("results/{sample}/abricate/report.tsv", sample=samples.index),
        #expand("results/{sample}/srst2/srst2__fullgenes__ResFinder__results.txt", sample=samples.index)

include: "rules/abricate.smk"
include: "rules/amrfinder.smk"
include: "rules/ariba.smk"
include: "rules/groot.smk"
include: "rules/resfinder.smk"
include: "rules/rgi.smk"
include: "rules/srst2.smk"
include: "rules/staramr.smk"


