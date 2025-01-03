rule get_rgi_bwt_db:
    output:
        card_db_bwt = os.path.join(config["params"]["db_dir"], "card_bwt", "card.json")
    params:
        db_dir = os.path.join(config["params"]["db_dir"], "card_bwt")
    log:
        "logs/rgi_bwt_db.log"
    shell:
        """{{
        mkdir -p {params.db_dir}
        wget -c -q -O {params.db_dir}/card.tar.bz2 'https://card.mcmaster.ca/latest/data'
        tar -C {params.db_dir} -xf {params.db_dir}/card.tar.bz2
        rm -f {params.db_dir}/card.tar.bz2
        }} >{log} 2>&1
        """

rule run_rgi_bwt:
    input:
        read1 = get_read1,
        read2 = get_read2,
        card_db = os.path.join(config["params"]["db_dir"], "card_bwt", "card.json")
    output:
        report = "results/{sample}/rgibwt/rgibwt.gene_mapping_data.txt",
        metadata = "results/{sample}/rgibwt/metadata.txt"
    message: "Running rule run_rgi_bwt on {wildcards.sample} with reads"
    log:
        "logs/rgi_bwt_{sample}.log"
    conda:
        "../envs/rgi.yaml"
    threads:
        config["params"]["threads"]
    params:
        out_dir = "results/{sample}/rgibwt"
    shell:
        """{{
        # We need to change directory to the output directory because we can't
        # control where rgi writes its annotations or "loads" its database;
        # and so before this we need to make all paths we use relative to PWD
        FQ1="$(realpath '{input.read1}')"
        FQ2="$(realpath '{input.read2}')"
        CARD="$(realpath '{input.card_db}')"
        META="$(realpath '{output.metadata}')"
        mkdir -p {params.out_dir}
        cd {params.out_dir}
        
        # Figure out the database version as 'rgi database -v' gives "NA"
        DB_VER="$(jq -r '._version' "$CARD")"

        # Create the annotation files (will be written in PWD)
        rgi card_annotation --input "$CARD"
        F1="card_database_v${{DB_VER}}.fasta"
        F2="card_database_v${{DB_VER}}_all.fasta"

        # Now "load" (= create) the database locally and run the tool
        rgi load --local -i "$CARD" --card_annotation "$F1" --card_annotation_all_models "$F2"
        rm -f "$F1" "$F2"
        rgi bwt --local --clean --read_one "$FQ1" --read_two "$FQ2" --output_file "rgibwt" --threads {threads}

        echo "--analysis_software_version $(rgi main --version) --reference_database_version $DB_VER" >"$META"
        }} >{log} 2>&1
        """

rule hamronize_rgi_bwt:
    input:
        read1 = get_read1,
        report = "results/{sample}/rgibwt/rgibwt.gene_mapping_data.txt",
        metadata = "results/{sample}/rgibwt/metadata.txt"
    output:
        "results/{sample}/rgibwt/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize rgi $(cat {input.metadata}) --input_file_name {input.read1} {input.report} > {output}
        """
