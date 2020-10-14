rule run_staramr:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
    output:
        report = "results/{sample}/staramr/resfinder.tsv",
        metadata = "results/{sample}/staramr/metadata.txt"
    message: "Running rule run_staramr on {wildcards.sample} with contigs"
    log:
       "logs/staramr_{sample}.log"
    conda:
      "../envs/staramr.yaml"
    threads:
       config["params"]["threads"]
    params:
        output_folder = "results/{sample}/staramr/",
        pointfinder_species = config['params']['pointfinder']['species'],
        settings = "results/{sample}/staramr/settings.txt"
    shell:
       """
       rm -r {params.output_folder};
       staramr search -o {params.output_folder} --nproc {threads} {input.contigs} >{log} 2>&1
       staramr --version | perl -p -e 's/staramr (.+)/analysis_software_version: $1/' > {output.metadata}
       cat {params.settings} | grep resfinder_db_date | perl -p -e 's/.+= (.+)/reference_database_version: $1/' >> {output.metadata}
       """
        # only support salmonella/campylobacter
