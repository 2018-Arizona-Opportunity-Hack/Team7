FROM mysql
COPY survey-stack.sql /docker-entrypoint-initdb.d/

RUN sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" &gt;&gt; /etc/apt/sources.list'
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
RUN gpg -a --export E084DAB9 | sudo apt-key add -
RUN sudo apt-get update
RUN sudo apt-get -y install r-base libapparmor1 libcurl4-gnutls-dev libxml2-dev libssl-dev gdebi-core

RUN sudo su - -c "R -e \"install.packages('shiny', repos = 'http://cran.rstudio.com/')\""
RUN sudo su - -c "R -e \"install.packages('shinydashboard', repos='http://cran.rstudio.com/')\""
RUN sudo su - -c "R -e \"install.packages('rlist', repos='http://cran.rstudio.com/')\""
RUN sudo su - -c "R -e \"install.packages('knitr', repos='http://cran.rstudio.com/')\""
RUN sudo su - -c "R -e \"install.packages('RSAGA', repos='http://cran.rstudio.com/')\""

RUN curl -o shiny-server-1.5.9.923-amd64.deb https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb

RUN gdebi shiny-server-1.5.9.923-amd64.deb
RUN reload shiny-server
