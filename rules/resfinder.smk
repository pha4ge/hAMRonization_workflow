rule get_resfinder_db:
    output: 
       resfinder_db = directory(os.path.join(config["params"]["db_dir"], "resfinder_db"))
    log:
        "logs/resfinder_db.log"
    params:
        db_dir = os.path.join(config["params"]["db_dir"], "resfinder"),
        db_version = config["params"]["resfinder"]["db_version"]
    shell:
        """
        curl https://bitbucket.org/genomicepidemiology/resfinder_db/get/{params.db_version}.zip --output {params.db_dir}.zip
        unzip -j -d {output.resfinder_db} {params.db_dir}.zip
        """

rule run_resfinder:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        resfinder_db = os.path.join(config["params"]["db_dir"], "resfinder_db")
    output:
        report = "results/{sample}/resfinder/data_resfinder.json",
        metadata = "results/{sample}/resfinder/metadata.txt"
    message: "Running rule run_resfinder on {wildcards.sample} with contigs"
    log:
       "logs/resfinder_{sample}.log"
    conda:
      "../envs/resfinder.yaml"
    threads:
       config["params"]["threads"]
    params:
        conda_env = "envs/resfinder.yaml",
        outdir = "results/{sample}/resfinder",
        output_tmp_dir = "results/{sample}/resfinder/tmp",
        db_version = config["params"]["resfinder"]["db_version"]
    shell:
       """
       mkdir -p {params.outdir}
       resfinder.py -p {input.resfinder_db} -i {input.contigs} -o {params.outdir} > {log} 2>&1
       rm -rf {params.output_tmp_dir}
       grep "resfinder=" {params.conda_env} | perl -p -e 's/ - resfinder=(.+)/--analysis_software_version $1/' > {output.metadata}
       echo "{params.db_version}" | perl -p -e 's/(.+)/--reference_database_version $1/' >> {output.metadata}
       """


rule hamronize_resfinder:
    input:
        report = "results/{sample}/resfinder/data_resfinder.json",
        metadata = "results/{sample}/resfinder/metadata.txt"
    output:
        "results/{sample}/resfinder/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize resfinder $(paste - - < {input.metadata}) {input.report} > {output}
        """
