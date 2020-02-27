rule run_srax:
    input:
        genome_dir = lambda wildcards: _get_seqdir(wildcards),
    output:
        report = "results/{sample}/srax/Results/sraX_analysis.html"
    message: "Running rule run_srax on {wildcards.sample} with contigs"
    log:
       "logs/srax_{sample}.log"
    conda:
      "../envs/srax.yaml"
    threads:
       config["params"]["threads"]
    params:
       dbtype = config["params"]["srax"]["dbtype"],
       outdir = "results/{sample}/srax"
    shell:
       "sraX -i {input.genome_dir} -t 4 -db {params.dbtype} -o {params.outdir} 2> >(tee {log} >&2)"
