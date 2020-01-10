rule run_amrfinder:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        ref = os.path.join(config["params"]["abricate"]["path"],config["params"]["abricate"]["name"],"sequences")
    output:
        report = "results/{sample}/abricate/report.tsv"
    message: "Running rule run_abricate on {wildcards.sample} with contigs"
    log:
       "logs/abricate_{sample}.log"
    conda:
      "../envs/abricate.yaml"
    threads:
       config["params"]["threads"]
    params:
        refdb = config["params"]["abricate"]["path"],
        dbname = config["params"]["abricate"]["name"], #"ncbi",
        minid = config["params"]["abricate"]["minid"],
        mincov = config["params"]["abricate"]["minid"]
    shell:
       "amrfinder -n {refdb} -"
       "abricate --threads {threads} --nopath --db {params.dbname} --minid {params.minid} --mincov {params.mincov} --datadir {params.refdb} {input.contigs} > {output.report} 2> >(tee {log} >&2)"
