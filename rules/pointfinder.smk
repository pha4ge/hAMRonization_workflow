rule get_pointfinder_db:
    output: 
        pointfinder_db = directory(os.path.join(config["params"]["db_dir"], "pointfinder_db"))
    shell:
        """
        git clone https://bitbucket.org/genomicepidemiology/pointfinder_db {output.pointfinder_db}
        """

rule get_pointfinder_script:
    output:
        pointfinder = os.path.join(config['params']['binary_dir'], "pointfinder", "PointFinder.py")
    params:
        binary_dir = config["params"]["binary_dir"]
    shell:
        """
        cd {params.binary_dir}
        git clone https://bitbucket.org/genomicepidemiology/pointfinder.git --recursive
        
        # tidy up shebang
        sed -i "s|env python3$|env python|" pointfinder/PointFinder.py
        chmod +x pointfinder/PointFinder.py
        """

rule run_pointfinder:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        pointfinder_db = os.path.join(config["params"]["db_dir"], "pointfinder_db"),
        pointfinder_script = os.path.join(config['params']['binary_dir'], "pointfinder", "PointFinder.py")
    output:
        raw_report = "results/{sample}/pointfinder/GCF_blastn_results.tsv",
        report = "results/{sample}/pointfinder/report.tsv"
    message: "Running rule run_pointfinder on {wildcards.sample} with contigs"
    log:
       "logs/pointfinder_{sample}.log"
    conda:
        "../envs/pointfinder.yaml"
    threads:
        config["params"]["threads"]
    params:
        species = config["params"]["pointfinder"]["species"],
        output_tmp_dir = "results/{sample}/pointfinder/tmp"
    shell:
        """
        python {input.pointfinder_script} -i {input.contigs} -p {input.pointfinder_db} -s {params.species} -m blastn -m_p $(which blastn) -o results/{wildcards.sample}/pointfinder > {log} 2>&1
        cp {output.raw_report} {output.report}
        rm -rf {params.output_tmp_dir}
        """
