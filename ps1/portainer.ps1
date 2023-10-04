$IMAGE="portainer/portainer-ce"
$NAME="portainer"
$DATA="portainer-data"
$PASS=-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

docker pull $IMAGE
docker stop $NAME
docker rm $NAME

$PASS_HASH = (docker run --rm httpd:2.4-alpine htpasswd -nbB admin "$PASS")
$PASSWORD = $PASS_HASH.split(":")[1]

docker volume create $DATA

docker run -d `
	--name=$NAME `
	--restart always `
    -p 9000:9000 `
	-v ${DATA}:/data `
	-v /var/run/docker.sock:/var/run/docker.sock `
	$IMAGE --admin-password "$PASSWORD" -H unix:///var/run/docker.sock

write-host "Go to http://localhost:9000"
Write-Host "Admin Password: $PASS"
pause
