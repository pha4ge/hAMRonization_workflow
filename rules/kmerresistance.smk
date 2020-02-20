rule run_kmerresistance:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2')
    output:
        report = "results/{sample}/kmerresistance/report.KmerRes"
    message: "Running rule run_kmerresistance on {wildcards.sample} with reads"
    log:
       "logs/kmerresistance_{sample}.log"
    conda:
      "../envs/kmerresistance.yaml"
    threads:
       config["params"]["threads"]
    params:
        amr_db = config["params"]["kmerresistance"]["amr_db"],
        species_db = config["params"]["kmerresistance"]["species_db"],
        output_folder = "results/{sample}/kmerresistance/"
    shell:
       """
       zcat {input.read1} {input.read2} > {params.output_folder}/temp_all_reads.fq
       kmerresistance -i {params.output_folder}/temp_all_reads.fq -t_db {params.amr_db} -s_db {params.species_db} -o {params.output_folder}/results 2> >(tee {log} >&2)
       rm {params.output_folder}/temp_all_reads.fq
       """
