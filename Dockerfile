FROM rocker/r-ver:3.6.1
RUN apt-get update && apt-get install -y  git-core imagemagick libcurl4-openssl-dev libgit2-dev libglpk-dev libgmp-dev libssh2-1-dev libssl-dev libxml2-dev make pandoc pandoc-citeproc zlib1g-dev && rm -rf /var/lib/apt/lists/*
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN R -e 'remotes::install_github("r-lib/remotes", ref = "97bbf81")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.2.1")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.5.0")'
RUN Rscript -e 'remotes::install_version("htmltools",upgrade="never", version = "0.5.0")'
RUN Rscript -e 'remotes::install_version("pkgload",upgrade="never", version = "1.0.2")'
RUN Rscript -e 'remotes::install_version("rmarkdown",upgrade="never", version = "2.1")'
RUN Rscript -e 'remotes::install_version("purrr",upgrade="never", version = "0.3.3")'
RUN Rscript -e 'remotes::install_version("dplyr",upgrade="never", version = "0.8.5")'
RUN Rscript -e 'remotes::install_version("lubridate",upgrade="never", version = "1.7.4")'
RUN Rscript -e 'remotes::install_version("stringr",upgrade="never", version = "1.4.0")'
RUN Rscript -e 'remotes::install_version("tidyr",upgrade="never", version = "1.0.2")'
RUN Rscript -e 'remotes::install_version("tsibble",upgrade="never", version = "0.8.6")'
RUN Rscript -e 'remotes::install_version("tidyquant",upgrade="never", version = "1.0.0")'
RUN Rscript -e 'remotes::install_version("quantmod",upgrade="never", version = "0.4-16")'
RUN Rscript -e 'remotes::install_version("timetk",upgrade="never", version = "0.1.3")'
RUN Rscript -e 'remotes::install_version("knitr",upgrade="never", version = "1.28")'
RUN Rscript -e 'remotes::install_version("kableExtra",upgrade="never", version = "1.1.0")'
RUN Rscript -e 'remotes::install_version("highcharter",upgrade="never", version = "0.7.0")'
RUN Rscript -e 'remotes::install_version("shinycssloaders",upgrade="never", version = "0.3")'
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
EXPOSE 80
CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0');library(acompanhacoes);run_app()"
