rule run_ariba:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2')
    output:
        report = "results/{sample}/ariba/report.tsv"
    message: "Running rule run_ariba on {wildcards.sample} with reads"
    log:
       "logs/ariba_{sample}.log"
    conda:
      "../envs/ariba.yaml"
    threads:
       config["params"]["threads"]
    params:
        gene_db = config["params"]["ariba"]["gene_db"],
        output_folder = "results/{sample}/ariba/"
    shell:
       "ariba run --threads {threads} {params.gene_db} {input.reads} {input.read1} {input.read2} {params.output_folder} 2> >(tee {log} >&2)"





