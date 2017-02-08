# Install Devless on Windows using Docker

This script downloads the devless image on Docker. It does all the checks for exisitng Docker or Devless installs, and
allows Docker run with the Virtual Machine of your choice on Windows. 

## Pre-requsites

* 64-bit Windows OS

* Ensure you have a virtual machine installed. Download [Oracle Virtual Box](https://www.virtualbox.org/wiki/Downloads). If you want to use Microsoft Hyper-V as your VM, scroll down to the end to see specific instructions for configuring Hyper-V.  

## Install

* Start PowerShell as Administrator.

* PowerShell sets Execution Policy for scripts to 'Restricted' by default. If you are running PowerShell for the first time you need to set it to 'Unrestricted' using the command below:

`Set-ExecutionPolicy -ExecutionPolicy Unrestricted`

* Cd into the directory where you cloned this file and run:

`./devless_windows_install.ps1`

* If you start or restart the docker service after a shutdown, you need to start a docker machine and expose devless to a port manually. We'll use 4545 again:

`docker-machine env --shell powershell devless | iex`

`docker run -p 4545:80 eddymens/devless:latest`

* Use the following command in a new tab to check the ip of the devless machine. The default is 192.168.99.100, but you should check.
`docker-machine ls`

* Run the address on your browser to access Devless
`192.168.99.100:4545`

## Using Microsoft Hyper-V

* Ensure Hyper-V is enabled. Run the Powershell as administrator and type`n`enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`

* If you have enabled Hyperv it is important you use an internal virtual switch. In Hyper-V Manager, create a Virtual Network Switch, pick type as internal and name it "Devless".

* Finally in your System's Network Connections, open the properties of your active internet connection and share the connection with the "Devless" virtual network switch. This will make sure that the IP of the boot2docker VM never changes and it still has internet access.

Enjoy Devless :)