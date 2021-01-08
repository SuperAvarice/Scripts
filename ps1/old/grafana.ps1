$IMAGE_TAG = "grafana-ubuntu"
$NAME="grafana"
$USER="docker"
$WORKSPACE="D:\Workspace"

$cmdOutput = docker images -q $IMAGE_TAG
if ($cmdOutput.length -lt 4) {
	Add-Content DockerFile "FROM grafana/grafana:latest-ubuntu"
	Add-Content DockerFile "LABEL `"Author`"=`"WonkoTheSane`""
	Add-Content DockerFile "LABEL description=`"Grafana Ubuntu with dev stuff `""
	Add-Content DockerFile "`n"
	Add-Content DockerFile "USER root"
	Add-Content DockerFile "ARG DEBIAN_FRONTEND=noninteractive`n"
	Add-Content DockerFile "RUN apt-get -yq update && \"
	Add-Content DockerFile "apt-get -yq install sudo wget vim git nodejs npm yarn && \"
	Add-Content DockerFile "apt-get -yq autoremove"
    Add-Content DockerFile "#RUN groupadd ${USER}"
	Add-Content DockerFile "RUN useradd -rm -d /home/${USER} -s /bin/bash -g ${USER} -G sudo -u 1000 ${USER} -p `"`$(openssl passwd -1 ${USER})`""
    Add-Content DockerFile "RUN chown -R ${USER}:${USER} /home/${USER}"
    Add-Content DockerFile "RUN echo `"%sudo ALL=(ALL) NOPASSWD: ALL`" >> /etc/sudoers"
    Add-Content DockerFile "USER ${USER}"
    Add-Content DockerFile "WORKDIR /home/${USER}"
	docker build --tag=$IMAGE_TAG -f DockerFile .
	Remove-Item DockerFile
}

write-host ""
write-host "Grafana:latest with mapped plugin directory"
write-host ""

docker stop $NAME
docker rm $NAME
docker run -it --rm `
	--name=${NAME} `
    -h ${NAME} `
    -p 3000:3000 `
	-v ${WORKSPACE}\grafana-plugins:/var/lib/grafana/plugins `
	-v ${WORKSPACE}\grafana-dev:/workspace `
	$IMAGE_TAG bash
