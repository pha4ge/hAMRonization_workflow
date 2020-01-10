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
        refdb = config["params"]["amrfinder"]["gene_db"],
    shell:
       "amrfinder -n {input.contigs} -o {output.report} -d {params.refdb} 2> >(tee {log} >&2) "
