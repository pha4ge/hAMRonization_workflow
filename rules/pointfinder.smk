rule run_pointfinder:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
    output:
        report = "results/{sample}/pointfinder/report.tsv"
    message: "Running rule run_pointfinder on {wildcards.sample} with contigs"
    log:
       "logs/pointfinder_{sample}.log"
    conda:
      "../envs/pointfinder.yaml"
    threads:
       config["params"]["threads"]
    params:
        species = config["params"]["pointfinder"]["species"],
        dbpath = config["params"]["pointfinder"]["db"], 
        binary = config["params"]["pointfinder"]["binary"] 
    shell:
       """
       python {params.binary} -i {input.contigs} -p {params.dbpath} -s {params.species} -m blastn -m_p $(which blastn) -o results/{wildcards.sample}/pointfinder 2> >(tee {log} >&2)
       mv results/*_results.tsv {outout.report}
       """
