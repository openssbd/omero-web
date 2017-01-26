################################################################################
#
# Dockerfile for developing OMERO environment
#
# See omero web sites about OMERO.server installation on Ubuntu 14.04 and Ice 3.5 for details:
# https://www.openmicroscopy.org/site/support/omero5.2/sysadmins/unix/server-linux-walkthrough.html
#

FROM ubuntu:14.04
MAINTAINER Yukako Tohsato <yukako.tohsato@riken.jp>

COPY setup/dot.emacs /root/.emacs
COPY setup/settings.env /root/settings.env

RUN echo 'root:root' | chpasswd &&\
    cat /root/settings.env >> /root/.bashrc &&\
    rm /root/settings.env &&\
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime &&\
    locale-gen ja_JP.UTF-8 &&\
    update-locale LANG=ja_JP.UTF-8 &&\
    apt-get update &&\
    apt-get -y install emacs24 emacs24-el   

ENV LC_ALL ja_JP.UTF-8

################################################################################
#
# OMEROサーバーの環境設定
#

COPY setup/requirements_omero.txt requirements_omero.txt
COPY setup/omeroserver /etc/init.d/omero    

# software-properties-common は add-apt-repository と apt-transport-https を入れるために必要
RUN apt-get -y install unzip wget curl software-properties-common &&\
    add-apt-repository -y ppa:openjdk-r/ppa &&\
    apt-get update &&\
    apt-get -y install openjdk-8-jre &&\
    apt-get update &&\
    apt-get -y install python-matplotlib python-numpy python-pip python-scipy python-tables python-virtualenv python-psycopg2 &&\
    apt-get -y install libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev &&\
    wget https://www.openmicroscopy.org/site/support/omero5.2/_downloads/requirements.txt &&\
    pip install --upgrade -r requirements.txt &&\
    rm requirements.txt &&\
    pip install -r requirements_omero.txt &&\
    rm requirements_omero.txt &&\
    apt-get -y install ice-services python-zeroc-ice &&\
    chmod a+x /etc/init.d/omero &&\
    update-rc.d -f omero remove &&\
    update-rc.d -f omero defaults 98 02

### add omero user ###
RUN useradd -m -d /OMERO -s /bin/bash omero &&\
    echo 'omero:omero' | chpasswd &&\
    echo 'omero ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER omero
WORKDIR /OMERO

ENV OMERO_USER="omero" \
    OMERO_SERVER="/OMERO/OMERO.server" \
    OMERO_DB_USER="db_user" \
    OMERO_DB_PASS="db_password" \
    OMERO_DB_NAME="omero_database" \
    OMERO_DATA_DIR="/OMERO/OMERO.data" \
    OMERO_ROOT_PASS="root_password" \
    OMERO_WEB_PORT=80 \
    PGPASSWORD=${OMERO_DB_PASS} \
    PATH=${OMERO_SERVER}/bin:/OMERO/bin:$PATH \
    PYTHONPATH=${OMERO_SERVER}/lib/python

COPY setup/dot.emacs /OMERO/.emacs
COPY setup/settings.env /OMERO/settings.env

RUN cat /OMERO/settings.env >> /OMERO/.bashrc &&\
    rm /OMERO/settings.env

RUN wget http://downloads.openmicroscopy.org/omero/5.2.7/artifacts/OMERO.server-5.2.7-ice35-b40.zip &&\
    unzip -q OMERO.server-5.2.7-ice35-b40.zip &&\
    ln -s OMERO.server-5.2.7-ice35-b40 OMERO.server &&\
    rm OMERO.server-5.2.7-ice35-b40.zip

RUN ${OMERO_SERVER}/bin/omero config set omero.db.host "localhost" &&\
    ${OMERO_SERVER}/bin/omero config set omero.db.user ${OMERO_DB_USER} &&\
    ${OMERO_SERVER}/bin/omero config set omero.db.pass ${OMERO_DB_PASS} &&\
    ${OMERO_SERVER}/bin/omero config set omero.db.name ${OMERO_DB_NAME} &&\
    ${OMERO_SERVER}/bin/omero config set omero.data.dir ${OMERO_DATA_DIR} &&\
    ${OMERO_SERVER}/bin/omero config set omero.web.public.enabled True &&\
    ${OMERO_SERVER}/bin/omero config set omero.web.public.user public_data &&\
    ${OMERO_SERVER}/bin/omero config set omero.web.public.password public_data &&\
    ${OMERO_SERVER}/bin/omero config set omero.sessions.timeout 600000 &&\
    ${OMERO_SERVER}/bin/omero config set omero.application_server.port 4080 &&\
    ${OMERO_SERVER}/bin/omero config set omero.web.prefix "/image" &&\
    ${OMERO_SERVER}/bin/omero config set omero.web.static_url "/image/static/" &&\
    ${OMERO_SERVER}/bin/omero config set omero.web.server_list '[["localhost", 4064, "image"]]' &&\
    ${OMERO_SERVER}/bin/omero config set omero.web.application_server wsgi-tcp

COPY setup/omero_start.sh /OMERO/bin/start.sh
COPY setup/omero_stop.sh /OMERO/bin/stop.sh
COPY setup/testOmero.py /OMERO/

RUN ${OMERO_SERVER}/bin/omero web config nginx > /OMERO/omero.conf.tmp &&\
    sudo chown -R omero.omero /OMERO

USER root

################################################################################
#
# SETUP PostgreSQL
#

WORKDIR /postgres

ENV PG_VERSION 9.4
ENV PG_PASS postgres

# 0: Docker内部に空データを作る
# 1: Docker内部にdumpデータを作る
# 2: データを永続化し変更した状態を維持する
ENV PG_DATA_FLG 1

RUN apt-get -y install apt-transport-https &&\
    add-apt-repository -y "deb https://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" &&\
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
    apt-get update &&\
    apt-get -y install postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} &&\
    echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/${PG_VERSION}/main/pg_hba.conf &&\
    echo "listen_addresses='*'" >> /etc/postgresql/${PG_VERSION}/main/postgresql.conf

COPY setup/omero_backup.sh /postgres/omero_backup.sh
COPY setup/sql/omero_database_init.pg_dump setup/sql/omero_database_sample.pg_dump /postgres/

RUN chown -R postgres.postgres /postgres

COPY setup/OMERO.data.sample /OMERO/OMERO.data.sample/

RUN if [ ${PG_DATA_FLG} -eq "0" ]; \
then \
    /etc/init.d/postgresql start &&\
    su postgres sh -c "psql --command \"ALTER USER postgres with PASSWORD ""'""${PG_PASS}""'"";\"" &&\
    su postgres sh -c "psql --command \"CREATE USER ${OMERO_DB_USER} WITH SUPERUSER PASSWORD ""'""${OMERO_DB_PASS}""'"";\"" &&\
    su postgres sh -c "psql --command \"CREATE DATABASE ${OMERO_DB_NAME} WITH OWNER ${OMERO_DB_USER} TEMPLATE template0 ENCODING 'UTF8';\"" &&\
    su postgres sh -c "pg_restore -Fc -d ${OMERO_DB_NAME} /postgres/omero_database_init.pg_dump" &&\
    mkdir -p /OMERO/OMERO.data && chown -R omero.omero /OMERO/OMERO.data ; \
fi

RUN if [ ${PG_DATA_FLG} -eq "1" ]; \
then \
    /etc/init.d/postgresql start &&\
    su postgres sh -c "psql --command \"ALTER USER postgres with PASSWORD ""'""${PG_PASS}""'"";\"" &&\
    su postgres sh -c "psql --command \"CREATE USER ${OMERO_DB_USER} WITH SUPERUSER PASSWORD ""'""${OMERO_DB_PASS}""'"";\"" &&\
    su postgres sh -c "psql --command \"CREATE DATABASE ${OMERO_DB_NAME} WITH OWNER ${OMERO_DB_USER} TEMPLATE template0 ENCODING 'UTF8';\"" &&\
    su postgres sh -c "pg_restore -Fc -d ${OMERO_DB_NAME} /postgres/omero_database_sample.pg_dump" &&\
    mv /OMERO/OMERO.data.sample /OMERO/OMERO.data && chown -R omero.omero /OMERO/OMERO.data ; \
fi

RUN if [ ${PG_DATA_FLG} -eq "2" ]; \
then \
    /etc/init.d/postgresql start ; \
fi

################################################################################
#
# SETUP Nginx
#

RUN apt-get -y install nginx &&\
    rm /etc/nginx/sites-enabled/default &&\
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.org &&\
    cp /OMERO/omero.conf.tmp /etc/nginx/sites-available/omero-web &&\
    ln -s /etc/nginx/sites-available/omero-web /etc/nginx/sites-enabled/ &&\
    rm /usr/share/nginx/html/index.html

COPY setup/nginx.conf /etc/nginx/nginx.conf

################################################################################
#
# SETUP services
#

COPY setup/start.sh setup/stop.sh /

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Nginx: 80, PostgreSQL: 5432, OMERO: 4063, 4064, 4080
EXPOSE 80 5432 4063 4064 4080

CMD /bin/bash /start.sh && tail -f /dev/null
