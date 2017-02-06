<#
    .SYNOPSIS
    Installs the Devless image and runs it for use on port 4545

    .DESCRIPTION
    This runs on already installed Docker for Windows. Get it here https://www.docker.com/products/docker#/windows.
    It checks that the Docker service is running, if not it prompts you to start it and rerun the script.
    Checks if you already have the Devless image and starts it on port 4545, if not it installs it and starts it on the same port.

    When you shutdown or restart docker, use this command to expose devless on any or same port:
    docker run -p 4545:80 eddymens/devless:latest
#>

Write-Host "______           _               "
Write-Host "|  _  \         | |              "
Write-Host "| | | |_____   _| | ___  ___ ___ "
Write-Host "| | | / _ \ \ / / |/ _ \/ __/ __|"
Write-Host "| |/ /  __/\ V /| |  __/\__ \__ \\"
Write-Host "|___/ \___| \_/ |_|\___||___/___/"

Write-Host "Checking for Docker installation..."

# Perform registry check to see if Docker is already installed
[Boolean]$DockerServicePath = Test-Path HKLM:\SYSTEM\CurrentControlSet\Services\com.docker.service
[String]$DockerService = "com.docker.service"

if ($DockerServicePath -eq $False) {
    #https://download.docker.com/win/stable/InstallDocker.msi
    Write-Host "Please install Docker from https://www.docker.com/products/docker#/windows"
    Write-Host "Exiting..."
}
elseif ((Get-Service com.docker.service).Status -ne "Running") {
    Write-Host "Please ensure docker is running and run the script again"
    Write-Host "Exiting..."
}
else {
    Write-Host "Docker is installed :)"

    Write-Host "Downloading the Devless image container..."

    [String]$DevlessId = docker images -q eddymens/devless

    if (($DevlessId -ne $null) -and ($DevlessId -ne '')) {
        Write-Host "Devless image already downloaded :)"
    }
    else {
        docker pull eddymens/devless   
    }

    Write-Host "Starting Devless on port 4545"

    docker run -p 4545:80 eddymens/devless:latest 
} 
