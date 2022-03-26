rule get_rgi_db:
    output: 
       card_db = os.path.join(config["params"]["db_dir"], "card", "card.json")
    params:
        db_version = config['params']['rgi']['db_version'],
        db_dir = os.path.join(config["params"]["db_dir"], "card")
    log:
        "logs/rgi_db.log"
    shell:
        """
        mkdir -p {params.db_dir}
        curl https://card.mcmaster.ca/latest/data --output {params.db_dir}/card.tar.bz2
        tar -C {params.db_dir} -xvf {params.db_dir}/card.tar.bz2
        """

rule run_rgi:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        card_db = os.path.join(config["params"]["db_dir"], "card", "card.json")
    output:
        report = "results/{sample}/rgi/rgi.txt",
        metadata = "results/{sample}/rgi/metadata.txt"
    message: "Running rule run_rgi on {wildcards.sample} with contigs"
    log:
       "logs/rgi_{sample}.log"
    conda:
      "../envs/rgi.yaml"
    threads:
       config["params"]["threads"]
    params:
        output_prefix = "results/{sample}/rgi/rgi"
    shell:
       """
       rgi load --card_json {input.card_db} > {log} 2>&1
       rgi main --input_sequence {input.contigs} --output_file {params.output_prefix} --clean --num_threads {threads} >>{log} 2>&1

       echo "--analysis_software_version $(rgi main --version)" > {output.metadata}
       echo "--reference_database_version $(rgi database --version)" >> {output.metadata}
       """

rule hamronize_rgi:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        report = "results/{sample}/rgi/rgi.txt",
        metadata = "results/{sample}/rgi/metadata.txt"
    output:
        "results/{sample}/rgi/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize rgi $(paste - - < {input.metadata}) --input_file_name {input.contigs} {input.report} > {output}
        """
