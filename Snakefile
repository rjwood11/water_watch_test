rule targets:
    input:
        "data/USW00013897.dly",

rule get_all_archive:
    input:
        script = "code/get_ghcnd_data.bash"
    output:
        "data/USW00013897.dly"
    conda:
        "environment.yml"
    params:
        file = "all/USW00013897.dly"
    shell:
        """
        {input.script} {params.file}
        """



        
