$IMAGE="theiaide/theia"
$NAME="theia"
$DATA_DIR="theia_data"
$WORK_DIR="c:\Workspace"

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker volume create $DATA_DIR

docker run -d --init `
	--name=$NAME `
	--restart always `
    -p 3000:3000 `
	-v ${DATA_DIR}:/cached `
    -v ${WORK_DIR}:/workspace `
	$IMAGE 

write-host "Go to http://localhost:3000"
pause