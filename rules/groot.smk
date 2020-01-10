rule run_groot:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2')
    output:
        report = "results/{sample}/groot/report.tsv"
    message: "Running rule run_groot on {wildcards.sample} with contigs"
    log:
       "logs/groot_{sample}.log"
    conda:
      "../envs/groot.yaml"
    threads:
       config["params"]["threads"]
    params:
        refdb = config["params"]["groot"]["db"],
    shell:
       "groot align -f {input.read1} {input.read2} -i {params.refdb} -y {log} | groot report -y {log} > {output.report}"
