#Set-ExecutionPolicy -ExecutionPolicy Unrestricted
$SCRIPT_PATH = split-path -parent $PSCommandPath

$IMAGE_TAG = "build-tool"
$BASE_IMG = "ubuntu:latest"
$NAME = "build_tool"
$USER = "docker"
$PACKAGES = "openssh-client openssl curl sudo unzip wget vim git docker-compose"

$SETUP_FILE = "${SCRIPT_PATH}\setup.ps1"
if (!(Test-Path $SETUP_FILE)) {
    Add-Content $SETUP_FILE "`$BASE_DIR `= `"D:\Workspace`""
}
. $SETUP_FILE

Set-Location "${BASE_DIR}"

$cmdOutput = docker images -q $IMAGE_TAG
if ($cmdOutput.length -lt 4) {
	Add-Content DockerFile "FROM ${BASE_IMG}"
	Add-Content DockerFile "`n"
	Add-Content DockerFile "ARG DEBIAN_FRONTEND=noninteractive"
	Add-Content DockerFile "RUN groupadd ${USER}"
	Add-Content DockerFile "RUN apt-get -yq update && apt-get -yq install ${PACKAGES} && apt-get -yq autoremove"
	Add-Content DockerFile "RUN useradd -rm -d /home/${USER} -s /bin/bash -g ${USER} -G sudo -u 1000 ${USER} -p `"`$(openssl passwd -1 ${USER})`""
	Add-Content DockerFile "RUN usermod -aG docker ${USER}"
	Add-Content DockerFile "RUN echo `"alias fix-docker='sudo chmod 666 /var/run/docker.sock'`" >> /home/${USER}/.bash_aliases"
	Add-Content DockerFile "RUN echo `"LS_COLORS=`$LS_COLORS:'di=0;36'; export LS_COLORS`" >> /home/${USER}/.bashrc"
	Add-Content DockerFile "RUN echo `"PS1='`${debian_chroot:+(`$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\`$ '`" >> /home/${USER}/.bashrc"
    Add-Content DockerFile "RUN echo `"fix-docker`" >> /home/${USER}/.bashrc"
    Add-Content DockerFile "RUN echo `"cd /workspace`" >> /home/${USER}/.bashrc"
	Add-Content DockerFile "RUN echo `"set background=dark`" >> /home/${USER}/.vimrc"
	Add-Content DockerFile "RUN chown -R ${USER}:${USER} /home/${USER}"
	Add-Content DockerFile "RUN echo `"%sudo ALL=(ALL) NOPASSWD: ALL`" >> /etc/sudoers"
	Add-Content DockerFile "USER ${USER}"
	Add-Content DockerFile "WORKDIR /home/${USER}"
	docker build --tag=$IMAGE_TAG -f DockerFile .
	Remove-Item DockerFile
}

write-host ""
write-host "${BASE_IMG} - ${NAME}"
write-host "  packages: ${PACKAGES}"
write-host "  /workspace is a file system mount to ${BASE_DIR}"
write-host ""

# The container is ephemeral - If you install something, it will not persist unless stored in one of the volumes.
# Modify the data volumes to your needs. sudo will run passwordless.
# docker can be used to manage host containers. eg. docker pull <image> goes to the host docker.

docker run -it --rm `
	--name=${NAME} `
	-h ${NAME} `
	-v ${BASE_DIR}:/workspace `
	-v /var/run/docker.sock:/var/run/docker.sock `
	$IMAGE_TAG bash
