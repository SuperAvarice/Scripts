# Set-ExecutionPolicy -ExecutionPolicy Unrestricted --||-- Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

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

Push-Location "${WORKING_DIR}"

if ($args.count -lt 1) {
    Write-Host "Usage: ./tool.ps1 <commnad>"
    Write-Host "command = clean, build, package, load, run"
    Pop-Location
    exit 1
}
$arg = $args[0]

switch ($arg) {
    "clean" {
        docker builder prune --all --force
        docker volume rm ${HOME_DIR}
        docker image rm ${image}
    }
    "build" {
        Write-Host "Building custom docker image ..."
        docker build --pull `
            --build-arg "BASE_IMAGE=${BASE_IMAGE}" `
            --build-arg "DOCKER_USER=${DOCKER_USER}" `
            --build-arg "PACKAGES=${PACKAGES}" `
            --tag=${IMAGE} `
            -f build/Dockerfile .
     }
    "package" {
        Write-Host "Saving image to file ${WORKING_DIR}\${ARCHIVE_VERSION}"
        docker save ${IMAGE} -o "${WORKING_DIR}\${ARCHIVE_VERSION}"
    }
    "load" {
        docker image rm ${IMAGE}
        docker load -i $args[1]
    }
    "run" {
        Write-Host ""
        Write-Host "Base Image: ${BASE_IMAGE}"
        Write-Host "This Image: ${IMAGE}"
        Write-Host "This Container: ${CONTAINER_NAME}"
        Write-Host "Volume: /workspace is a file system mount to `"${BASE_DIR}`""
        Write-Host "Volume: /home/${DOCKER_USER} is a docker volume mapped to `"${HOME_DIR}`""
        Write-Host ""

        docker volume create ${HOME_DIR}
        docker run -it --rm `
            --name=${CONTAINER_NAME} `
            -h ${CONTAINER_NAME} `
            -e USER=${USER} `
            -e IS_WINDOWS_HOST=true `
            -v "${BASE_DIR}:/workspace" `
            -v "${HOME_DIR}:/home/${DOCKER_USER}" `
            -v /var/run/docker.sock:/var/run/docker.sock `
            ${IMAGE} /bin/bash
    }
    default {
        Write-Host "Error - Invalid option: $arg"
    }
}

Pop-Location
