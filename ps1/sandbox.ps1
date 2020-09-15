$IMAGE_TAG = "sandbox"
$BASE_IMG = "ubuntu:latest"
$NAME = "sandbox"
$USER = "docker"
$TERRAFORM_VER = "0.13.0" # https://www.terraform.io/downloads.html
$TERRAFORM_ZIP = "https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip"
$PACKAGES = "openssh-client openssl curl sudo unzip wget vim git docker-compose"
$HOME_DIR = "sbx_data" # Docker volume for the home directory
$DATA_DIR = $env:USERPROFILE + "\sandbox_data"
New-Item -ItemType Directory -Force -Path $DATA_DIR | Out-Null
$WORK_DIR = "D:\Workspace"

$cmdOutput = docker images -q $IMAGE_TAG
if ($cmdOutput.length -lt 4) {
	Add-Content DockerFile "FROM ${BASE_IMG}"
	Add-Content DockerFile "`n"
	Add-Content DockerFile "ARG DEBIAN_FRONTEND=noninteractive"
	Add-Content DockerFile "RUN groupadd ${USER}"
	Add-Content DockerFile "RUN apt-get -yq update && apt-get -yq install ${PACKAGES} && apt-get -yq autoremove"
	Add-Content DockerFile "RUN cd /tmp && wget --progress=bar:force --no-check-certificate ${TERRAFORM_ZIP} && \"
	Add-Content DockerFile "unzip terraform_${TERRAFORM_VER}_linux_amd64.zip && mv terraform /usr/local/bin/"
	Add-Content DockerFile "RUN useradd -rm -d /home/${USER} -s /bin/bash -g ${USER} -G sudo -u 1000 ${USER} -p `"`$(openssl passwd -1 ${USER})`""
	Add-Content DockerFile "RUN usermod -aG docker ${USER}"
	Add-Content DockerFile "#RUN chmod 666 /var/run/docker.sock"
	Add-Content DockerFile "RUN chown -R ${USER}:${USER} /home/${USER}"
	Add-Content DockerFile "RUN echo `"%sudo ALL=(ALL) NOPASSWD: ALL`" >> /etc/sudoers"
	Add-Content DockerFile "USER ${USER}"
	Add-Content DockerFile "WORKDIR /home/${USER}"
	docker build --tag=$IMAGE_TAG -f DockerFile .
	Remove-Item DockerFile
	docker volume create $HOME_DIR
}

write-host ""
write-host "${BASE_IMG} - ${NAME}"
write-host "  packages: ${PACKAGES} + terraform"
write-host "  /home/${USER} is preserved in a docker volume"
write-host "  /data is preserved in your userprofile directory ${DATA_DIR}"
write-host "  /workspace is a file system mount to ${WORK_DIR}"
write-host ""

# The container is ephemeral - If you install something, it will not persist unless stored in one of the volumes.
# Modify the data volumes to your needs. sudo will run passwordless.
# docker can be used to manage host containers. eg. docker pull <image> goes to the host docker.

docker run -it --rm `
	--name=${NAME} `
	-h ${NAME} `
	-v ${HOME_DIR}:/home/${USER} `
	-v ${DATA_DIR}:/data `
	-v ${WORK_DIR}:/workspace `
	-v /var/run/docker.sock:/var/run/docker.sock `
	$IMAGE_TAG bash
