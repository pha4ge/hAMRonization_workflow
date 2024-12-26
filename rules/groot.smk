rule get_groot_db:
    output:
       db = directory(os.path.join(config["params"]["db_dir"], "groot_index"))
    conda:
      "../envs/groot.yaml"
    params:
        db_source = config['params']['groot']['db_source'],
        read_length = config['params']['groot']['read_length'],
        db_dir = config["params"]["db_dir"]
    log:
       "logs/groot_db.log"
    threads:
       config["params"]["threads"]
    shell:
        """
        rm -rf {params.db_dir}/groot_clustered
        groot get -d {params.db_source} -o {params.db_dir}/groot_clustered
        groot index -p {threads} -m {params.db_dir}/groot_clustered/{params.db_source}.90 -i {output.db} -w {params.read_length} --log {log}
        """

rule run_groot:
    input:
        read1 = get_read1,
        read2 = get_read2,
        db_index = os.path.join(config["params"]["db_dir"], "groot_index")
    output:
        report = "results/{sample}/groot/report.tsv",
        metadata = "results/{sample}/groot/metadata.txt"
    message: "Running rule run_groot on {wildcards.sample} with reads"
    log:
       "logs/groot_{sample}.log"
    conda:
      "../envs/groot.yaml"
    threads:
       config["params"]["threads"]
    params:
        min_read_length = config['params']['groot']['read_length'] - config['params']['groot']['window'],
        max_read_length = config['params']['groot']['read_length'] + config['params']['groot']['window'],
        graph_dir = "results/{sample}/groot/graphs"
    shell:
       """
       zcat {input.read1} {input.read2} | seqkit seq --min-len {params.min_read_length} --max-len {params.max_read_length} | groot align -g {params.graph_dir} -p {threads} -i {input.db_index} --log {log} | groot report --log {log} > {output.report}
       groot version | perl -p -e 's/(.+)/--analysis_software_version $1/' > {output.metadata}
       """

rule hamronize_groot:
    input:
        read1 = get_read1,
        report = "results/{sample}/groot/report.tsv",
        metadata = "results/{sample}/groot/metadata.txt"
    output:
        "results/{sample}/groot/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    params:
        db_source = config['params']['groot']['db_source'],
        db_dir = config["params"]["db_dir"]
    shell:
        """
        hamronize groot --input_file_name {input.read1} $(paste - < {input.metadata}) --reference_database_name {params.db_source} --reference_database_version $(paste - < {params.db_dir}/groot_clustered/card.90/timestamp.txt) {input.report} > {output}
        """
