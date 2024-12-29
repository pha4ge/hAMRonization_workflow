rule get_kmerresistance_db:
    output:
        # We do not mark species_db as a directory output because Snakemake would drop it on failure and it is a 20G download
        resfinder_db = directory(os.path.join(config['params']['db_dir'], 'kmerresistance', 'resfinder_db'))
    params:
        db_base = os.path.join(config['params']['db_dir'], 'kmerresistance'),
        res_db_version = config['params']['kmerresistance']['res_db_version'],
        species_db = os.path.join(config['params']['db_dir'], 'kmerresistance', 'kmerfinder_db')
    log:
        "logs/kmerresistance_db.log"
    conda:
        "../envs/kmerresistance.yaml"
    shell:
        """
        mkdir -p {params.db_base}
        # Species database is downloaded like this but is 20G and downloads
        # from the DTU FTP very slowly, so not going to support this feature
        # for now and just use a single type klebsiella genome for now
        #git clone --depth=1 https://bitbucket.org/genomicepidemiology/kmerfinder_db.git {params.species_db}
        #{params.species_db}/INSTALL.sh {params.species_db} bacteria latest
        mkdir -p {params.species_db}
        test -f '{params.species_db}/bacteria.name' ||
           wget -O- https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/240/185/GCF_000240185.1_ASM24018v2/GCF_000240185.1_ASM24018v2_genomic.fna.gz |
           gunzip -c - | tee '{params.species_db}/bacteria.fsa' | kma_index -Sparse ATG -i -- -o '{params.species_db}/bacteria'
        # Resistance database same as for resfinder
        git clone --depth=1 -b {params.res_db_version} https://bitbucket.org/genomicepidemiology/resfinder_db.git {output.resfinder_db}
        grep -Ev '^[[:space:]]*(#|$)' {output.resfinder_db}/config | cut -f1 | xargs -I@ cat {output.resfinder_db}/@.fsa | kma_index -i -- -o {output.resfinder_db}/kma_resfinder
        """

rule run_kmerresistance:
    input:
        read1 = get_read1,
        read2 = get_read2,
        resfinder_db = os.path.join(config['params']['db_dir'], 'kmerresistance', 'resfinder_db')
    output:
        report = "results/{sample}/kmerresistance/results.res",
        metadata = "results/{sample}/kmerresistance/metadata.txt"
    message: "Running rule run_kmerresistance on {wildcards.sample} with reads"
    log:
        "logs/kmerresistance_{sample}.log"
    conda:
        "../envs/kmerresistance.yaml"
    threads:
        config['params']['threads']
    params:
        output_folder = "results/{sample}/kmerresistance",
        kma_resfinder_db = os.path.join(config['params']['db_dir'], 'kmerresistance', 'resfinder_db', 'kma_resfinder'),
        species_db = os.path.join(config['params']['db_dir'], 'kmerresistance', 'kmerfinder_db', 'bacteria'),
        db_version = config['params']['kmerresistance']['res_db_version']
    shell:
        """
        zcat {input.read1} {input.read2} > {params.output_folder}/temp_all_reads.fq
        kmerresistance -i {params.output_folder}/temp_all_reads.fq -t_db {params.kma_resfinder_db} -s_db {params.species_db} -o {params.output_folder}/results > {log} 2>&1
        rm {params.output_folder}/temp_all_reads.fq
        kmerresistance -v 2>&1 | perl -p -e 's/KmerResistance-(.+)/--analysis_software_version $1/' > {output.metadata}
        echo "{params.db_version}" | perl -p -e 's/(.+)/--reference_database_version $1/' >> {output.metadata}
        """

rule hamronize_kmerresistance:
    input:
        read1 = get_read1,
        report = "results/{sample}/kmerresistance/results.res",
        metadata = "results/{sample}/kmerresistance/metadata.txt"
    output:
        "results/{sample}/kmerresistance/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize kmerresistance --input_file_name {input.read1} $(paste - - < {input.metadata}) {input.report} > {output}
        """

