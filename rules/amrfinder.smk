rule run_amrfinder:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
    output:
        report = "results/{sample}/amrfinder/report.tsv"
    message: "Running rule run_amrfinder on {wildcards.sample} with contigs"
    log:
       "logs/amrfinder_{sample}.log"
    conda:
      "../envs/amrfinder.yaml"
    threads:
       config["params"]["threads"]
    params:
        #refdb = config["params"]["amrfinder"]["path"],
    shell:
       "amrfinder -n {refdb} -"
       "amrfinder --threads {threads} --nopath --db {params.dbname} --minid {params.minid} --mincov {params.mincov} --datadir {params.refdb} {input.contigs} > {output.report} 2> >(tee {log} >&2)"
