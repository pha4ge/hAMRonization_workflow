rule get_rgi_db:
    output:
        card_db = os.path.join(config["params"]["db_dir"], "card", "card.json")
    params:
        db_dir = os.path.join(config["params"]["db_dir"], "card")
    log:
        "logs/rgi_db.log"
    shell:
        """{{
        mkdir -p {params.db_dir}
        wget -c -q -O {params.db_dir}/card.tar.bz2 'https://card.mcmaster.ca/latest/data'
        tar -C {params.db_dir} -xvf {params.db_dir}/card.tar.bz2
        rm -f {params.db_dir}/card.tar.bz2
        }} >{log} 2>&1
        """

rule run_rgi:
    input:
        contigs = get_assembly,
        card_db = os.path.join(config["params"]["db_dir"], "card", "card.json")
    output:
        report = "results/{sample}/rgi/rgi.txt",
        metadata = "results/{sample}/rgi/metadata.txt"
    message: "Running rule run_rgi on {wildcards.sample} with contigs"
    log:
        "logs/rgi_{sample}.log"
    conda:
        "../envs/rgi.yaml"
    threads:
        config["params"]["threads"]
    params:
        out_dir = "results/{sample}/rgi"
    shell:
        """{{
        # Inconveniently we need to cd to the output directory because 'rgi load' writes
        # its database where it runs, and we don't want two jobs writing in one location.
        # Before we change directory we need to make all file paths absolute.
        FNA="$(realpath '{input.contigs}')"
        CARD="$(realpath '{input.card_db}')"
        META="$(realpath '{output.metadata}')"
        mkdir -p {params.out_dir}
        cd {params.out_dir}
        rgi load -i "$CARD" --local
        rgi main --local --clean --input_sequence "$FNA" --output_file rgi --num_threads {threads}
        # We extract the database version from the JSON, as 'rgi database -v' gives "N/A"
        echo "--analysis_software_version $(rgi main --version) --reference_database_version $(jq -r '._version' "$CARD")" >"$META"
        }} >{log} 2>&1
        """

rule hamronize_rgi:
    input:
        contigs = get_assembly,
        report = "results/{sample}/rgi/rgi.txt",
        metadata = "results/{sample}/rgi/metadata.txt"
    output:
        "results/{sample}/rgi/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize rgi $(cat {input.metadata}) --input_file_name {input.contigs} {input.report} > {output}
        """
