rule get_resfinder_db:
    output:
        res_db = directory(os.path.join(config['params']['db_dir'], "resfinder_db")),
        point_db = directory(os.path.join(config['params']['db_dir'], "pointfinder_db")),
        disinf_db = directory(os.path.join(config['params']['db_dir'], "disinfinder_db"))
    log:
        "logs/resfinder_db.log"
    conda:
        "../envs/resfinder.yaml"
    params:
        res_ver = config['params']['resfinder']['res_db_version'],
        point_ver = config['params']['resfinder']['point_db_version'],
        disinf_ver = config['params']['resfinder']['disinf_db_version']
    shell:
        """
        {{ set -euo pipefail
        git clone --depth=1 -b {params.res_ver} https://bitbucket.org/genomicepidemiology/resfinder_db.git {output.res_db}
        git clone --depth=1 -b {params.point_ver} https://bitbucket.org/genomicepidemiology/pointfinder_db.git {output.point_db}
        git clone --depth=1 -b {params.disinf_ver} https://bitbucket.org/genomicepidemiology/disinfinder_db.git {output.disinf_db}
        grep -Ev '^\s*(#|$)' {output.res_db}/config    | cut -f1 | xargs -I@ kma_index -i {output.res_db}/@.fsa -o {output.res_db}/@
        grep -Ev '^\s*(#|$)' {output.point_db}/config  | cut -f1 | xargs -I@ sh -c 'kma_index -i {output.point_db}/@/*.fsa -o {output.point_db}/@/@'
        grep -Ev '^\s*(#|$)' {output.disinf_db}/config | cut -f1 | xargs -I@ kma_index -i {output.disinf_db}/@.fsa -o {output.disinf_db}/@
        }} >{log} 2>&1
        """

rule run_resfinder:
    input:
        # ResFinder can take a reads pair or an assembly (or a single nanopore reads file, ignored for now);
        # We might normally prefer reads for accuracy, but pick assembly first for uniformity in the workflow
        inputs = get_assembly_or_reads,
        res_db = os.path.join(config['params']['db_dir'], "resfinder_db"),
        point_db = os.path.join(config['params']['db_dir'], "pointfinder_db"),
        disinf_db = os.path.join(config['params']['db_dir'], "disinfinder_db")
    output:
        report = "results/{sample}/resfinder/data_resfinder.json",
    message: "Running rule run_resfinder on {wildcards.sample}"
    log:
        "logs/resfinder_{sample}.log"
    conda:
        "../envs/resfinder.yaml"
    threads:
        config['params']['threads']
    params:
        # Depending on whether we have a read pair or an assembly, compose the appropriate ResFinder argument
        inputs_arg = branch(get_assembly,
            then = lambda w: "-ifa '{}'".format(get_assembly(w)),
            otherwise = lambda w: "-ifq '{0}' '{1}'".format(get_read1(w), get_read2(w))),
        # PointFinder requires a species, but will not error out if it is not in its database.
        species = branch(get_species, then=get_species, otherwise="Unknown"),
        outdir = "results/{sample}/resfinder"
    shell:
        """
        {{ set -euo pipefail
        mkdir -p '{params.outdir}'
        run_resfinder.py --acquired --point --disinfectant --species '{params.species}' --ignore_missing_species \
            -db_res '{input.res_db}' -db_point '{input.point_db}' -db_disinf '{input.disinf_db}' \
            {params.inputs_arg} -j '{output.report}' -o '{params.outdir}'
        }} >{log} 2>&1
        """

rule hamronize_resfinder:
    input:
        report = "results/{sample}/resfinder/data_resfinder.json",
    output:
        "results/{sample}/resfinder/hamronized_report.tsv"
    log:
        "logs/resfinder_{sample}_harmonize.log"
    conda:
        "../envs/hamronization.yaml"
    shell:
        "hamronize resfinder {input.report} >{output} 2>{log}"
