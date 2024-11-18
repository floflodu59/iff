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
ssh-keygen -t rsa
echo "CONFIGURATION TERMINEE"