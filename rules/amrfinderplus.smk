rule get_amrfinder_db:
    output:
        directory(os.path.join(config['params']['db_dir'], "amrfinderplus", "latest"))
    conda:
        "../envs/amrfinderplus.yaml"
    params:
        db_dir = os.path.join(config['params']['db_dir'], "amrfinderplus")
    log:
        "logs/amrfinderplus_db.log"
    shell:
        """
        amrfinder_update -d '{params.db_dir}' 2> {log}
        # Fix the 'latest' symlink to be relative, so it works from containers too
        ln -srfT "$(realpath '{params.db_dir}/latest')" '{params.db_dir}/latest'
        """

rule run_amrfinderplus:
    input:
        contigs = get_assembly,
        db_dir = os.path.join(config['params']['db_dir'], "amrfinderplus", "latest")
    output:
        report = "results/{sample}/amrfinderplus/report.tsv",
        metadata = "results/{sample}/amrfinderplus/metadata.txt"
    message: "Running rule run_amrfinderplus on {wildcards.sample} with contigs"
    log:
        "logs/amrfinderplus_{sample}.log"
    conda:
        "../envs/amrfinderplus.yaml"
    params:
        species = branch(get_species, then=lambda w: get_species(w).replace(' ','_'))
    threads:
        config["params"]["threads"]
    shell:
        """
        [ -n '{params.species}' ] && amrfinder --list_organisms -d {input.db_dir} 2>/dev/null | fgrep -q '{params.species}' && SPECIES_OPT='-O {params.species}' || SPECIES_OPT=''
        amrfinder -n '{input.contigs}' $SPECIES_OPT -o '{output.report}' -d '{input.db_dir}' >{log} 2>&1
        sed -En 's/^Software version: (.*)$/--analysis_software_version \\1/p;s/^Database version: (.*)$/--reference_database_version \\1/p' {log} | sort -u >{output.metadata}
        """

rule hamronize_amrfinderplus:
    input:
        contigs = get_assembly,
        report = "results/{sample}/amrfinderplus/report.tsv",
        metadata = "results/{sample}/amrfinderplus/metadata.txt"
    output:
        "results/{sample}/amrfinderplus/hamronized_report.tsv"
    log:
        "logs/amrfinderplus_{sample}_hamronize.log"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize amrfinderplus --input_file_name {input.contigs} $(cat {input.metadata}) {input.report} > {output} 2>{log}
        """
