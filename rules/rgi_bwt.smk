rule get_rgi_bwt_db:
    output: 
       card_db_bwt = os.path.join(config["params"]["db_dir"], "card_bwt", "card.json")
    params:
        db_version = config['params']['rgi']['db_version'],
        db_dir = os.path.join(config["params"]["db_dir"], "card_bwt")
    log:
        "logs/rgi_db.log"
    shell:
        """
        mkdir -p {params.db_dir}
        curl https://card.mcmaster.ca/download/0/broadstreet-v{params.db_version}.tar.gz --output {params.db_dir}/card.tar.gz
        tar -C {params.db_dir} -xvf {params.db_dir}/card.tar.gz
        """

rule run_rgi_bwt:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2'),
        card_db_bwt = os.path.join(config["params"]["db_dir"], "card_bwt", "card.json")
    output:
        report = "results/{sample}/rgibwt/rgibwt.gene_mapping_data.txt",
        metadata = "results/{sample}/rgibwt/metadata.txt"
    message: "Running rule run_rgi_bwt on {wildcards.sample} with reads"
    log:
       "logs/rgi_bwt_{sample}.log"
    conda:
      "../envs/rgi.yaml"
    threads:
       config["params"]["threads"]
    params:
        output_prefix = "results/{sample}/rgibwt/rgibwt"
    shell:
       """
       rgi card_annotation --input {input.card_db_bwt} > {log} 2>&1 
       rgi load --card_json {input.card_db_bwt} --card_annotation card_database_v*.fasta >> {log} 2>&1
       rm card_database_v*.fasta
       rgi bwt --read_one {input.read1} --read_two {input.read2} --output_file {params.output_prefix} --aligner bwa --threads {threads} >>{log} 2>&1

       echo "--analysis_software_version $(rgi main --version)" > {output.metadata}
       echo "--reference_database_version $(rgi database --version)" >> {output.metadata}
       """

rule hamronize_rgi_bwt:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        report = "results/{sample}/rgibwt/rgibwt.gene_mapping_data.txt",
        metadata = "results/{sample}/rgibwt/metadata.txt"
    output:
        "results/{sample}/rgibwt/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize rgi $(paste - - < {input.metadata}) --input_file_name {input.read1} {input.report} > {output}
        """
