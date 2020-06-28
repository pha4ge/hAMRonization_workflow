rule get_sstar_script:
    output:
        sstar = os.path.join(config['params']['binary_dir'], "c-SSTAR", "c-SSTAR")
    params:
        bin_dir = config['params']['binary_dir']
    shell:
        """
        cd {params.bin_dir}
        git clone https://github.com/chrisgulvik/c-SSTAR
        """

rule get_sstar_database:
    output:
        os.path.join(config['params']['db_dir'], "ResGANNOT_srst2.fasta")
    shell:
        """
        wget -O {output} https://raw.githubusercontent.com/tomdeman-bio/Sequence-Search-Tool-for-Antimicrobial-Resistance-SSTAR-/master/Latest_AR_database/ResGANNOT_srst2.fasta
        """

rule run_sstar:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        sstar = os.path.join(config['params']['binary_dir'], "c-SSTAR", "c-SSTAR"),
        resgannot_db = os.path.join(config['params']['db_dir'], "ResGANNOT_srst2.fasta")
    output:
        report = "results/{sample}/sstar/report.tsv"
    message: "Running rule run_sstar on {wildcards.sample} with contigs"
    log:
       "logs/sstar_{sample}.log"
    conda:
      "../envs/sstar.yaml"
    threads:
       config["params"]["threads"]
    params:
        outdir = 'results/{sample}/sstar'
    shell:
       """
       {input.sstar} -g {input.contigs} -d {input.resgannot_db} --outdir {params.outdir} > {output.report} 
       """
