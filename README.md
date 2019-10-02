# Intro
`bbox_toolbox.sh` is a menu driven script designed to help install a few additional
software packages to a new or existing BackBox Linux installation (https://www.backbox.org/).
BackBox is the main linux distro that I use and I wanted a quick and easy way of adding
the applications I like to use whenever I perform a fresh install.

### Applications

The following can be installed:

* VirtualBox 6 - (https://www.virtualbox.org/)
* Docker - (https://www.docker.com/)
* NetworkMiner 2.4 - (https://www.netresec.com)
* Ghidra 9.0.4 - (https://ghidra-sre.org/)

### Additional functions
 
The script can also set permissions on Wireshark to allow for
non-root user packet capturing.

### Compatibility

I have only tested this script on BackBox 6. I imagine it will work on older versions, but
I have not tried it. It might also work on other distros but I don't have any plans to test
it. If you test it and it works, let me know.

### Installation

You can download bbox_toolbox.sh by cloning this git repository:
```
git clone https://github.com/sonusboom/bbox_toolbox.git
```
    
**To Run:**
```
chmod +x bbox_toolbox.sh`
sudo ./bbox_toolbox.sh
```

### Important Notice
I likely don't know what I am doing and the actions performed by this script could probably be done faster, better or cheaper. I am open to suggestions and improvement. Thanks!
