FROM mysql
COPY survey-stack.sql /docker-entrypoint-initdb.d/

RUN sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
RUN gpg -a --export E084DAB9 | apt-key add -
RUN apt-get update
RUN apt-get -y install r-base gdebi-core

RUN su - -c "R -e \"install.packages('shiny', repos = 'http://cran.rstudio.com/')\""
RUN su - -c "R -e \"install.packages('shinydashboard', repos='http://cran.rstudio.com/')\""
RUN su - -c "R -e \"install.packages('rlist', repos='http://cran.rstudio.com/')\""
RUN su - -c "R -e \"install.packages('knitr', repos='http://cran.rstudio.com/')\""
RUN su - -c "R -e \"install.packages('RSAGA', repos='http://cran.rstudio.com/')\""

RUN curl -o shiny-server-1.5.9.923-amd64.deb https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb

RUN gdebi shiny-server-1.5.9.923-amd64.deb
RUN reload shiny-server
