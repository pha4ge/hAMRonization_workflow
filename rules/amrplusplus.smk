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
        wget -O {output.megares_db} https://www.meglab.org/downloads/megares_v2.00/megares_full_database_v2.00.fasta
        wget -O {output.megares_annot} https://www.meglab.org/downloads/megares_v2.00/megares_full_annotations_v2.00.csv
        cd {params.db_dir}
        bwa index megares_full_database_v2.00.fasta
        """

rule get_amrplusplus_binaries:
    output:
        resistome_tool = os.path.join(config["params"]["binary_dir"], 'resistome'),
        rarefaction_tool = os.path.join(config["params"]["binary_dir"], 'rarefaction'),
        snp_tool = os.path.join(config["params"]["binary_dir"], 'snpfinder')
    params:
        bin_dir = config['params']['binary_dir'],
        snpfinder_version = config['params']['amrplusplus']["snpfinder_version"],
        resistome_analyzer_version = config['params']['amrplusplus']["resistome_analyzer_version"],
        rarefaction_analyzer_version = config['params']['amrplusplus']["rarefactionanalyzer_version"]
    shell:
        """
        rm -rf {output.resistome_tool} {output.rarefaction_tool} {output.snp_tool}
        TMP_DIR="$(mktemp -d)"
        git clone https://github.com/cdeanj/snpfinder $TMP_DIR/snpfinder
        git -C $TMP_DIR/snpfinder checkout {params.snpfinder_version}
        make -C $TMP_DIR/snpfinder
        mv $TMP_DIR/snpfinder/snpfinder {output.snp_tool}
        git clone https://github.com/cdeanj/rarefactionanalyzer $TMP_DIR/rarefaction
        git -C $TMP_DIR/rarefaction checkout {params.rarefaction_analyzer_version}
        make -C $TMP_DIR/rarefaction
        mv $TMP_DIR/rarefaction/rarefaction {output.rarefaction_tool}
        git clone https://github.com/cdeanj/resistomeanalyzer $TMP_DIR/resistome
        git -C $TMP_DIR/resistome checkout {params.resistome_analyzer_version}
        make -C $TMP_DIR/resistome
        mv $TMP_DIR/resistome/resistome {output.resistome_tool}
        rm -rf "$TMP_DIR"
        """

rule run_amrplusplus:
    input:
        read1 = get_read1,
        read2 = get_read2,
        megares_db = os.path.join(config["params"]["db_dir"], "megares", "megares_full_database_v2.00.fasta"),
        megares_annot = os.path.join(config["params"]["db_dir"], "megares", "megares_full_annotations_v2.00.csv"),
        resistome_tool = os.path.join(config["params"]["binary_dir"], 'resistome'),
        rarefaction_tool = os.path.join(config["params"]["binary_dir"], 'rarefaction'),
        snp_tool = os.path.join(config["params"]["binary_dir"], 'snpfinder')
    output:
        amr_class = "results/{sample}/amrplusplus/class.tsv",
        amr_gene  = "results/{sample}/amrplusplus/gene.tsv",
        amr_snps  = "results/{sample}/amrplusplus/snp.tsv",
        amr_group = "results/{sample}/amrplusplus/group.tsv",
        amr_mech  = "results/{sample}/amrplusplus/mech.tsv",
        metadata = "results/{sample}/amrplusplus/metadata.txt"
    log:
       "logs/amrplusplus_{sample}.log"
    message:
        "Running rule run_amrplusplus on {wildcards.sample} with reads"
    conda:
      "../envs/amrplusplus.yaml"
    threads:
       config["params"]["threads"]
    params:
        output_prefix_tmp = "results/{sample}/amrplusplus/tmp",
        resistome_analyzer_version = config['params']['amrplusplus']["resistome_analyzer_version"]
    shell:
       """
       mkdir -p {params.output_prefix_tmp}
       trimmomatic PE {input.read1} {input.read2} {params.output_prefix_tmp}/{wildcards.sample}_r1_pe_trimmed.fq {params.output_prefix_tmp}/{wildcards.sample}_r1_se_trimmed.fq {params.output_prefix_tmp}/{wildcards.sample}_r2_pe_trimmed.fq {params.output_prefix_tmp}/{wildcards.sample}_r2_se_trimmed.fq SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:36 >{log} 2>&1
       bwa mem {input.megares_db} {params.output_prefix_tmp}/{wildcards.sample}_r1_pe_trimmed.fq {params.output_prefix_tmp}/{wildcards.sample}_r2_pe_trimmed.fq 2>> {log} | samtools sort -n -O sam > {params.output_prefix_tmp}/{wildcards.sample}.sam 2>>{log}
       {input.resistome_tool} -ref_fp {input.megares_db} -annot_fp {input.megares_annot} -sam_fp {params.output_prefix_tmp}/{wildcards.sample}.sam -gene_fp {output.amr_gene} -group_fp {output.amr_group} -class_fp {output.amr_class} -mech_fp {output.amr_mech} -t 80  >>{log} 2>&1
       {input.rarefaction_tool} -ref_fp {input.megares_db} -annot_fp {input.megares_annot} -sam_fp {params.output_prefix_tmp}/{wildcards.sample}.sam -gene_fp {output.amr_gene}_rare -group_fp {output.amr_group}_rare -class_fp {output.amr_class}_rare -mech_fp {output.amr_mech}_rare -min 5 -max 100 -skip 5 -samples 1 -t 80 >>{log} 2>&1
       {input.snp_tool} -amr_fp {input.megares_db} -sampe {params.output_prefix_tmp}/{wildcards.sample}.sam -out_fp {output.amr_snps} >>{log} 2>&1
       #rm -rf {params.output_prefix_tmp}

       echo "--analysis_software_version {params.resistome_analyzer_version}" > {output.metadata}
       echo "--reference_database_version v2.00" >> {output.metadata}
       """

rule hamronize_amrplusplus:
    input:
        read1 = get_read1,
        amr_gene  = "results/{sample}/amrplusplus/gene.tsv",
        metadata = "results/{sample}/amrplusplus/metadata.txt"
    output:
        "results/{sample}/amrplusplus/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize amrplusplus $(paste - - < {input.metadata}) --input_file_name {input.read1} {input.amr_gene} > {output}
        """
