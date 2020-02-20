rule run_srax:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
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
       "srax -i {input.contigs} -t {threads} -db {params.dbtype} -o {output.outdir} 2> >(tee {log} >&2)"
