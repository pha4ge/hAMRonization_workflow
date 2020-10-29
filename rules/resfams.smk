rule get_resfams_db:
    output: 
       resfams_hmms = os.path.join(config["params"]["db_dir"], "resfams-full.hmm"),
       dbversion = os.path.join(config["params"]["db_dir"], "resfams.version.txt")
    params:
       dateformat = config["params"]["dateformat"]
    shell:
       """
       curl http://dantaslab.wustl.edu/resfams/Resfams-full.hmm.gz | gunzip > {output.resfams_hmms}
       date +"{params.dateformat}" > {output.dbversion}
       """

rule run_resfams:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        resfams_hmms = os.path.join(config["params"]["db_dir"], "resfams-full.hmm"),
        dbversion = os.path.join(config["params"]["db_dir"], "resfams.version.txt")
    output:
        report = "results/{sample}/resfams/resfams.tblout",
        metadata = "results/{sample}/resfams/metadata.txt"
    message: "Running rule run_resfams on {wildcards.sample} with contigs"
    log:
       "logs/resfams_{sample}.log"
    conda:
      "../envs/resfams.yaml"
    threads:
       config["params"]["threads"]
    params:
        output_prefix = "results/{sample}/resfams"
    shell:
       """
       prodigal -i {input.contigs} -a {params.output_prefix}/protein_seqs.faa > {log} 2>&1
       hmmsearch --cpu {threads} --tblout {output.report} {input.resfams_hmms} {params.output_prefix}/protein_seqs.faa  >>{log} 2>&1
       hmmsearch -h | grep "# HMMER " | perl -p -e 's/# HMMER (.+) \(.+/--analysis_software_version hmmsearch_v$1/' >> {output.metadata}
       cat {input.dbversion} | perl -p -e 's/(.+)/--reference_database_version $1/' >> {output.metadata} 
       """
#       prodigal -v 2>&1 | grep "Prodigal" | perl -p -e 's/(.+)/--analysis_software_version $1/' > {output.metadata}

rule hamronize_resfams:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        report = "results/{sample}/resfams/resfams.tblout",
        metadata = "results/{sample}/resfams/metadata.txt"
    output:
        "results/{sample}/resfams/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize resfams --input_file_name {input.contigs} $(paste - - < {input.metadata}) {input.report} > {output}
        """
