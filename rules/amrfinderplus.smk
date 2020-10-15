rule get_amrfinder_db:
    output: 
       dbversion = os.path.join(config["params"]["db_dir"], "amrfinderplus", "latest", "version.txt")
    conda:
      "../envs/amrfinderplus.yaml"
    log:
       "logs/amrfinderplus_db.log"
    shell:
        "amrfinder_update -d {output.db} 2> {log}"
        
rule run_amrfinderplus:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        dbversion = os.path.join(config["params"]["db_dir"], "amrfinderplus", "latest", "version.txt")
    output:
        report = "results/{sample}/amrfinderplus/report.tsv",
        metadata = "results/{sample}/amrfinderplus/metadata.txt"
    message: "Running rule run_amrfinderplus on {wildcards.sample} with contigs"
    log:
       "logs/amrfinderplus_{sample}.log"
    conda:
      "../envs/amrfinderplus.yaml"
    params:
        db = os.path.join(config["params"]["db_dir"], "amrfinderplus"),
        organism = config["params"]["amrfinderplus"]["organism"],
        output_tmp_dir = "results/{sample}/amrfinderplus/tmp",
    threads:
       config["params"]["threads"]
    shell:
        """
        amrfinder -n {input.contigs} -o {output.report} -O {params.organism} -d {params.db}/latest >{log} 2>&1
        rm -rf {params.output_tmp_dir}
        amrfinder --version | perl -p -e 's/(.+)/analysis_software_version: $1/' > {output.metadata}
        cat {input.dbversion} | perl -p -e 's/(.+)/reference_database_version: $1/' >> {output.metadata} 
        """
