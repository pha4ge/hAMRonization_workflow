rule run_srax:
    input:
        genome_dir = lambda wildcards: _get_seq (wildcards, 'assembly'),
    output:
        report = "results/{sample}/srax/Results/srax_analysis.html",
        outdir = "results/{sample}/srax"
    message: "Running rule run_srax on {wildcards.sample} with contigs"
    log:
       "logs/srax_{sample}.log"
    conda:
      "../envs/srax.yaml"
    threads:
       config["params"]["threads"]
    params:
       dbtype = config["params"]["srax"]["dbtype"]
    shell:
       "sraX -i {input.genome_dir} -t {threads} -db {params.dbtype} -o {output.outdir} 2> >(tee {log} >&2)"
