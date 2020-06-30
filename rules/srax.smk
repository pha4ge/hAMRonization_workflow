rule run_srax:
    input:
        genome_dir = lambda wildcards: _get_seqdir(wildcards),
    output:
        report = "results/{sample}/srax/sraX_analysis.html"
    message: "Running rule run_srax on {wildcards.sample} with contigs"
    log:
       "logs/srax_{sample}.log"
    conda:
      "../envs/srax.yaml"
    threads:
       config["params"]["threads"]
    params:
       dbtype = config["params"]["srax"]["dbtype"],
       outdir = "results/{sample}/srax",
       tmp_output_dir = "results/{sample}/srax/tmp",
       log_output_dir = "results/{sample}/srax/Log",
       ARG_DB_output_dir = "results/{sample}/srax/ARG_DB",
       analysis_output_dir = "results/{sample}/srax/Analysis",
       result_output_dir = "results/{sample}/srax/Results"
    shell:
       """
       sraX -i {input.genome_dir} -t 4 -db {params.dbtype} -o {params.outdir} > {log} 2>&1
       mv {params.result_output_dir}/* {params.outdir}
       rm -rf {params.tmp_output_dir} {params.log_output_dir} {params.ARG_DB_output_dir} {params.analysis_output_dir} {params.result_output_dir}
       """
