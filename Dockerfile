FROM mysql
COPY survey-stack.sql /docker-entrypoint-initdb.d/

RUN apt install dirmngr --install-recommends
RUN apt install software-properties-common
RUN apt install apt-transport-https

RUN apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF'
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/debian stretch-cran35/'
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
