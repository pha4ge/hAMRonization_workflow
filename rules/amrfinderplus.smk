rule get_amrfinder_db:
    output:
        dbversion = os.path.join(config["params"]["db_dir"], "amrfinderplus", "latest", "version.txt")
    conda:
        "../envs/amrfinderplus.yaml"
    params:
        db_dir = os.path.join(config['params']['db_dir'], 'amrfinderplus')
    log:
        "logs/amrfinderplus_db.log"
    shell:
        "amrfinder_update -d {params.db_dir} 2> {log}"

rule run_amrfinderplus:
    input:
        contigs = get_assembly,
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
        output_tmp_dir = "results/{sample}/amrfinderplus/tmp",
    threads:
        config["params"]["threads"]
    shell:
        """
        amrfinder -n {input.contigs} -o {output.report} -d {params.db}/latest >{log} 2>&1
        rm -rf {params.output_tmp_dir}
        amrfinder --version | perl -p -e 's/(.+)/--analysis_software_version $1/' > {output.metadata}
        cat {input.dbversion} | perl -p -e 's/(.+)/--reference_database_version $1/' >> {output.metadata}
        """

rule hamronize_amrfinderplus:
    input:
        contigs = get_assembly,
        report = "results/{sample}/amrfinderplus/report.tsv",
        metadata = "results/{sample}/amrfinderplus/metadata.txt"
    output:
        "results/{sample}/amrfinderplus/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize amrfinderplus --input_file_name {input.contigs} $(paste - - < {input.metadata}) {input.report} > {output}
        """
