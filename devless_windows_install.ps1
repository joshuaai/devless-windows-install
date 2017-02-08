<#
    .SYNOPSIS
    Installs the Devless image and runs it for use on port 4545

    .DESCRIPTION
    This script downloads the devless image on Docker. It does all the checks for exisitng Docker or Devless installs, and
    allows Docker run with the Virtual Machine of your choice on Windows. 

    When you shutdown or restart docker, you will need to start a docker machine and expose devless to a port manually:
    - docker-machine env --shell powershell devless | iex
    - docker run -p 4545:80 eddymens/devless:latest
#>

Write-Host "______           _               "
Write-Host "|  _  \         | |              "
Write-Host "| | | |_____   _| | ___  ___ ___ "
Write-Host "| | | / _ \ \ / / |/ _ \/ __/ __|"
Write-Host "| |/ /  __/\ V /| |  __/\__ \__ \\"
Write-Host "|___/ \___| \_/ |_|\___||___/___/"

# Perform registry check to see if Docker is already installed
[Boolean]$DockerServicePath = Test-Path HKLM:\SYSTEM\CurrentControlSet\Services\com.docker.service
[Boolean]$DockerToolboxPath = Test-Path "C:\Program Files\Docker Toolbox\Docker.exe"
[String]$ChocoVersion = choco -v
[Boolean]$VBPath = Test-Path "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
[String]$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
[Boolean]$VMWarePath = Test-Path "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Workstation\Private\UninstallFiles"

Write-Host "Checking for Chocolatey installation..."
if ($ChocoVersion -eq $null) {
    #Install chocolatey package manager
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
}
else {
    Write-Host "Chocolatey already installed :)"
    
    Write-Host "Checking for Docker installation..."
    if (($DockerServicePath -eq $False) -and ($DockerToolboxPath -eq $False)) {
        Write-Host "Downloading Docker..."
        choco install -y docker

        Write-Host "Downloading docker-machine..."
        choco install -y docker-machine

        Write-Host "Downloading docker-composer..."
        choco install -y docker-composer

        #MY CODE FOR CHECKING WHICH VIRTUAL MACHINE TO USE
        if ($hyperv -eq "Enabled") {
            docker-machine create -d hyperv --hyperv-virtual-switch "Devless" devless
        }
        elseif ($VBPath -eq "True") {
            docker-machine create -d virtualbox devless
        }
        elseif ($VMWarePath -eq "True") {
            #Docker driver plugin from VMware Workstation
            choco install docker-machine-vmwareworkstation
            docker-machine create -d vmwareworkstation devless
        }
        else {
            Write-Host "Please install a virtual machine.`nGet Virtual Box online or enable Microsoft Hyper V from
            powershell as administrator using: enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`n
            Run this script again after that is done."
        }

        Write-Host "Starting the docker-machine..."
        docker-machine env --shell powershell devless | iex

        #Download the devless image
        Write-Host "Downloading the Devless image container..."
        docker pull eddymens/devless   

        #Expose Devless to port 4545
        [String]$DevlessId = docker images -q eddymens/devless
        if (($DevlessId -ne $null) -and ($DevlessId -ne '')) {
            Write-Host "Starting Devless on port 4545..."
            docker run -p 4545:80 eddymens/devless:latest
        } 
        else {
            Write-Host "Devless download failed. Running the script again with good internet connection will fix this."
        }
    }
    elseif ($DockerServicePath -eq $True) {
        Write-Host "Docker is installed :)"

        Write-Host "Checking to see if Docker Service is running"
        [String]$DockerService = "com.docker.service"
        if ((Get-Service $DockerService).Status -ne "Running") {
            Write-Host "Please ensure docker is running and run the script again"
            Write-Host "Exiting..."
        }
        else {
            #Download the devless image
            Write-Host "Downloading the Devless image container..."
            docker pull eddymens/devless   

            [String]$DevlessId = docker images -q eddymens/devless
            if (($DevlessId -ne $null) -and ($DevlessId -ne '')) {
                #Expose Devless to port 4545
                Write-Host "Starting Devless on port 4545..."
                docker run -p 4545:80 eddymens/devless:latest
            } 
            else {
                Write-Host "Devless download failed. Running the script again with good internet connection will fix this."
            }
        }
    }
    else {
        Write-Host "You have Docker Toolbox already installed.`nPlease open you Docker Quickstart Terminal and
        type this: docker pull eddymens/devless.`nAfter the image is pulled, expose devless to a port by typing: 
        docker run -p 4545:80 eddymens/devless:latest.`nCheck the host of the running docker machine (default is
        192.168.99.100) using the docker command: docker-machine ls.`nOn your browser, enter 192.168.99.100:4545 to
        see Devless.`nEnjoy Devless :)"
    }
}