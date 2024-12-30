rule get_deeparg_db:
    output:
        db_dir = directory(os.path.join(config['params']['db_dir'], 'deeparg'))
    log:
        "logs/deeparg_db.log"
    params:
        db_zip = os.path.join(config['params']['db_dir'], 'deeparg.zip')
    shell:
        """
        # deeparg download_data should do this but thinks it is gzip and fails;
        # we use wget -c so an incomplete download will resume (it is 1.8G)
        wget -cO '{params.db_zip}' 'https://zenodo.org/records/8280582/files/deeparg.zip?download=1'
        unzip -d "$(dirname '{output.db_dir}')" '{params.db_zip}'
        """

rule run_deeparg_fna:
    input:
        contigs = get_assembly,
        db_dir = os.path.join(config['params']['db_dir'], 'deeparg')
    output:
        report = "results/{sample}/deeparg-fna/output.mapping.ARG",
        report_potential = "results/{sample}/deeparg-fna/output.mapping.potential.ARG",
        metadata = "results/{sample}/deeparg-fna/metadata.txt"
    message: "Running deeparg on {wildcards.sample} with contigs"
    log:
        "logs/deeparg-fna_{sample}.log"
    conda:
        "../envs/deeparg.yaml"
    params:
        out_dir = "results/{sample}/deeparg-fna",
        version = "1.0.4"
    shell:
        """
        mkdir -p '{params.out_dir}'
        # Note: default --arg-alignment-identity is 50, maybe increase to 90?
        deeparg predict --model LS --type nucl -i '{input.contigs}' -d '{input.db_dir}' -o '{params.out_dir}/output' >{log} 2>&1
        echo "--input_file_name '{input.contigs}' --analysis_software_version '{params.version}' --reference_database_version '{params.version}'" >{output.metadata}
        """

rule run_deeparg_fqs:
    input:
        read1 = get_read1, read2 = get_read2,
        db_dir = os.path.join(config['params']['db_dir'], 'deeparg')
    output:
        report = "results/{sample}/deeparg-fqs/output.mapping.ARG",
        report_potential = "results/{sample}/deeparg-fqs/output.mapping.potential.ARG",
        metadata = "results/{sample}/deeparg-fqs/metadata.txt"
    message: "Running deeparg on {wildcards.sample} with reads"
    log:
        "logs/deeparg-fqs_{sample}.log"
    conda:
        "../envs/deeparg.yaml"
    params:
        out_dir = "results/{sample}/deeparg-fqs",
        version = "1.0.4"
    shell:
        """
        mkdir -p '{params.out_dir}'
        deeparg short_reads_pipeline --forward_pe_file '{input.read1}' --reverse_pe_file '{input.read2}' -d '{input.db_dir}' --output_file '{params.out_dir}/output' >{log} 2>&1
        mv '{params.out_dir}/output.clean.deeparg.mapping.ARG' '{params.out_dir}/output.mapping.ARG'
        mv '{params.out_dir}/output.clean.deeparg.mapping.potential.ARG' '{params.out_dir}/output.mapping.potential.ARG'
        rm -f '{params.out_dir}/output.clean.deeparg'.*
        echo "--input_file_name '{input.read1}' --analysis_software_version '{params.version}' --reference_database_version '{params.version}'" >{output.metadata}
        """

rule hamronize_deeparg:
    input:
        report = "results/{sample}/deeparg-{sfx}/output.mapping.ARG",
        metadata = "results/{sample}/deeparg-{sfx}/metadata.txt"
    output:
        "results/{sample}/deeparg-{sfx}/hamronized_report.tsv"
    log:
        "logs/deeparg-{sfx}_{sample}_hamronize.log"
    conda:
        "../envs/hamronization.yaml"
    shell:
        "hamronize deeparg $(cat '{input.metadata}') '{input.report}' >{output}"
