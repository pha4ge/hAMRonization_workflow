rule get_ariba_db:
    output:
      db = directory(os.path.join(config["params"]["db_dir"], "ariba_card.prepareref")),
      dbversion = os.path.join(config["params"]["db_dir"], "ariba_card.version.txt")
    conda:
      "../envs/ariba.yaml"
    log:
       "logs/ariba_db.log"
    params:
        db_dir = config["params"]["db_dir"],
        dateformat = config["params"]["dateformat"]
    shell:
        """
        ariba getref card {params.db_dir}/ariba_card > {log}
        ariba prepareref -f {params.db_dir}/ariba_card.fa -m {params.db_dir}/ariba_card.tsv {output.db} >> {log}
        date +"{params.dateformat}" > {output.dbversion}
        """

rule run_ariba:
    input:
        read1 = get_read1,
        read2 = get_read2,
        ref_db = os.path.join(config["params"]["db_dir"], "ariba_card.prepareref"),
        dbversion = os.path.join(config["params"]["db_dir"], "ariba_card.version.txt")
    output:
        report = "results/{sample}/ariba/report.tsv",
        metadata = "results/{sample}/ariba/metadata.txt"
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
       ariba version | grep "ARIBA version" | perl -p -e 's/ARIBA version: (.+)/--analysis_software_version $1/' > {output.metadata}
       cat {input.dbversion} | perl -p -e 's/(.+)/--reference_database_version $1/' >> {output.metadata}
       """

rule hamronize_ariba:
    input:
        read1 = get_read1,
        report = "results/{sample}/ariba/report.tsv",
        metadata = "results/{sample}/ariba/metadata.txt"
    output:
        "results/{sample}/ariba/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize ariba --input_file_name {input.read1} --reference_database_name CARD $(paste - - < {input.metadata}) {input.report} > {output}
        """
