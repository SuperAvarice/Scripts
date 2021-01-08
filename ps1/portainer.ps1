$IMAGE="portainer/portainer-ce"
$NAME="portainer"
#$PASS="you_should_probably_change_this"
$PASS="y56s1Csn0wn1Hn05iZDFdLkZai3GIZIRwZFjgbdy2rJilu98I9"

docker pull $IMAGE
docker stop $NAME
docker rm $NAME

$PASS_HASH = (docker run --rm httpd:2.4-alpine htpasswd -nbB admin "$PASS")
$PASSWORD = $PASS_HASH.split(":")[1]

docker run -d `
	--name=$NAME `
	--restart always `
    -p 9000:9000 `
	-v /var/run/docker.sock:/var/run/docker.sock `
	$IMAGE --admin-password "$PASSWORD" -H unix:///var/run/docker.sock

write-host "Go to http://localhost:9000"
Write-Host "Admin Password: $PASS"
pause
