rule run_srax:
    input:
        contigs = get_assembly
    output:
        report = "results/{sample}/srax/sraX_detected_ARGs.tsv",
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
        dateformat = config["params"]["dateformat"]
    shell:
        """{{
        mkdir -p $(dirname {output.report})
        # copy input to a temp directory because sraX processes every fasta file in its input directory
        TMPDIR=$(mktemp -d)
        cp {input.contigs} $TMPDIR/
        sraX -i $TMPDIR -t 4 -db {params.dbtype} -o $TMPDIR/output
        mv $TMPDIR/output/Results/Summary_files/sraX_detected_ARGs.tsv {output.report}
        rm -rf $TMPDIR
        }} >{log} 2>&1
        printf -- '--analysis_software_version %s --reference_database_version %s --reference_database_name srax_{params.dbtype}_amr_db' \
                     $(sraX --version | fgrep version | cut -d: -f2)   $(date '+{params.dateformat}')  >{output.metadata}
       """

rule hamronize srax:
    input:
        contigs = get_assembly,
        report = "results/{sample}/srax/sraX_detected_ARGs.tsv",
        metadata = "results/{sample}/srax/metadata.txt"
    output:
        "results/{sample}/srax/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize srax --input_file_name {input.contigs} $(cat {input.metadata}) {input.report} > {output}
        """
