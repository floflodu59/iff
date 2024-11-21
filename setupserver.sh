#!/bin/bash
# IFF - Script de configuration hôte
echo "CONFIGURATION HOTE IFF"
echo "======================"
echo "Adresse IPv4 serveur :"
read ipaddress
echo "Gateway IPv4 :"
read gatewayaddress
echo "Longueur Masque (1-32) :"
read masklength
echo "CONFIGURATION RESEAU EN COURS..."
echo "# This is an automatically generated network config file by the IFF project." > /etc/netplan/00-installer-config.yaml
echo "network:" >> /etc/netplan/00-installer-config.yaml
echo " ethernets:" >> /etc/netplan/00-installer-config.yaml
echo "  eno1:" >> /etc/netplan/00-installer-config.yaml
echo "   dhcp4: no" >> /etc/netplan/00-installer-config.yaml
echo " bridges:" >> /etc/netplan/00-installer-config.yaml
echo "  br0:" >> /etc/netplan/00-installer-config.yaml
echo "   interfaces: [eno1]" >> /etc/netplan/00-installer-config.yaml
echo "   addresses: [$ipaddress/$masklength]" >> /etc/netplan/00-installer-config.yaml
echo "   gateway4: $gatewayaddress" >> /etc/netplan/00-installer-config.yaml
echo "   nameservers:" >> /etc/netplan/00-installer-config.yaml
echo "    addresses:" >> /etc/netplan/00-installer-config.yaml
echo "    - 8.8.8.8" >> /etc/netplan/00-installer-config.yaml
echo "    - 1.1.1.1" >> /etc/netplan/00-installer-config.yaml
echo "    - $gatewayaddress" >> /etc/netplan/00-installer-config.yaml
echo " version: 2" >> /etc/netplan/00-installer-config.yaml
#echo " renderer: NetworkManager" >> /etc/netplan/00-installer-config.yaml
netplan apply
echo "INSTALLATION APPLICATIONS EN COURS..."
apt-get update
apt-get install ansible cockpit cockpit-pcp qemu qemu-kvm bridge-utils cpu-checker libvirt-clients libvirt-daemon postgresql cockpit-machines cloud-image-utils -y
ssh-keygen -t rsa /home/isc/.ssh/id_rsa
echo "CONFIGURATION HOTE TERMINEE"
echo "======================"
echo "Adresse IPv4 pour ISIL :"
read guestip
echo "Gateway IPv4 pour ISIL :"
read guestgateway
echo "Longueur Masque (1-32) pour ISIL :"
read guestmask
echo "Taille de la VM ISIL en Go :"
read guestsize
echo "CONFIGURATION RESEAU INVITE EN COURS..."/
echo "# This is an automatically generated network config file by the IFF project." > /srv/iff/phase1/setupnetwork.sh
echo "network:" >> /srv/iff/phase1/setupnetwork.sh
echo " ethernets:" >> /srv/iff/phase1/setupnetwork.sh
echo "  eno1:" >> /srv/iff/phase1/setupnetwork.sh
echo "   dhcp4: no" >> /srv/iff/phase1/setupnetwork.sh
echo "   addresses: [$guestip/$guestmask]" >> /srv/iff/phase1/setupnetwork.sh
echo "   gateway4: $guestgateway" >> /srv/iff/phase1/setupnetwork.sh
echo "   nameservers:" >> /srv/iff/phase1/setupnetwork.sh
echo "    addresses:" >> /srv/iff/phase1/setupnetwork.sh
echo "    - 8.8.8.8" >> /srv/iff/phase1/setupnetwork.sh
echo "    - 1.1.1.1" >> /srv/iff/phase1/setupnetwork.sh
echo "    - $guestgateway" >> /srv/iff/phase1/setupnetwork.sh
echo " version: 2" >> /srv/iff/phase1/setupnetwork.sh
