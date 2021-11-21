#! /bin/sh
sudo apt install debootstrap -y
sudo mkdir /tmp/ramdisk
mount -t tmpfs none /tmp/ramdisk -o size=2048M
sudo mkdir /tmp/ramdisk/impish
sudo debootstrap --foreign impish /tmp/ramdisk/impish
sudo mount -o bind /dev /tmp/ramdisk/impish/dev
sudo mount -o bind /dev/pts /impish/dev/pts
sudo mount -t sysfs sys /tmp/ramdisk/impish/sys 
sudo mount -t proc proc /tmp/ramdisk/impish/proc

#script de creación de archivo de instalación
> /home/config.sh
cat <<+>> /home/config.sh
#!/bin/sh
echo " Configurando debootstrap segunda fase"
sleep 3
/debootstrap/debootstrap --second-stage
export LANG=C
echo "deb http://archive.ubuntu.com/ubuntu/ impish main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ impish-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ impish-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ impish-backports main restricted universe multiverse" >> /etc/apt/sources.list
apt-get update
echo "Reconfigurando parametros locales"
locale-gen es_ES.UTF-8
export LC_ALL="es_ES.UTF-8"
update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
dpkg-reconfigure -f noninteractive tzdata
apt-get upgrade -y 
hostnamectl set-hostname impish
sudo apt-get install htop -y
apt-get -f install
apt-get clean
adduser impish
addgroup impish sudo
addgroup impish adm
addgroup impish users
+
chmod +x  /home/config.sh
sudo mv  /home/config.sh /tmp/ramdisk/impish/home
chroot /tmp/ramdisk/impish /bin/sh -i ./home/config.sh
