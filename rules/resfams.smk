rule get_resfams_db:
    output: 
       resfams_hmms = os.path.join(config["params"]["db_dir"], "resfams-full.hmm")
    shell:
       "curl http://dantaslab.wustl.edu/resfams/Resfams-full.hmm.gz | gunzip > {output.resfams_hmms} "

rule run_resfams:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        resfams_hmms = os.path.join(config["params"]["db_dir"], "resfams-full.hmm")
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
       hmmsearch -h | grep "# HMMER " | perl -p -e 's/# (.+) \(.+/analysis_software_version:$1/' >> {output.metadata}
       """
#       prodigal -v 2>&1 | grep "Prodigal" | perl -p -e 's/(.+)/analysis_software_version:$1/' > {output.metadata}
