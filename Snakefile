rule targets:
    input:
        "data/USW00013897.dly",
        "data/composite_dly.tsv"

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

rule get_regions_years:
    input:
        r_script = "code/get_regions_years.R",
        data = "data/USW00013897.dly"
    output:
        "data/composite_dly.tsv",
        "visuals/world_drought.png"
    conda:
        "environment.yml"
    shell:
        """
        {input.r_script}
        """

rule render_index:
    input:
        rmd = "index.Rmd",
        png = "visuals/world_drought.png"
    output:
        "index.html"
    conda:
        "environment.yml"
    shell:
        """
        R -e "library(rmarkdown); render('{input.rmd}')"
        """

        
