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
    shell:
        """
        groot get -d {params.db_source} -o {params.db_dir}/groot_clustered > {log}
        groot index -i {params.db_dir}/groot_clustered -o {output.db} -l {params.read_length} >> {log}
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
    shell:
       "groot align -f {input.read1} {input.read2} -i {input.db_index} -y {log} -o results/{wildcards.sample}/groot/graphs | groot report -y {log} > {output.report}"
