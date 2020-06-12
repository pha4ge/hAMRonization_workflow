rule get_rgi_db:
    output: 
       card_db = os.path.join(config["params"]["db_dir"], "card", "card.json")
    params:
        db_version = config['params']['rgi']['db_version'],
        db_dir = os.path.join(config["params"]["db_dir"], "card")
    log:
        "logs/rgi_db.log"
    shell:
        """
        mkdir -p {params.db_dir}
        curl https://card.mcmaster.ca/download/0/broadstreet-v{params.db_version}.tar.gz --output {params.db_dir}/card.tar.gz
        tar -C {params.db_dir} -xvf {params.db_dir}/card.tar.gz
        """

rule run_rgi:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        card_db = os.path.join(config["params"]["db_dir"], "card", "card.json")
    output:
        report = "results/{sample}/rgi/rgi.json"
    message: "Running rule run_rgi on {wildcards.sample} with contigs"
    log:
       "logs/rgi_{sample}.log"
    conda:
      "../envs/rgi.yaml"
    threads:
       config["params"]["threads"]
    params:
        output_prefix = "results/{sample}/rgi/rgi"
    shell:
       """
       rgi load --card_json {input.card_db}
       rgi main --input_sequence {input.contigs} --output_file {params.output_prefix} --clean --num_threads {threads} 2> >(tee {log} >&2)
       """
