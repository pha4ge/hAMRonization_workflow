rule get_srst2_db:
    output:
        db_file = os.path.join(config["params"]["db_dir"], config["params"]["srst2"]["gene_db"]),
        dbversion = os.path.join(config["params"]["db_dir"], config["params"]["srst2"]["gene_db"] + '-version.txt')
    log:
        "logs/srst2_db.log"
    params:
        db_source = config["params"]["srst2"]["db_source"],
        dateformat = config["params"]["dateformat"]
    shell:
        """
        curl {params.db_source} --output {output.db_file}
        date +"{params.dateformat}" > {output.dbversion}
        """

rule run_srst2:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2'),
        db_file = os.path.join(config["params"]["db_dir"], config["params"]["srst2"]["gene_db"]),
        dbversion = os.path.join(config["params"]["db_dir"], config["params"]["srst2"]["gene_db"] + '-version.txt')
    output:
        report = "results/{sample}/srst2/srst2__fullgenes__ARGannot__results.txt",
        metadata = "results/{sample}/srst2/metadata.txt"
    message: "Running rule run_srst2 on {wildcards.sample} with reads"
    log:
       "logs/srst2_{sample}.log"
    conda:
      "../envs/srst2.yaml"
    threads:
       config["params"]["threads"]
    params:
        gene_db = os.path.join(config["params"]["db_dir"], config["params"]["srst2"]["gene_db"]),
        min_depth = config["params"]["srst2"]["min_depth"],
        max_divergence = config["params"]["srst2"]["max_divergence"],
        for_suffix = config["params"]["srst2"]["forward"],
        rev_suffix = config["params"]["srst2"]["reverse"],
        output_prefix = "results/{sample}/srst2/srst2",
    shell:
       """
       srst2 --threads {threads} --gene_db {params.gene_db} --forward {params.for_suffix} --reverse {params.rev_suffix} --input_pe {input.read1} {input.read2} --min_depth {params.min_depth} --output {params.output_prefix} > {log} 2>&1
       srst2 --version 2>&1 | perl -p -e 's/srst2 (.+)/--analysis_software_version $1/' > {output.metadata}
       cat {input.dbversion} | perl -p -e 's/(.+)/--reference_database_version $1/' >> {output.metadata}
       """

rule hamronize_srst2:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        report = "results/{sample}/srst2/srst2__fullgenes__ARGannot__results.txt",
        metadata = "results/{sample}/srst2/metadata.txt"
    output:
        "results/{sample}/srst2/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize srst2 --input_file_name {input.read1} $(paste - - - < {input.metadata}) {input.report} > {output}
        """
