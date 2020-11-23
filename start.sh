#!/bin/bash
# get environment
source /root/.bashrc

# start redis in background
redis-server &

# start postgres
pg_ctlcluster 11 main start

# wait for postgres to accept connections
while ! nc -z 127.0.0.1 5432
do
  echo "Waiting for postgres..."
  sleep 1 
done

# reset database only if it is the first time we start the container
if [ ! -f "/home/.initdone" ]; then
  echo "First run, resetting database"
  /usr/local/bin/otree resetdb --noinput && touch /home/.initdone
fi

# start otree production server
/usr/local/bin/otree runprodserver 8000
