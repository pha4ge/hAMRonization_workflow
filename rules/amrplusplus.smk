rule run_amrplusplus:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2'),
    output:
        amr_class = "results/{sample}/amrplusplus/class.tsv",
        amr_gene  = "results/{sample}/amrplusplus/gene.tsv",
        amr_snps  = "results/{sample}/amrplusplus/snp.tsv",
        amr_group = "results/{sample}/amrplusplus/group.tsv",
        amr_mech  = "results/{sample}/amrplusplus/mech.tsv"
    log:
       "logs/amrplusplus_{sample}.log"
    message: 
        "Running rule run_amrplusplus on {wildcards.sample} with reads"
    conda:
      "../envs/amrplusplus.yaml"
    threads:
       config["params"]["threads"]
    params:
        refdb = config["params"]['amrplusplus']['refdb'],
        annots = config["params"]['amrplusplus']['annots'],
        resistome_tool = config["params"]["amrplusplus"]["resistome_tool"],
        rarefaction_tool = config["params"]["amrplusplus"]["rarefaction_tool"],
        snp_tool = config["params"]["amrplusplus"]["snp_tool"]
    shell:
       """
       mkdir -p tmp
       trimmomatic PE  {input.read1} {input.read2} tmp/{wildcards.sample}_r1_pe_trimmed.fq tmp/{wildcards.sample}_r1_se_trimmed.fq tmp/{wildcards.sample}_r2_pe_trimmed.fq tmp/{wildcards.sample}_r2_se_trimmed.fq SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:36 2> >(tee {log} >&2)
       rm tmp/{wildcards.sample}_r1_se_trimmed.fq tmp/{wildcards.sample}_r2_se_trimmed.fq
       bwa mem {params.refdb} tmp/{wildcards.sample}_r1_pe_trimmed.fq tmp/{wildcards.sample}_r2_pe_trimmed.fq | samtools sort -n -O sam > tmp/{wildcards.sample}.sam 2> >(tee -a {log} >&2)
       {params.resistome_tool} -ref_fp {params.refdb} -annot_fp {params.annots} -sam_fp tmp/{wildcards.sample}.sam -gene_fp {output.amr_gene} -group_fp {output.amr_group} -class_fp {output.amr_class} -mech_fp {output.amr_mech} -t 80 2> >(tee -a {log} >&2)
       {params.rarefaction_tool} -ref_fp {params.refdb} -annot_fp {params.annots} -sam_fp tmp/{wildcards.sample}.sam -gene_fp {output.amr_gene}_rare -group_fp {output.amr_group}_rare -class_fp {output.amr_class}_rare -mech_fp {output.amr_mech}_rare -min 5 -max 100 -skip 5 -samples 1 -t 80 2> >(tee -a {log} >&2)
       {params.snp_tool} -amr_fp {params.refdb} -sampe tmp/{wildcards.sample}.sam -out_fp {output.amr_snps} 2> >(tee -a {log} >&2)
       """
