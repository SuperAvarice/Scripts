$IMAGE="jlesage/firefox"
$NAME="firefox"
$VNCPASS="1yG46gsc" # Some 8 character password for the web interface

docker pull $IMAGE
docker stop $NAME
docker rm $NAME

docker run -d --rm `
    --name=$NAME `
    -p 5800:5800 `
    --shm-size 2g `
    -e VNC_PASSWORD=${VNCPASS} `
    -e DISPLAY_WIDTH=1920 `
    -e DISPLAY_HEIGHT=1200 `
    $IMAGE
	
write-host "Go to http://localhost:5800/?password=${VNCPASS}"
pause