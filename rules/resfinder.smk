rule get_resfinder_db:
    output: 
       resfinder_db = directory(os.path.join(config["params"]["db_dir"], "resfinder_db"))
    log:
        "logs/resfinder_db.log"
    params:
        db_dir = os.path.join(config["params"]["db_dir"], "resfinder")
    shell:
        """
        curl https://bitbucket.org/genomicepidemiology/resfinder_db/get/2a8dd7fc7a8c.zip --output {params.db_dir}.zip
        unzip -j -d {output.resfinder_db} {params.db_dir}.zip
        """

rule run_resfinder:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        resfinder_db = os.path.join(config["params"]["db_dir"], "resfinder_db")
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
        outdir = "results/{sample}/resfinder",
        output_tmp_dir = "results/{sample}/resfinder/tmp"
    shell:
       """
       mkdir -p {params.outdir}
       resfinder.py -p {input.resfinder_db} -i {input.contigs} -o {params.outdir} > {log} 2>&1
       rm -rf {params.output_tmp_dir}
       """
