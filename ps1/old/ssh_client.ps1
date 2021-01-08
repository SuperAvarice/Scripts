
$IMAGE_TAG = "ssh-client"
$NAME="sshclient"

$SSH_DIR="ssh_data"
#$SSH_DIR=$env:USERPROFILE
#$SSH_DIR += "\.ssh_docker"
#New-Item -ItemType Directory -Force -Path $SSH_DIR | Out-Null

$cmdOutput = docker images -q $IMAGE_TAG
if ($cmdOutput.length -lt 4) {
	Add-Content DockerFile "FROM ubuntu:latest"
	Add-Content DockerFile "LABEL `"Author`"=`"WonkoTheSane`""
	Add-Content DockerFile "LABEL description=`"Ubuntu with ssh client`""
	Add-Content DockerFile "`n"
	Add-Content DockerFile "ARG DEBIAN_FRONTEND=noninteractive`n"
	Add-Content DockerFile "RUN apt-get -yq update && \"
	Add-Content DockerFile "apt-get -yq install openssh-client && \"
	#Add-Content DockerFile "apt-get -yq install curl && \"
	Add-Content DockerFile "apt-get -yq autoremove"
	docker build --tag=$IMAGE_TAG -f DockerFile .
	Remove-Item DockerFile
	docker volume create $SSH_DIR
}

write-host ""
write-host "Ubuntu ssh client"
write-host ""

docker run -it --rm `
	--name=${NAME} `
    -h ${NAME} `
	-v ${SSH_DIR}:/root/.ssh `
	$IMAGE_TAG bash