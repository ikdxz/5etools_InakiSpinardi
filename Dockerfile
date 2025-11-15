FROM jafner/5etools-docker
COPY . /usr/local/apache2/htdocs
WORKDIR /usr/local/apache2/htdocs
EXPOSE 80