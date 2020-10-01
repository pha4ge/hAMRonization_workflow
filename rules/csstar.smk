rule get_csstar_script:
    output:
        csstar = os.path.join(config['params']['binary_dir'], "c-SSTAR", "c-SSTAR")
    params:
        bin_dir = config['params']['binary_dir']
    shell:
        """
        cd {params.bin_dir}
        git clone https://github.com/chrisgulvik/c-SSTAR
        """

rule get_csstar_database:
    output:
        os.path.join(config['params']['db_dir'], "ResGANNOT_srst2.fasta")
    shell:
        """
        wget -O {output} https://raw.githubusercontent.com/tomdeman-bio/Sequence-Search-Tool-for-Antimicrobial-Resistance-SSTAR-/master/Latest_AR_database/ResGANNOT_srst2.fasta
        """

rule run_csstar:
    input:
        contigs = lambda wildcards: _get_seq(wildcards, 'assembly'),
        csstar = os.path.join(config['params']['binary_dir'], "c-SSTAR", "c-SSTAR"),
        resgannot_db = os.path.join(config['params']['db_dir'], "ResGANNOT_srst2.fasta")
    output:
        report = "results/{sample}/csstar/report.tsv"
    message: "Running rule run_csstar on {wildcards.sample} with contigs"
    log:
       "logs/csstar_{sample}.log"
    conda:
      "../envs/csstar.yaml"
    threads:
       config["params"]["threads"]
    params:
        outdir = 'results/{sample}/csstar'
    shell:
       """
       {input.csstar} -g {input.contigs} -d {input.resgannot_db} --outdir {params.outdir} > {output.report} 2>{log}
       """
