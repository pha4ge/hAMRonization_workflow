rule run_abricate:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
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
        dbname = config["params"]["abricate"]["name"], #"ncbi",
        minid = config["params"]["abricate"]["minid"],
        mincov = config["params"]["abricate"]["minid"]
    shell:
        """
        abricate --list > {log}
        abricate --threads {threads} --nopath --db {params.dbname} --minid {params.minid} --mincov {params.mincov} {input.contigs} > {output.report} > {log} 2>&1
        """
