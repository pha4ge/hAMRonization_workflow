rule get_ariba_db:
    output: db = directory(os.path.join(config["params"]["db_dir"], "ariba_card.prepareref"))
    conda:
      "../envs/ariba.yaml"
    log:
       "logs/ariba_db.log"
    params:
        db_dir = config["params"]["db_dir"]
    shell:
        """
        ariba getref card {params.db_dir}/ariba_card > {log}
        ariba prepareref -f {params.db_dir}/ariba_card.fa -m {params.db_dir}/ariba_card.tsv {output.db} >> {log}
        """

rule run_ariba:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2'),
        ref_db = os.path.join(config["params"]["db_dir"], "ariba_card.prepareref")
    output:
        report = "results/{sample}/ariba/report.tsv"
    message: "Running rule run_ariba on {wildcards.sample} with reads"
    log:
       "logs/ariba_{sample}.log"
    conda:
      "../envs/ariba.yaml"
    threads: 1
    params:
        output_folder = "results/{sample}/ariba/",
        tmp_dir = "results/{sample}/ariba_tmp"
    shell:
       """
       mkdir -p {params.tmp_dir}
       ariba run --noclean --force --tmp_dir {params.tmp_dir} --threads {threads} {input.ref_db} {input.read1} {input.read2} {params.output_folder} > {log} 2>&1
       rm -rf {params.tmp_dir}
       """
