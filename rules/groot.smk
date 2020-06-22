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
        groot get -d {params.db_source} -o {params.db_dir}/groot_clustered 
        groot index -p {threads} -m {params.db_dir}/groot_clustered/{params.db_source}.90 -i {output.db} -w {params.read_length} --log {log}
        """

rule run_groot:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2'),
        db_index = os.path.join(config["params"]["db_dir"], "groot_index")
    output:
        report = "results/{sample}/groot/report.tsv"
    message: "Running rule run_groot on {wildcards.sample} with reads"
    log:
       "logs/groot_{sample}.log"
    conda:
      "../envs/groot.yaml"
    threads:
       config["params"]["threads"]
    params:
        min_read_length = config['params']['groot']['read_length'] - 5,
        max_read_length = config['params']['groot']['read_length'] + 5
    shell:
       "zcat {input.read1} {input.read2} | seqkit seq --min-len {params.min_read_length} --max-len {params.max_read_length} | groot align -p {threads} -i {input.db_index} --log {log} | groot report --log {log} > {output.report}"
