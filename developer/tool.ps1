# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass

 # Windows Podman Desktop installed with Docker Compatibility mode, rootful.

$VARS_FILE = "$PSScriptRoot\vars.cfg"
if (!(Test-Path $VARS_FILE)) {
    Write-Host "$VARS_FILE not found."
    exit 1
}

Get-Content $VARS_FILE | ForEach-Object {
    $var = $_.Split('=')
    New-Variable -Name $var[0] -Value $var[1].Trim('"')
}

$USER = "$env:USERNAME"
$BASE_DIR = "C:\workspace"
$BASE_IMAGE = "$IMAGE_NAME"
$WORKING_DIR = "$PSScriptRoot"
$ARCHIVE_VERSION = "$IMAGE-$BUILD_VERSION.tar"
$PODMAN_SOCKET = $env:PODMAN_SOCKET
if ([string]::IsNullOrWhiteSpace($PODMAN_SOCKET)) {
    $PODMAN_SOCKET = "/run/podman/podman.sock"
}

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
        podman build --pull `
            --build-arg "BASE_IMAGE=${BASE_IMAGE}" `
            --build-arg "DOCKER_USER=${DOCKER_USER}" `
            --build-arg "PACKAGES=${PACKAGES}" `
            --tag=${IMAGE} `
            -f build/Dockerfile .
     }
    "run" {
        Write-Host ""
        Write-Host "Base Image: ${BASE_IMAGE}"
        Write-Host "This Image: ${IMAGE}"
        Write-Host "This Container: ${CONTAINER_NAME}"
        Write-Host "Host User: ${USER}"
        Write-Host "Volume: /workspace is a file system mount to `"${BASE_DIR}`""
        Write-Host "Volume: /home/${DOCKER_USER} is a podman volume mapped to `"${HOME_DIR}`""
        Write-Host "Podman Socket: ${PODMAN_SOCKET}"
        Write-Host ""

        podman volume inspect ${HOME_DIR} 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { podman volume create ${HOME_DIR} }

        podman run --rm -it `
            --name=${CONTAINER_NAME} `
            -h ${CONTAINER_NAME} `
            --privileged `
            --device /dev/fuse `
            --userns=keep-id `
            --security-opt label=disable `
            -e PODMAN_SOCKET=${PODMAN_SOCKET} `
            -e CONTAINER_HOST=unix://${PODMAN_SOCKET} `
            -v "${PODMAN_SOCKET}:${PODMAN_SOCKET}" `
            -v "${BASE_DIR}:/workspace" `
            -v "${HOME_DIR}:/home/${DOCKER_USER}" `
            ${IMAGE} /bin/bash
    }
    default {
        Write-Host "Error - Invalid option: $arg"
    }
}

Pop-Location
