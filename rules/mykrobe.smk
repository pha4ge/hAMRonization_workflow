rule run_mykrobe:
    input:
        read1 = get_read1,
        read2 = get_read2
    output:
        report = "results/{sample}/mykrobe/report.json"
    message: "Running rule run_mykrobe on {wildcards.sample} with reads"
    log:
        "logs/mykrobe_{sample}.log"
    conda:
        "../envs/mykrobe.yaml"
    threads:
        config["params"]["threads"]
    params:
        species = get_species,
        skel_dir = "results/{sample}/mykrobe/skels",
        tmp_dir = "results/{sample}/mykrobe/tmp"
    shell:
        """
        mkdir -p $(dirname {output.report})
        echo '{{}}' >{output.report}  # create empty JSON report by default to flag that Mykrobe found nothing
        if [ -z '{params.species}' ]; then
          echo "Not running Mykrobe: it requires the species of the organism"
        else
          # map species to mykrobe-supported species code (see output of: mykrobe panels describe)
          declare -rA species_map=(
            'Mycobacterium tuberculosis' tb
            'Staphylococcus aureus'      staph
            'Shigella sonnei'            sonnei
          ) # ignore Mykrobe's typhi and paratyphiB because we don't have that detail
          myk_species=${{species_map[{params.species}]:-}}
          if [ -z "$myk_species" ]; then
            echo "Not running Mykrobe: it doesn't support {params.species}"
          else
            rm -f {output.report}  # remove as it is now up to mykrobe to write it or else fail
            mykrobe predict -s {wildcards.sample} -S $myk_species -1 {input.read1} {input.read2} --skeleton_dir {params.skel_dir} --threads {threads} --format json --output {output.report} --tmp {params.tmp_dir}/
            rm -rf {params.skel_dir} {params.tmp_dir}
          fi
        fi >{log} 2>&1
        """

rule hamronize_mykrobe:
    input:
        report = "results/{sample}/mykrobe/report.json",
    output:
        "results/{sample}/mykrobe/hamronized_report.tsv"
    log:
        "logs/mykrobe_{sample}_hamronize.log"
    conda:
        "../envs/hamronization.yaml"
    shell:
        "hamronize mykrobe {input.report} >{output} 2>{log}"
