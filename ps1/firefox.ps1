$IMAGE="jlesage/firefox"
$NAME="firefox"
$DATA="firefox-data"

docker pull $IMAGE
docker stop $NAME
docker rm $NAME

docker volume create $DATA
docker run -d --rm `
    --name=$NAME `
    -p 5800:5800 `
    -e DARK_MODE=1 `
    -e KEEP_APP_RUNNING=1 `
    -v ${DATA}:/config `
    $IMAGE
	
write-host "Go to http://localhost:5800/"
pause