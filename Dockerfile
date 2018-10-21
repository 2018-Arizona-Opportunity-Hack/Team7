FROM mysql
COPY survey-stack.sql /docker-entrypoint-initdb.d/

RUN apt-get update -y

RUN apt-get -y install dirmngr --install-recommends
RUN apt-get -y install software-properties-common
RUN apt-get -y install apt-transport-https

RUN apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF'
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/debian stretch-cran35/'
RUN apt-get update -y

RUN apt-get -y install r-base gdebi-core curl

RUN su - -c "R -e \"install.packages('shiny', repos = 'http://cran.rstudio.com/')\""
RUN su - -c "R -e \"install.packages('shinydashboard', repos='http://cran.rstudio.com/')\""
RUN su - -c "R -e \"install.packages('rlist', repos='http://cran.rstudio.com/')\""
RUN su - -c "R -e \"install.packages('knitr', repos='http://cran.rstudio.com/')\""
RUN su - -c "R -e \"install.packages('RSAGA', repos='http://cran.rstudio.com/')\""

RUN rm -rf /srv/shiny-server/*
COPY app.r /srv/shiny-server
COPY mock.csv /srv/shiny-server

RUN curl -o shiny-server-1.5.9.923-amd64.deb https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb

RUN dpkg -i shiny-server-1.5.9.923-amd64.deb
RUN service shiny-server restart
RUN service shiny-server enable
