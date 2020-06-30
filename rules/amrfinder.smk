rule get_amrfinder_db:
    output: 
       db = directory(os.path.join(config["params"]["db_dir"], "amrfinder"))
    conda:
      "../envs/amrfinder.yaml"
    log:
       "logs/amrfinder_db.log"
    shell:
        "amrfinder_update -d {output.db} 2> {log}"
        
rule run_amrfinder:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        db = os.path.join(config["params"]["db_dir"], "amrfinder")
    output:
        report = "results/{sample}/amrfinder/report.tsv"
    message: "Running rule run_amrfinder on {wildcards.sample} with contigs"
    log:
       "logs/amrfinder_{sample}.log"
    conda:
      "../envs/amrfinder.yaml"
    params:
        organism = config["params"]["amrfinder"]["organism"],
        output_tmp_dir = "results/{sample}/amrfinder/tmp"
    threads:
       config["params"]["threads"]
    shell:
        """
        amrfinder -n {input.contigs} -o {output.report} -O {params.organism} -d {input.db}/latest >{log} 2>&1
        rm -rf {params.output_tmp_dir}
        """
