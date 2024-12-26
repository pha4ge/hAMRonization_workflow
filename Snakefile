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

def _get_deeparg():
	results = []

	if hasattr(workflow, 'use_singularity') and workflow.use_singularity:
		results = expand("results/{sample}/deeparg/hamronized_report.tsv", sample=samples.index),
	
	return results

rule all:
    input:
        "results/all_hamronized_results.tsv",
        "results/contig_only_hamronized_summary.html"

rule generate_interactive_contig_only_report:
    input:
        expand("results/{sample}/abricate/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/staramr/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/amrfinderplus/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/srax/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/csstar/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/resfinder/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/rgi/hamronized_report.tsv", sample=samples.index),
    output:
        "results/contig_only_hamronized_summary.html"
    conda:
        "envs/hamronization.yaml"
    shell:
        """
        hamronize summarize -t interactive -o {output} {input}
        """

rule hamronize:
    input:
        expand("results/{sample}/staramr/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/ariba/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/abricate/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/amrfinderplus/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/groot/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/resfams/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/srax/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/csstar/hamronized_report.tsv", sample=samples.index),
#        expand("results/{sample}/deeparg/hamronized_report.tsv", sample=samples.index),
        _get_deeparg(),
        expand("results/{sample}/kmerresistance/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/resfinder/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/rgi/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/rgibwt/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/amrplusplus/hamronized_report.tsv", sample=samples.index),
        expand("results/{sample}/srst2/hamronized_report.tsv", sample=samples.index)
        #expand("results/{sample}/mykrobe/report.json", sample=samples.index), need variant spec to use
        #expand("results/{sample}/pointfinder/report.tsv", sample=samples.index), need variant spec to use
    output:
        "results/all_hamronized_results.tsv"
    conda:
        "envs/hamronization.yaml"
    shell:
        """
        hamronize summarize -o {output} -t tsv {input}
        """

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

