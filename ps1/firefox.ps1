$IMAGE="jlesage/firefox"
$NAME="firefox"
$VNCPASS= -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})

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