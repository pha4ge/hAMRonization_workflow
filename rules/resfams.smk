rule run_resfams:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
    output:
        report = "results/{sample}/resfams/resfams.tblout"
    message: "Running rule run_resfams on {wildcards.sample} with contigs"
    log:
       "logs/resfams_{sample}.log"
    conda:
      "../envs/resfams.yaml"
    threads:
       config["params"]["threads"]
    params:
        output_prefix = "results/{sample}/resfams/resfams",
        refdb = config["params"]["resfams"]["db"]
    shell:
       """
       prodigal -i {input.contigs} -a {params.output_prefix}/protein_seqs.faa 2> >(tee {log} >&2);
       hmmsearch --threads {threads} --tblout {output.report} {params.refdb} {params.output_prefix}/protein_seqs.faa 2> >(tee {log} >&2)
       """
