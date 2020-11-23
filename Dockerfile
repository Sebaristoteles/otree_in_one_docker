FROM redis:buster
MAINTAINER Sebastian Geschonke sebastian.geschonke@hu-berlin.de

RUN echo "Building Otree Image" 


# --------------------------------------------------- set other environment variables (optional to change)
# ENV variables are also available during the build, 
# as soon as you introduce them with an ENV instruction. 
# However, unlike ARG, they are also accessible by containers started from the final image. 
# ENV values can be overridden when starting a container.

# cannot call it "otree", because otree won't let us create a project folder called "otree"
ENV OTREE_APP_FOLDER=otree_docker


# these variables all relate to the postgres database
# a change of "POSTGRES_DATABASE" requires an adjustment in bashrc (DATABASE_URL)
ENV POSTGRES_DATABASE=django_test					
ENV OTREE_USER=otree_user
ENV OTREE_PW='mydbpassword'

# choose port that otree prodserver will listen to
ENV PORT_OF_OTREE=8000


# --------------------------------------------------- install packages
#RUN apt-get install -y apt-utils
# -> in Ubuntu
# Debian raises warning and wants:
RUN apt-get install -y apt

# get apt-utils by following:
# https://github.com/phusion/baseimage-docker/issues/319
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils


# https://linuxize.com/post/how-to-install-python-3-7-on-ubuntu-18-04/
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common netcat

# deadsnake repository for multiple python versions on the system
# RUN add-apt-repository ppa:deadsnakes/ppa
# -> just in case FROM=ubuntu:18.04

# https://otree.readthedocs.io/en/latest/server/ubuntu.html
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3.7
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-dev libpq-dev postgresql postgresql-contrib nano

#RUN apt-get install -y redis-server
# usually installing redis asks to choose a location:
# How to do this in a dockerfile?
## Europe
## Berlin

# https://redis.io/topics/quickstart
# install from other source
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
#RUN apt install wget

#WORKDIR /home
#wget http://download.redis.io/redis-stable.tar.gz
#RUN tar xvzf redis-stable.tar.gz
#WORKDIR redis-stable
#RUN make

# for otree:
# get pip3 for python 3.7
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip
RUN DEBIAN_FRONTEND=noninteractive python3.7 -m pip install pip && \
    python3.7 -m pip install --upgrade pip && \
    pip3.7 install -U otree

# clean cache to reduce space usage
RUN apt-get clean

# --------------------------------------------------- configure postgres
# (https://stackoverflow.com/questions/31645550/postgresql-why-psql-cant-connect-to-server)
#RUN pg_ctlcluster 11 main start
#RUN pg_lsclusters
# -> does not run this way (but status can be switched on, if later in running container done)

# from
# https://docs.docker.com/engine/examples/postgresql_service/
USER postgres

# create user and set superuser pw (maybe just normal user required)
RUN /etc/init.d/postgresql start &&\
        psql --command "CREATE USER $OTREE_USER WITH SUPERUSER PASSWORD '$OTREE_PW';" &&\
        createdb -O $OTREE_USER $POSTGRES_DATABASE

# grant privileges on database to user (does not work but might not be necessary as superuser?)
#RUN /etc/init.d/postgresql start &&\
#       psql --command "RUN GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DATABASE TO $OTREE_USER;"


# switch back to root user
USER root


# --------------------------------------------------- configure redis
# not necessary: already done with FROM



# --------------------------------------------------- configure otree
## create directory for otree app
WORKDIR /home/otree


## copy app
COPY $OTREE_APP_FOLDER /home/otree


## install requirements
RUN pip3.7 install -r /home/otree/requirements.txt
# works in Debian Buster, fails for Ubuntu 18.04 (psycopg2)
# in Ubuntu 18.04:
#pip3.7 install psycopg2-binary
# (https://stackoverflow.com/questions/5420789/how-to-install-psycopg2-with-pip-on-python)


## reset database
#RUN DEBIAN_FRONTEND=noninteractive otree resetdb
#-> fails due to interactive question in python module
# workaround by using a little change in  resetdb.py: no interaction
#COPY resetdb.py /usr/local/lib/python3.7/dist-packages/otree/management/commands/
#RUN otree resetdb
# -> scrapped since the database still has to get reset once container runs

## run production server
# in start.sh script does not work
# see readme for further instructions

## change ~/.bashrc by using a prepared standard script with slight changes according to
# https://otree.readthedocs.io/en/latest/server/ubuntu.html
# find ~/.bashrc in your home (if root) or user directory:
# ls -la ~/ | more
WORKDIR /home
#COPY .bashrc ~/.bashrc # -> direct copying does not work and creates "~" folder
COPY bashrc bashrc
RUN mv bashrc ~/.bashrc

WORKDIR /home/otree

# --------------------------------------------------- Expose ports and start processes
# expose ports of otree, postgres and redis (necessary for the latter two?)
EXPOSE $PORT_OF_OTREE 6379 5432

#CMD redis-server && pg_ctlcluster 11 main start
# -> Dockerfile CMD cannot run multiple commands, especially if they are started interactively
#https://stackoverflow.com/questions/23692470/why-cant-i-use-docker-cmd-multiple-times-to-run-multiple-services
# alternative: wrapper script
#https://docs.docker.com/config/containers/multi-service_container/
#https://stackoverflow.com/questions/19948149/can-i-run-multiple-programs-in-a-docker-container

COPY start.sh /home/start.sh
CMD bash /home/start.sh

