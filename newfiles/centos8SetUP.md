getting Centos 8 setup
Devices > Optical Drives > Remove disk from virtual drive.
Click on Machine > Reset

Gno-menu
Gnome-tweaks

node instruction:
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo yum install perl gcc dkms kernel-devel kernel-headers make bzip2 -y
yum groupinstall -y 'Development Tools'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash
nvm install node

Install Docker

Start docker

Containerizing Angular App
