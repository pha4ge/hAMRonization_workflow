rule run_mykrobe:
    input:
        read1 = lambda wildcards: _get_seq(wildcards, 'read1'),
        read2 = lambda wildcards: _get_seq(wildcards, 'read2')
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
        tmp = "results/{sample}/mykrobe/tmp/",
        skel_dir = "results/{sample}/mykrobe/skels",
        tmp_dir = "results/{sample}/mykrobe/tmp"
    shell:
       """
       mykrobe predict {wildcards.sample} tb -1 {input.read1} {input.read2} --skeleton_dir {params.skel_dir} --threads {threads} --format json --output {output.report} --tmp {params.tmp} > {log} 2>&1
       rm -rf {params.skel_dir} {params.tmp_dir}
       """
