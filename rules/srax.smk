rule run_srax:
    input:
        genome_dir = lambda wildcards: _get_seqdir(wildcards),
    output:
        report = "results/{sample}/srax/Summary_files/sraX_detected_ARGs.tsv",
        metadata = "results/{sample}/srax/metadata.txt"
    message: "Running rule run_srax on {wildcards.sample} with contigs"
    log:
       "logs/srax_{sample}.log"
    conda:
      "../envs/srax.yaml"
    threads:
       config["params"]["threads"]
    params:
       dbtype = config["params"]["srax"]["dbtype"],
       outdir = "results/{sample}/srax",
       tmp_output_dir = "results/{sample}/srax/tmp",
       log_output_dir = "results/{sample}/srax/Log",
       ARG_DB_output_dir = "results/{sample}/srax/ARG_DB",
       analysis_output_dir = "results/{sample}/srax/Analysis",
       result_output_dir = "results/{sample}/srax/Results",
       dateformat = config["params"]["dateformat"]
    shell:
       """
       sraX -i {input.genome_dir} -t 4 -db {params.dbtype} -o {params.outdir} > {log} 2>&1
       mv {params.result_output_dir}/* {params.outdir}
       sraX --version | grep version | perl -p -e 's/.+version: (.+)/--analysis_software_version $1/' > {output.metadata}
       date +"{params.dateformat}" | perl -p -e 's/(.+)/--reference_database_version $1/' >> {output.metadata}
       """
#       rm -rf {params.tmp_output_dir} {params.log_output_dir} {params.ARG_DB_output_dir} {params.analysis_output_dir} {params.result_output_dir}

rule hamronize srax:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        report = "results/{sample}/srax/Summary_files/sraX_detected_ARGs.tsv",
        metadata = "results/{sample}/srax/metadata.txt"
    output:
        "results/{sample}/srax/hamronized_report.tsv"
    params:
        dbtype = config["params"]["srax"]["dbtype"]
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize srax --input_file_name {input.contigs} $(paste - - < {input.metadata}) --reference_database_id srax_{params.dbtype}_amr_db {input.report} > {output}
        """
