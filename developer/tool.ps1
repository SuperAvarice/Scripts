# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass

 # Windows Podman Desktop installed with Docker Compatibility mode, rootless.

$VARS_FILE = "$PSScriptRoot\vars.cfg"
if (!(Test-Path $VARS_FILE)) { Write-Host "$VARS_FILE not found." ; exit 1 }
Get-Content $VARS_FILE | ForEach-Object { $var = $_.Split('=') ; New-Variable -Name $var[0] -Value $var[1].Trim('"') -Force }

$USER = "$env:USERNAME"
$BASE_DIR = "C:\workspace"
$BASE_IMAGE = "$IMAGE_NAME"
$WORKING_DIR = "$PSScriptRoot"
$PODMAN_SOCKET = "/run/user/1000/podman/podman.sock"

Push-Location "${WORKING_DIR}"

if ($args.count -lt 1) {
    Write-Host "Usage: ./tool.ps1 <commnad>"
    Write-Host "command = clean, build, run"
    Pop-Location
    exit 1
}
$arg = $args[0]

switch ($arg) {
    "clean" {
        podman builder prune --all --force
        podman volume rm ${HOME_DIR}
        podman image rm ${IMAGE}
    }
    "build" {
        Write-Host "Building custom podman image ..."
        podman build --format=docker --pull `
            --build-arg "BASE_IMAGE=${BASE_IMAGE}" `
            --build-arg "DOCKER_USER=${DOCKER_USER}" `
            --build-arg "PACKAGES=${PACKAGES}" `
            --tag=${IMAGE} `
            -f build/Dockerfile .
     }
    "run" {
        Write-Host ""
        $BASE_BUILD_TIME = (podman image inspect ${BASE_IMAGE} --format '{{ index .Config.Labels \"org.opencontainers.image.created\"}}')
        $BASE_BUILD_VERSION = (podman image inspect ${BASE_IMAGE} --format '{{ index .Config.Labels \"org.opencontainers.image.version\"}}')
        $BUILD_TIME = (podman image inspect ${IMAGE} --format '{{ index .Config.Labels \"org.opencontainers.image.created\"}}')
        $BUILD_VERSION = (podman image inspect ${IMAGE} --format '{{ index .Config.Labels \"org.opencontainers.image.version\"}}')
        $REPO_TAGS = (podman image inspect ${IMAGE} --format '{{.RepoTags}}')
        Write-Host "Base Image: ${BASE_IMAGE} (Created: ${BASE_BUILD_TIME}, Version: ${BASE_BUILD_VERSION})"
        Write-Host "This Image: ${IMAGE} (Created: ${BUILD_TIME}, Version: ${BUILD_VERSION})"
        Write-Host "This Container: ${CONTAINER_NAME} Repository Tags: ${REPO_TAGS}"
        Write-Host "Volume: /workspace is a file system mount to `"${BASE_DIR}`""
        Write-Host "Volume: /home/${DOCKER_USER} is a podman volume mapped to `"${HOME_DIR}`""
        Write-Host "Podman Socket: ${PODMAN_SOCKET}"
        Write-Host ""
        podman volume inspect "${HOME_DIR}" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Creating volume: ${HOME_DIR}"
            podman volume create "${HOME_DIR}"
        } else {
            Write-Host "Using existing volume: ${HOME_DIR}"
        }
        Write-Host "### Running interactive shell ###"
        Write-Host ""

        podman run -it --rm `
            --name=${CONTAINER_NAME} `
            --hostname ${CONTAINER_NAME} `
            --privileged `
            --device /dev/fuse `
            --userns=keep-id `
            --security-opt label=disable `
            --env="USER=${USER}" `
            --env="PODMAN_SOCKET=${PODMAN_SOCKET}" `
            --env="CONTAINER_HOST=unix://${PODMAN_SOCKET}" `
            --env="DOCKER_HOST=unix://${PODMAN_SOCKET}" `
            --volume "${PODMAN_SOCKET}:${PODMAN_SOCKET}" `
            --volume "${BASE_DIR}:/workspace" `
            --volume "${HOME_DIR}:/home/${DOCKER_USER}" `
            "${IMAGE}" /bin/bash
    }
    default {
        Write-Host "Error - Invalid option: $arg"
    }
}

Pop-Location
