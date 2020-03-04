rule run_groot:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2')
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
        refdb = config["params"]['groot']['gene_db']
    shell:
       "groot align -f {input.read1} {input.read2} -i {params.refdb} -y {log} -o results/{wildcards.sample}/groot/graphs | groot report -y {log} > {output.report}"
