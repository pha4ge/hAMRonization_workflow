rule run_resfinder:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        ref = config["params"]["resfinder"]["path"]
    output:
        report = "results/{sample}/resfinder/data_resfinder.json"
    message: "Running rule run_resfinder on {wildcards.sample} with contigs"
    log:
       "logs/resfinder_{sample}.log"
    conda:
      "../envs/resfinder.yaml"
    threads:
       config["params"]["threads"]
    params:
        refdb = config["params"]["resfinder"]["path"],
        outdir = "results/{sample}/resfinder"
    shell:
       "resfinder.py -p {params.refdb} -i {input.contigs} -o {output.outdir} 2> >(tee {log} >&2)"
