import pandas as pd
import os
shell.executable("bash")

# Samples Table ---

# Read the samples TSV verbatim into an all-strings dataframe
# - Empty lines and comment lines are skipped
# - Empty cells yield zero-length strings (no NaN or NA weirdness)
# - Lenienty skip spaces that start a cell value
# - The 'biosample' index column must be unique (checked below)
# - The 'usecols' array lists our required columns (others are ignored),
#   and enforces that every row has a (possibly empty) value for each
samples = pd.read_table(config['samples'], index_col="biosample",
    dtype='str', na_filter=False, comment='#', skipinitialspace=True,
    usecols=['biosample', 'species', 'assembly', 'read1', 'read2'])

# Sanity checks on the samples table: biosample index must be unique and non-empty
if not all(map(len, samples.index)) or samples.index.size != samples.index.unique().size:
    raise Exception("Every sample must have a unique 'biosample' identfier in {}".format(config['samples']))

# Input Helpers ---

# Define functions to retrieve column values from the samples table
# - All these use the {sample} variable in the wildcards that Snakemake
#   passes in to index into the rows of the samples table
# - All return empty string when the value is absent, which evaluates to False,
#   so can be conveniently used as condition in Snakemake's "branch" function
get_species = lambda w: samples.loc[w.sample].species
get_assembly = lambda w: samples.loc[w.sample].assembly
get_read1 = lambda w: samples.loc[w.sample].read1
get_read2 = lambda w: samples.loc[w.sample].read2

# Define functions for tools that can take either reads or assemblies
# - All functions return empty list when they find nothing, which evals to False,
#   so can be used as the condition in Snakemake's "branch" function
get_reads = lambda w: list(filter(None, [get_read1(w), get_read2(w)]))
get_reads_or_assembly = lambda w: get_reads(w) or list(filter(None, [get_assembly(w)]))
get_assembly_or_reads = lambda w: list(filter(None, [get_assembly(w)])) or get_reads(w)

# Config Helpers ---

# Report whether we have Singularity (or at least workflow runs with --singularity-args)
use_singularity = lambda w: workflow.deployment_settings.apptainer_args is not None

# Target rules ---

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
        branch(use_singularity, then=expand("results/{sample}/deeparg/hamronized_report.tsv", sample=samples.index)),
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

