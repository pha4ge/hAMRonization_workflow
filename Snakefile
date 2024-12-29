import pandas as pd
import os
import re
shell.executable("bash")

# Samples Table ---

# Read the samples TSV verbatim into an all-strings dataframe
# - Empty lines and comment lines are skipped
# - Empty cells yield zero-length strings (no NaN or NA weirdness)
# - Lenienty skip spaces that start a cell value
# - The 'biosample' index column must be unique (checked below)
# - The 'usecols' array lists our required columns (others are ignored)

samples = pd.read_table(config['samples'], index_col="biosample",
    dtype='str', na_filter=False, comment='#', skipinitialspace=True,
    usecols=['biosample', 'species', 'assembly', 'read1', 'read2'])

# Sanity checks on the samples table: biosample index must be unique and non-empty
if not all(map(len, samples.index)) or samples.index.size != samples.index.unique().size:
    raise Exception("Every sample must have a unique 'biosample' identfier in {}".format(config['samples']))

# Check that biosample has no characters that break things (like '/')
pat = re.compile(r"^[\w.@:=-]+$")
if not all(map(lambda id: re.match(pat, id), samples.index)):
    raise Exception("Biosample IDs must not contain spaces or punctuation other than: . @ : = - _")

# Sample Lists ---

# Some tools run on assemblies, others on read pairs.  Here we define
# lists of indices (= biosample IDs) of samples that have an assembly
# and/or a read pair, to be used in the 'expand' definitions below.

samples_with_assembly = samples[samples.assembly != ''].index
samples_with_readpair = samples[samples.read2 != ''].index
samples_with_either = samples[samples.assembly + samples.read2 != ''].index

# Input Helpers ---

# Functions to retrieve column values from the samples table
# - All these use the {sample} variable in the wildcards that Snakemake passes in
# - All return empty string when the value is absent so can be used as boolean tests

get_species = lambda w: samples.loc[w.sample].species
get_assembly = lambda w: samples.loc[w.sample].assembly
get_read1 = lambda w: samples.loc[w.sample].read1
get_read2 = lambda w: samples.loc[w.sample].read2

# Convenience functions for tools that are can take both reads and assemblies
# - All functions return empty list when they find nothing, thus can be used as tests

get_reads = lambda w: list(filter(None, [get_read1(w), get_read2(w)]))
get_reads_or_assembly = lambda w: get_reads(w) or list(filter(None, [get_assembly(w)]))
get_assembly_or_reads = lambda w: list(filter(None, [get_assembly(w)])) or get_reads(w)

# Report whether we have Singularity (or at least workflow runs with --singularity-args)
use_singularity = lambda w: workflow.deployment_settings.apptainer_args is not None

# Target rules ---

rule all:
    input:
        "results/hamronized_report.tsv",
        "results/hamronized_report.json",
        "results/hamronized_report.html"

rule summarize_all:
    output:
        tsv = "results/hamronized_report.tsv",
        json = "results/hamronized_report.json",
        html = "results/hamronized_report.html"
    input:
        expand("results/{sample}/{sample}_hamronized.tsv", sample=samples_with_either),
    conda:
        "envs/hamronization.yaml"
    shell:
        """
        hamronize summarize -t tsv -o {output.tsv} {input}
        hamronize summarize -t json -o {output.json} {input}
        hamronize summarize -t interactive -o {output.html} {input}
        """

rule summarize_sample:
    output:
        tsv = "results/{sample}/{sample}_hamronized.tsv",
        json = "results/{sample}/{sample}_hamronized.json",
        html = "results/{sample}/{sample}_hamronized.html"
    input:
        expand("results/{sample}/abricate/hamronized_report.tsv", sample=samples_with_assembly),
        expand("results/{sample}/amrfinderplus/hamronized_report.tsv", sample=samples_with_assembly),
        expand("results/{sample}/amrplusplus/hamronized_report.tsv", sample=samples_with_readpair),
        expand("results/{sample}/ariba/hamronized_report.tsv", sample=samples_with_readpair),
        expand("results/{sample}/csstar/hamronized_report.tsv", sample=samples_with_assembly),
        branch(use_singularity, then=expand("results/{sample}/deeparg/hamronized_report.tsv", sample=samples_with_readpair)),
        expand("results/{sample}/groot/hamronized_report.tsv", sample=samples_with_readpair),
        expand("results/{sample}/kmerresistance/hamronized_report.tsv", sample=samples_with_readpair),
#       expand("results/{sample}/mykrobe/hamronized_report.json", sample=samples_with_readpair),
        expand("results/{sample}/resfams/hamronized_report.tsv", sample=samples_with_assembly),
        expand("results/{sample}/resfinder-fna/hamronized_report.tsv", sample=samples_with_assembly),
        expand("results/{sample}/resfinder-fqs/hamronized_report.tsv", sample=samples_with_readpair),
        expand("results/{sample}/rgi/hamronized_report.tsv", sample=samples_with_assembly),
        expand("results/{sample}/rgibwt/hamronized_report.tsv", sample=samples_with_readpair),
        expand("results/{sample}/srax/hamronized_report.tsv", sample=samples_with_assembly),
        expand("results/{sample}/staramr/hamronized_report.tsv", sample=samples_with_assembly),
        expand("results/{sample}/srst2/hamronized_report.tsv", sample=samples_with_readpair)
    conda:
        "envs/hamronization.yaml"
    shell:
        """
        hamronize summarize -t tsv -o {output.tsv} {input}
        hamronize summarize -t json -o {output.json} {input}
        hamronize summarize -t interactive -o {output.html} {input}
        """

include: "rules/abricate.smk"
include: "rules/amrfinderplus.smk"
include: "rules/amrplusplus.smk"
include: "rules/ariba.smk"
include: "rules/csstar.smk"
include: "rules/deeparg.smk"
include: "rules/groot.smk"
include: "rules/kmerresistance.smk"
#include: "rules/mykrobe.smk"
include: "rules/resfams.smk"
include: "rules/resfinder.smk"
include: "rules/rgi.smk"
include: "rules/rgi_bwt.smk"
include: "rules/srax.smk"
include: "rules/srst2.smk"
include: "rules/staramr.smk"

