$IMAGE="jlesage/firefox"
$NAME="firefox"
$DATA_DIR="firefox_data"

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker volume create $DATA_DIR

docker run -d `
    --name=$NAME `
    -p 5800:5800 `
    --shm-size 2g `
    -v ${DATA_DIR}:/config:rw `
    -e DISPLAY_WIDTH=1920 `
    -e DISPLAY_HEIGHT=960 `
    $IMAGE
	
write-host "Go to http://localhost:5800"
pause