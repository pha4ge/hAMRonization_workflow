rule run_deeparg:
    input:
        fasta_reads = "results/{sample}/deeparg/reads.fasta"
    output:
        report = "results/{sample}/deeparg/output.mapping.ARG",
        report_potential = "results/{sample}/deeparg/output.mapping.potential.ARG",
        metadata = "results/{sample}/deeparg/metadata.txt"
    log:
       "logs/deeparg_{sample}.log"
    singularity:
        "docker://gaarangoa/deeparg:v1.0.1"
    params:
        version = "1.0.1"
    shell:
        """
        python /deeparg/deepARG.py --align --type nucl --reads --input /data/results/{wildcards.sample}/deeparg/reads.fasta --output /data/results/{wildcards.sample}/deeparg/output > {log} 2>&1
        rm /data/results/{wildcards.sample}/deeparg/reads.fasta
        echo "--analysis_software_version {params.version}" > {output.metadata}
        echo "--reference_database_version {params.version}" >> {output.metadata}
        """

rule prepare_deeparg_reads:
    input:
        read1 = get_read1,
        read2 = get_read2
    output:
        fasta_reads = "results/{sample}/deeparg/reads.fasta"
    shell:
        "zcat {input.read1} {input.read2} > {output.fasta_reads}"

rule hamronize_deeparg:
    input:
        read1 = get_read1,
        report = "results/{sample}/deeparg/output.mapping.ARG",
        metadata = "results/{sample}/deeparg/metadata.txt"
    output:
        "results/{sample}/deeparg/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize deeparg --input_file_name {input.read1} $(paste - - < {input.metadata}) {input.report} > {output}
        """
