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
        mkdir -p '{params.out_dir}/tmp'
        # Create symlinks to the reads in the output/tmp directory, because deeparg leaves behind huge
        # temporary files both in the (possibly read-only) input directory and in the output directory.
        ln -srft '{params.out_dir}/tmp' '{input.read1}' '{input.read2}'
        deeparg short_reads_pipeline -d '{input.db_dir}' \
          --forward_pe_file "{params.out_dir}/tmp/$(basename '{input.read1}')" \
          --reverse_pe_file "{params.out_dir}/tmp/$(basename '{input.read2}')" \
          --output_file '{params.out_dir}/tmp/output' >{log} 2>&1
        # Move the final outputs out of the tmp directory and rename to what they should be
        mv -f '{params.out_dir}/tmp/output.clean.deeparg.mapping.ARG' '{output.report}'
        mv -f '{params.out_dir}/tmp/output.clean.deeparg.mapping.potential.ARG' '{output.report_potential}'
        rm -rf '{params.out_dir}/tmp'
        # Write the metadata file for hamronizer
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
