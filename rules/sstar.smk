rule run_sstar:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
    output:
        report = "results/{sample}/sstar/report.tsv"
    message: "Running rule run_sstar on {wildcards.sample} with contigs"
    log:
       "logs/sstar_{sample}.log"
    conda:
      "../envs/sstar.yaml"
    threads:
       config["params"]["threads"]
    params:
        tool = config["params"]["sstar"]["binary"],
        refdf = contig["params"]["sstar"]["refdb"]
    shell:
       """
       {params.tool} -g {input.contigs} -d {params.refdb} > {output.report} 
       """
