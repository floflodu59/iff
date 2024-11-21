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
echo "Taille de la mémoire de la VM ISIL en Mo :"
read guestram
echo "Mot de passe root de la VM ISIL :"
read guestpwd
echo "CONFIGURATION RESEAU INVITE EN COURS..."/
echo'echo "CONFIGURATION RESEAU EN COURS..."' > /srv/iff/phase1/setupnetwork.sh
echo'echo "# This is an automatically generated network config file by the IFF project." > /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "network:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo " ethernets:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "  enp1s0:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "   dhcp4: no" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "   addresses:['$guestip'/'$guestmask']" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "   gateway4: '$guestgateway'" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "   nameservers:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "    addresses:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "    - 8.8.8.8" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "    - 1.1.1.1" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo "    - '$guestgateway'" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'echo " version: 2" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo'netplan apply' >> /srv/iff/phase1/setupnetwork.sh
echo'ssh-keygen -A' >> /srv/iff/phase1/setupnetwork.sh
echo'sytemctl restart ssh' >> /srv/iff/phase1/setupnetwork.sh
echo "---" > /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "# defaults file for kvm_provision" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "base_image_name: jammy-server-cloudimg-amd64.img" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "base_image_url: https://cloud-images.ubuntu.com/jammy/current/{{ base_image_name }}" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "base_image_sha: 0ba0fd632a90d981625d842abf18453d5bf3fd7bb64e6dd61809794c6749e18b" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo 'libvirt_pool_dir: "/var/lib/libvirt/images"' >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_name: ubuntu2204-dev" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_vcpus: 2" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_ram_mb: $guestram" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_net: default" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_size: $guestsize\G" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_root_pass: $guestpwd" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "cleanup_tmp: no" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "ssh_key: /root/.ssh/id_rsa.pub" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "# defaults file for kvm_provision" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
