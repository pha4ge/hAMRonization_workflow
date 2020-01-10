rule run_staramr:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
    output:
        report = "results/{sample}/staramr/resfinder.tsv"
    message: "Running rule run_staramr on {wildcards.sample} with contigs"
    log:
       "logs/staramr_{sample}.log"
    conda:
      "../envs/staramr.yaml"
    threads:
       config["params"]["threads"]
    params:
        output_folder = "results/{sample}/staramr/"
    shell:
       """
       rm -r {params.output_folder};
       staramr search -o {params.output_folder} {input.contigs} 2> >(tee {log} >&2)
       """
       #TODO: activate point mutation search for given species?
