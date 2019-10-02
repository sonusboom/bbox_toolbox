#!/bin/bash
#
# Script Name: bbox_toolbox.sh
# Created By: SonusBoom
# Original Date: 9/07/2019
#
# 
# 
# This menu driven script is designed to install several additional
# software packages to a new or exisitng BackBox Linux installation 
# (https://www.backbox.org/). I use BackBox a lot and often find
# myself installing or re-installing it for different projects I am 
# working. I grew tired of having to manually install certain items.
# I have only tested this script on BackBox 6 but it may also work on
# older versions.
#
# The following packages can be installed:
# 
# - VirtualBox 6
# - Docker (latest version)
# - NetworkMiner 2.4
# - Ghidra 9.0.4
# 
# This script can also set permissions on Wireshark to allow for
# non-priviledged packet capturing.
#
# Comments that contain "***" are sections of code that came from
# github.com/da667 AutoMISP script. Please check out his GitHub
# page.
#
#

# List of variables

# capture current logged in user for wireshark and virtual group memberships

username=${SUDO_USER:-$(whoami)}

# ***Make the script look extra expensive with some awesome fancy outputs***

function print_status () 
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

# ***Check for root user status***

print_status "Checking for root..."
if [ $(whoami) != "root" ]; then
	print_error "Root check failed...please execute script with sudo..."
	exit 1
else
	print_good "Root check successful..."
fi

# ***Redirect certain processes to an install log***

logfile=/var/log/bbox_toolbox_install.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

# ***Function to perform error checking.***

function error_check ()
{

if [ $? -eq 0 ]; then
	print_good "$1 successfully completed."
else
	print_error "$1 failed. Please check $logfile for more details."
exit 1
fi

}

# Sofware Install Functions

function install_virtualbox () {

	# Add Oracle Key to apt key management
	echo " "
	wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - &>> $logfile
	error_check 'Add Oracle key...'	
	
	# Add VirtualBox repository
	echo " "
	add-apt-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" &>> $logfile
	error_check 'Add VirtualBox repository...'

	# Update repositories and install VirtualBox
	echo " "
	print_status "Downloading and Installing VirtualBox...(this may take awhile)..."
	echo " "
	apt-get update &>> $logfile
	apt-get install virtualbox-6.0 -y &>> $logfile

	# Add current user to vboxusers
	usermod -a -G vboxusers $username

	echo " "
	error_check 'VirtualBox Installation...'
	echo " "
	read -p "Press any key to continue..."

}

function install_docker () {
	
	# Install Dependency packages to support Docker on Linux
	echo " "
	print_status "Installing dependencies to support Docker...(this may take awhile)..."	
	apt-get install apt-transport-https ca-certificates software-properties-common -y &>> $logfile
	echo " "
	error_check 'Dependency installation...'
	
	# Add Docker Key to apt key management
	echo " "
	wget -q https://download.docker.com/linux/ubuntu/gpg -O- | apt-key add - &>> $logfile
	echo " "
	error_check 'Add Docker key...'	
	
	# Add Docker repository
	echo " "
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable" &>> $logfile
	echo " "
	error_check 'Add Docker repository...'
	
	# Update repositories and install Docker
	echo " "
	print_status "Downloading and Installing Docker...(this may take awhile)..."
	echo " "
	apt-get update &>> $logfile
	apt-get install docker-ce -y &>> $logfile
		
	echo " "
	error_check 'Docker Installation...'
	echo " "
	read -p "Press any key to continue..."
}

function install_network_miner () {

	# Install Mono packages to support NetworkMiner on Linux

	echo " "
	print_status "Installing Mono to support NetworkMiner...(this may take awhile)..."
	apt-get install libmono-system-windows-forms4.0-cil libmono-system-web4.0-cil libmono-system-net4.0-cil libmono-system-runtime-serialization4.0-cil libmono-system-xml-linq4.0-cil -y &>> $logfile
	echo " "
	error_check 'Mono Installation...'

	# Download NetworkMiner and Install to /opt directory

	echo " "
	print_status "Downloading and installing NetworkMiner..."
	echo " "
	wget -q www.netresec.com/?download=NetworkMiner -O /tmp/nm.zip &>> $logfile
	unzip /tmp/nm.zip -d /opt/ &>> $logfile
	cp networkminer.png /opt/NetworkMiner_2-4
	cd /opt/NetworkMiner*
	chmod +x NetworkMiner.exe
	chmod -R go+w AssembledFiles/
	chmod -R go+w Captures/

	# Create NetworkMiner desktop icon
	
	cd /home/${username}/Desktop
	cat > NetworkMiner.desktop <<-EOF
	# autostart server & periodic update
	#!/usr/bin/env xdg-open
	[Desktop Entry]
	Version=1.0
	Type=Application
	Terminal=false
	Exec=mono /opt/NetworkMiner_2-4/NetworkMiner.exe
	Path=/opt/NetworkMiner_2-4
	Name=NetworkMiner
	Comment=NetworkMiner_2.4
	Icon=/opt/NetworkMiner_2-4/networkminer.png
	EOF
	chmod +x NetworkMiner.desktop
	chown $username:$username NetworkMiner.desktop
	error_check 'NetworkMiner Installation...'
	echo " "
	read -p "Press any key to continue..."
}

function install_ghidra () {

	# Install OpenJDK packages to support Ghidra on Linux

	echo " "
	print_status "Installing OpenJDK to support Ghidra...(this may take awhile)..."
	echo " "
	add-apt-repository ppa:openjdk-r/ppa -y &>> $logfile
	apt-get update &>> $logfile
	apt-get install openjdk-11-jdk openjdk-11-jre-headless -y &>> $logfile
	echo " "
	error_check 'OpenJDK Installation...'

	# Download Ghidra and Install to /opt directory

	print_status "Downloading and installing Ghidra...(this may take awhile)..."
	echo " "
	wget -q https://ghidra-sre.org/ghidra_9.0.4_PUBLIC_20190516.zip -O /tmp/ghidra_9.0.4_PUBLIC_20190516.zip &>> $logfile
	unzip /tmp/ghidra_9.0.4_PUBLIC_20190516.zip -d /opt/ &>> $logfile
	cp ghidra.png /opt/ghidra_9.0.4
	echo " "

	# Create Ghidra desktop icon
	
	cd /home/${username}/Desktop
	cat > Ghidra.desktop <<- EOF
	#!/usr/bin/env xdg-open
	[Desktop Entry]
	Version=1.0
	Type=Application
	Terminal=false
	Exec=/opt/ghidra_9.0.4/ghidraRun
	Path=/opt/ghidra
	Name=Ghidra
	Comment=Ghidra 9.0.4
	Icon=/opt/ghidra_9.0.4/ghidra.png
	EOF
	chmod +x Ghidra.desktop
	chown $username:$username Ghidra.desktop
	error_check 'Ghidra Installation...'
	echo " "
	read -p "Press any key to continue..."
}

function wireshark_permissions () {

# This function sets wireshark permissions to allow non-root users
# to capture packets. This first statement checks for the wireshark
# group and if not found assumes that none of the changes have been
# made and sets them.

if [ "$(getent group wireshark | awk -F ":" '{print $1}')" == "wireshark" ]; then
	echo " "
    print_notification "Group \"wireshark\" exists...checking /usr/bin/dumpcap settings..."
    echo " "
    
    else
		echo " "
		print_notification "Group \"wireshark\" doesn't exist...creating group..."
		sleep 2
		echo " "
		groupadd wireshark
		usermod -a -G wireshark $username
    
		# Assign dumpcap to wireshark group
		chgrp wireshark /usr/bin/dumpcap
		chmod 750 /usr/bin/dumpcap

		# Grant capabilities with SETCAP
		setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
	
		echo " "
		print_notification "Wireshark group created and ${username} added..."
		sleep 2
		echo " "
fi

# These statements check for /usr/bin/dumpcap settings and if not configured
# properly, implements the required settings for non-privileged captures

if [ "$(stat -c %G /usr/bin/dumpcap)" == "wireshark" ]; then
	echo " "
	print_notification	"Dumpcap group is already set to Wireshark...checking permissions..."
	sleep 2
	echo " "
	else	
		echo " "
		print_notification "Dumpcap group is not set to Wireshark...setting group membership..."
		sleep 2
		echo " "
		chgrp wireshark /usr/bin/dumpcap		
fi
	
if [ "$(stat -c %a /usr/bin/dumpcap)" == "750" ]; then
	echo " "
	print_notification "Dumpcap permissions are set to 750...checking if ${username} is member of wireshark group..."
	sleep 2
	echo " "
	else
		echo " "
		print_notification "Dumpcap permissions are not set to 750...setting permissions..."
		sleep 2
		echo " "
		chmod 750 /usr/bin/dumpcap		
fi		
	
if [ "$(groups ${username} |grep -oP wireshark)" == "wireshark" ]; then
	echo " "
	print_notification "User ${username} is already a member of the Wireshark group..."
	sleep 2
	echo " "
	else
		echo " "
		print_notification "User ${username} is not a member of the Wireshark group...adding user to group..."
		sleep 2
		# Assign dumpcap to wireshark group
		usermod -a -G wireshark $username		

		# Grant capabilities with SETCAP
		setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
		echo " "
		print_notification "Capture capabilities set via \"setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap\"..."
		sleep 2
		echo " "
		read -p "Press enter to continue..."
fi
}

m_choice=" "
while [ "$m_choice" != "q" ]
do
 clear
 echo " "
 echo "        |====|	   "
 echo " ===================="
 echo " |   		    |"
 echo " |   Bbox Toolbox   |" 
 echo " ===================="
 echo " "
 echo " 1. Install VirtualBox"
 echo " 2. Install Docker"
 echo " 3. Install NetworkMiner"
 echo " 4. Install Ghidra"
 echo " 5. Set Wireshark Privileges"
 echo " q. Quit"
 echo " "
 read -p " Enter your choice: " m_choice

 if [ "$m_choice" = "1" ]; then
	install_virtualbox
 elif [ "$m_choice" = "2" ]; then
	install_docker
 elif [ "$m_choice" = "3" ]; then
	install_network_miner
 elif [ "$m_choice" = "4" ]; then
	install_ghidra
 elif [ "$m_choice" = "5" ]; then
	wireshark_permissions
 elif [ "$m_choice" = "q" ]; then
	clear
	break
 fi

done
