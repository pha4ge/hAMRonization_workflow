rule run_deeparg:
    input:
        fasta_reads = "results/{sample}/deeparg/reads.fasta"
    output:
        report = "results/{sample}/deeparg/output.mapping.ARG",
        report_potential = "results/{sample}/deeparg/output.mapping.potential.ARG",
        metadata = "results/{sample}/deeparg/metadata.txt"
    log:
       "logs/amrfinder_{sample}.log"
    singularity:
        "docker://gaarangoa/deeparg:v1.0.1"
    params:
        version = "1.0.1"
    shell:
        """
        python /deeparg/deepARG.py --align --type nucl --reads --input /data/results/{wildcards.sample}/deeparg/reads.fasta --output /data/results/{wildcards.sample}/deeparg/output > {log} 2>&1
        rm /data/results/{wildcards.sample}/deeparg/reads.fasta
        echo "analysis_software_version:{params.version}" > {output.metadata}
        """

rule prepare_deeparg_reads:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2')
    output:
        fasta_reads = "results/{sample}/deeparg/reads.fasta"
    shell:
        "zcat {input.read1} {input.read2} > {output.fasta_reads}"
