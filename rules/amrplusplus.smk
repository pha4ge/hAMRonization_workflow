rule get_amrplusplus_db:
    output: 
        megares_db = os.path.join(config["params"]["db_dir"], "megares", "megares_full_database_v2.00.fasta"),
        megares_annot = os.path.join(config["params"]["db_dir"], "megares", "megares_full_annotations_v2.00.csv")
    params:
        db_dir = os.path.join(config["params"]["db_dir"], "megares")
    conda:
      "../envs/amrplusplus.yaml"
    shell:
        """
        mkdir -p {params.db_dir}
        wget -O {output.megares_db} http://megares.meglab.org/download/megares_v2.00/megares_full_database_v2.00.fasta
        wget -O {output.megares_annot} http://megares.meglab.org/download/megares_v2.00/megares_full_annotations_v2.00.csv
        cd {params.db_dir}
        bwa index megares_full_database_v2.00.fasta
        """

rule get_amrplusplus_binaries:
    output:
        resistome_tool = os.path.join(config["params"]["binary_dir"], 'resistomeanalyzer', 'resistome'),
        rarefaction_tool = os.path.join(config["params"]["binary_dir"], 'rarefactionanalyzer', 'rarefaction'),
        snp_tool = os.path.join(config["params"]["binary_dir"], 'snpfinder', 'snpfinder')
    params:
        bin_dir = config['params']['binary_dir']
    shell:
        """
        cd {params.bin_dir}
        git clone https://github.com/cdeanj/snpfinder
        cd snpfinder
        make
        cd ..
        git clone https://github.com/cdeanj/rarefactionanalyzer
        cd rarefactionanalyzer
        make
        cd ..
        git clone https://github.com/cdeanj/resistomeanalyzer
        cd resistomeanalyzer
        make
        """

rule run_amrplusplus:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2'),
        megares_db = os.path.join(config["params"]["db_dir"], "megares", "megares_full_database_v2.00.fasta"),
        megares_annot = os.path.join(config["params"]["db_dir"], "megares", "megares_full_annotations_v2.00.csv"),
        resistome_tool = os.path.join(config["params"]["binary_dir"], 'resistomeanalyzer', 'resistome'),
        rarefaction_tool = os.path.join(config["params"]["binary_dir"], 'rarefactionanalyzer', 'rarefaction'),
        snp_tool = os.path.join(config["params"]["binary_dir"], 'snpfinder', 'snpfinder')
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
        output_prefix_tmp = "results/{sample}/amrplusplus/tmp"
    shell:
       """
       mkdir -p {params.output_prefix_tmp}
       trimmomatic PE  {input.read1} {input.read2} {params.output_prefix_tmp}/{wildcards.sample}_r1_pe_trimmed.fq {params.output_prefix_tmp}/{wildcards.sample}_r1_se_trimmed.fq {params.output_prefix_tmp}/{wildcards.sample}_r2_pe_trimmed.fq {params.output_prefix_tmp}/{wildcards.sample}_r2_se_trimmed.fq SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:36 2> >(tee {log} >&2)
       bwa mem {input.megares_db} {params.output_prefix_tmp}/{wildcards.sample}_r1_pe_trimmed.fq {params.output_prefix_tmp}/{wildcards.sample}_r2_pe_trimmed.fq | samtools sort -n -O sam > {params.output_prefix_tmp}/{wildcards.sample}.sam 2> >(tee -a {log} >&2)
       {input.resistome_tool} -ref_fp {input.megares_db} -annot_fp {input.megares_annot} -sam_fp {params.output_prefix_tmp}/{wildcards.sample}.sam -gene_fp {output.amr_gene} -group_fp {output.amr_group} -class_fp {output.amr_class} -mech_fp {output.amr_mech} -t 80 2> >(tee -a {log} >&2)
       {input.rarefaction_tool} -ref_fp {input.megares_db} -annot_fp {input.megares_annot} -sam_fp {params.output_prefix_tmp}/{wildcards.sample}.sam -gene_fp {output.amr_gene}_rare -group_fp {output.amr_group}_rare -class_fp {output.amr_class}_rare -mech_fp {output.amr_mech}_rare -min 5 -max 100 -skip 5 -samples 1 -t 80 2> >(tee -a {log} >&2)
       {input.snp_tool} -amr_fp {input.megares_db} -sampe {params.output_prefix_tmp}/{wildcards.sample}.sam -out_fp {output.amr_snps} 2> >(tee -a {log} >&2)
       """
