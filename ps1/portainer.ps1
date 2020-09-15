$IMAGE="portainer/portainer-ce"
$NAME="portainer"
$DATA_DIR="portainer_data"

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker volume create $DATA_DIR

docker run -d `
	--name=$NAME `
	--restart always `
    -p 9000:9000 `
	-v /var/run/docker.sock:/var/run/docker.sock `
	-v ${DATA_DIR}:/data `
	$IMAGE 

write-host "Go to http://localhost:9000"
pause