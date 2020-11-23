## Dockerfile for running oTree in one container
depends on
- image redis:buster
- Postgres
- Python 3.7
- oTree
- your oTree-app

TESTED ON A SERVER RUNNNIG UBUNTU 18.04

**The following numerated steps ore required to get oTree running with your app.**
Those steps without numeration are optional.

### 1. preparation
1. copy all files from this repository into an empty directory of your choice
	- e.g. if you have git installed, browse to your directory and: 
```
git clone https://github.com/Sebaristoteles/otree_in_one_docker.git .
```
2. copy your otree app folder into the same directory
	- you can find examples here: https://github.com/oTree-org/oTree
	- files: you need the typical files as in the folder following the link above
	- folders: you need the folders "_static" and "_templates" and one of the example-folders with its content
3. get your oTree-app folder ready
	a) easy: name your oTree-app folder "otree_docker" (placed in the same folder as the files from this github project)
	b) open the Dockerfile and change "ENV OTREE_APP_FOLDER=..." to the name for your otree app folder (e.g. "my_app")
- in the Dockerfile you can optionally change other ENV variables that all relate to postgres (more notes in Dockerfile)
- in the Dockerfile you can optionally change the port that the otree prodserver will listen to later
- in the bashrc file you can optionally change the password that allows you to enter the Admin area "Session" in the oTree browser application (with username "admin")
	

	
### 2. Building image from dockerfile
browse to folder of the dockerfile and build image
```
#docker build -t image_name:version .
# e.g.
docker build -t otree:1.0 .

# if you do not have so much disk space, you could not store (cache) intermediate builds:
#docker build -t --no-cache otree:1.0 .
```


### 3. choose port
see all ports that are listening
```
netstat -tulpn | grep LISTEN
```
choose a free port that will be the server port mapped to the container, e.g. 8000



### 4. run container
create docker container from image
```
#docker run -it -d -p server_port_that_maps_to:listening_port_container --name container_name image_name
# e.g.
docker run -it -d -p 8000:8000 --name otree otree:1.0
```

On the first start, the database is reset. On subsequent starts of the same container, the database is not touched.



### 5. Using oTree directly on port
open the port in your shell
```
ufw status verbose
ufw allow 8000

# to delete firewall rules and port opening again:
#ufw status numbered
#ufw delete <number>
```
open browser to use app at "localhost:port_server_opened" 
(e.g. "my.webpage:8000" OR "IP-Address:8000" OR "localhost:8000")



### nginx configuration
go to your nginx configuration file and change accordingly:
https://otree-server-setup.readthedocs.io/en/latest/step5.html



### nginx redirecting from sub-directory to otree-app
- e.g. from 'my.webpage/otree' to container
- not working so far
TBD




### (Optional) Resetting the database in the docker container
```
# enter the container
docker exec -it otree /bin/bash

# reset database
otree resetdb
# -> confirm with y
```



### change the oTree-app within your docker container
in case you want to change the oTree-app but do not want to run the full image building again, 
you can change the oTree-app within in the container

```
# stop oTree server
docker stop otree
docker start otree
# -> alternatively, find a way to stop oTree within the container

# delete old content in oTree-app folder
docker exec -u root -it otree sh -c 'exec rm -r *'

# copy new oTree-app folder into docker container
# assuming you are in the mother-folder of your new oTree-app folder
docker cp otree otree:/home
```
after that you have to reset the database again and start the prodserver.

