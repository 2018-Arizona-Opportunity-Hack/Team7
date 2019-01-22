FROM debian

COPY rpubkey.asc /rpubkey.asc

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update

RUN apt-get install -y gnupg2 software-properties-common apt-transport-https curl libxml2-dev libgdal-dev texinfo texlive

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -

RUN apt-get install -y nodejs

RUN apt-key add /rpubkey.asc &&\
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/debian stretch-cran35/' &&\
    apt-get update -y

RUN apt-get -y install r-base --allow-unauthenticated

RUN su - -c "R -e \"install.packages(c('shiny', 'shinydashboard', 'exams', 'rlist', 'knitr', 'RSAGA', 'pathological', 'ECharts2Shiny', 'DT', 'rmarkdown'), repos = 'http://cran.rstudio.com/')\""

RUN curl -o shiny-server-1.5.9.923-amd64.deb https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb && dpkg -i shiny-server-1.5.9.923-amd64.deb && rm -rf /srv/shiny-server/*

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY app.R /srv/shiny-server/app.r

RUN mkdir /auth-proxy
COPY auth-proxy/package.json /auth-proxy/package.json
COPY auth-proxy/index.js /auth-proxy/index.js
COPY auth-proxy/static/index.html /auth-proxy/static/index.html
COPY auth-proxy/static/index.js auth-proxy/static/index.js
COPY auth-proxy/static/index.css auth-proxy/static/index.css

RUN cd /auth-proxy && npm install

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
