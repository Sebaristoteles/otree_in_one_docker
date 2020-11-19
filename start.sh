# start first application
redis-server &
P1=$!
# start second application
pg_ctlcluster 11 main start &
P2=$!
# start third application
#otree prodserver 8000 &
#P3=$!
# -> did not work starting this way (even not with shell script later, just from inside the container)
wait $P1 $P2
#$P3
