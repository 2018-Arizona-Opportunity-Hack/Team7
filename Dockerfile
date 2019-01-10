FROM debian

COPY rpubkey.asc /rpubkey.asc

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update

RUN apt-get install -y gnupg2 software-properties-common apt-transport-https curl libxml2-dev libgdal-dev texinfo

RUN apt-key add /rpubkey.asc &&\
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/debian stretch-cran35/' &&\
    apt-get update -y

RUN apt-get -y install r-base --allow-unauthenticated

RUN su - -c "R -e \"install.packages(c('shiny', 'shinydashboard', 'exams', 'rlist', 'knitr', 'RSAGA', 'pathological', 'ECharts2Shiny', 'rmarkdown'), repos = 'http://cran.rstudio.com/')\""

RUN curl -o shiny-server-1.5.9.923-amd64.deb https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb && dpkg -i shiny-server-1.5.9.923-amd64.deb && rm -rf /srv/shiny-server/*

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY app.R /srv/shiny-server/app.r

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
