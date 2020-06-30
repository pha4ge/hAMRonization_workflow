rule run_srst2:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2')
    output:
        report = "results/{sample}/srst2/srst2__fullgenes__ResFinder__results.txt"
    message: "Running rule run_srst2 on {wildcards.sample} with reads"
    log:
       "logs/srst2_{sample}.log"
    conda:
      "../envs/srst2.yaml"
    threads:
       config["params"]["threads"]
    params:
        gene_db = config["params"]["srst2"]["gene_db"],
        min_depth = config["params"]["srst2"]["min_depth"],
        max_divergence = config["params"]["srst2"]["max_divergence"],
        output_prefix = "results/{sample}/srst2/srst2"
    shell:
       "srst2 --threads {threads} --gene_db {params.gene_db} --forward '_R1' --reverse '_R2' --input_pe {input.read1} {input.read2} --min_depth {params.min_depth} --output {params.output_prefix} > {log} 2>&1"
