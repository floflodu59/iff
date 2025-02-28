#!/bin/bash
# IFF - Script de configuration hôte
echo "CONFIGURATION HOTE IFF"
echo "======================"
echo "Nom de l'interface ethernet utilisée :"
read interface
echo "Adresse IPv4 serveur :"
read ipaddress
echo "Gateway IPv4 :"
read gatewayaddress
echo "Longueur Masque (1-32) :"
read masklength
echo "CONFIGURATION RESEAU EN COURS..."
rm -rf /etc/netplan/*
echo "# This is an automatically generated network config file by the IFF project." > /etc/netplan/00-installer-config.yaml
echo "network:" >> /etc/netplan/00-installer-config.yaml
echo " ethernets:" >> /etc/netplan/00-installer-config.yaml
echo "  $interface:" >> /etc/netplan/00-installer-config.yaml
echo "   dhcp4: no" >> /etc/netplan/00-installer-config.yaml
echo " bridges:" >> /etc/netplan/00-installer-config.yaml
echo "  br0:" >> /etc/netplan/00-installer-config.yaml
echo "   interfaces: [$interface]" >> /etc/netplan/00-installer-config.yaml
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
echo "======================"
echo "GENERATION DE LA CLE SSH"
ssh-keygen -t rsa -f /home/isc/.ssh/id_rsa
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
echo "CONFIGURATION RESEAU INVITE EN COURS..."
sed -i 's/ram_mb: 2048/ram_mb: '$guestram'/g' /srv/iff/phase1/kvm_provision.yaml
echo 'echo "CONFIGURATION RESEAU EN COURS..."' > /srv/iff/phase1/setupnetwork.sh
echo 'echo "# This is an automatically generated network config file by the IFF project." > /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "network:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo " ethernets:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "  enp1s0:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "   dhcp4: no" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "   addresses: ['$guestip'/'$guestmask']" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "   gateway4: '$guestgateway'" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "   nameservers:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "    addresses:" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "    - 8.8.8.8" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "    - 1.1.1.1" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo "    - '$guestgateway'" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'echo " version: 2" >> /etc/netplan/00-installer-config.yaml' >> /srv/iff/phase1/setupnetwork.sh
echo 'netplan apply' >> /srv/iff/phase1/setupnetwork.sh
echo 'ssh-keygen -A' >> /srv/iff/phase1/setupnetwork.sh
echo 'rm /etc/ssh/sshd_config.d/60-cloudimg-settings.conf' >> /srv/iff/phase1/setupnetwork.sh
echo 'adduser isil' >> /srv/iff/phase1/setupnetwork.sh
echo 'shutdown -r' >> /srv/iff/phase1/setupnetwork.sh
echo "---" > /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "# defaults file for kvm_provision" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "base_image_name: jammy-server-cloudimg-amd64.img" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "base_image_url: https://cloud-images.ubuntu.com/jammy/current/{{ base_image_name }}" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "base_image_sha: 0ba0fd632a90d981625d842abf18453d5bf3fd7bb64e6dd61809794c6749e18b" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo 'libvirt_pool_dir: "/var/lib/libvirt/images"' >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_name: VMISIL" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_vcpus: 2" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_ram_mb: $guestram" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_net: default" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_size: "$guestsize"G" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "vm_root_pass: $guestpwd" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "cleanup_tmp: no" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "ssh_key: /root/.ssh/id_rsa.pub" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "# defaults file for kvm_provision" >> /srv/iff/phase1/roles/kvm_provision/defaults/main.yml
echo "[myhosts]" > /srv/iff/phase2/inventory.ini
echo "$guestip" >> /srv/iff/phase2/inventory.ini
echo "[all:vars]" >> /srv/iff/phase2/inventory.ini
echo "ansible_user=root" >> /srv/iff/phase2/inventory.ini
echo "ansible_pass=$guestpwd" >> /srv/iff/phase2/inventory.ini
echo "ansible_ssh_private_key_file =/home/isc/.ssh/id_rsa" >> /srv/iff/phase2/inventory.ini
echo 'ansible_ssh_common_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"' >> /srv/iff/phase2/inventory.ini
echo "======================"
echo "EXECUTION PHASE 1"
ansible-playbook /srv/iff/phase1/kvm_provision.yaml
echo "CONFIGURATION & REDEMARRAGE MACHINE VIRTUELLE"
sleep 120
echo "EXECUTION PHASE 2"
ansible-playbook /srv/iff/phase2/setupisil.yaml -i /srv/iff/phase2/inventory.ini
echo "======================"
echo "Mot de passe pour la base de donnée :"
read dbpassword
echo "CONFIGURATION DE LA BASE DE DONNEES"
systemctl enable postgresql && systemctl start postgresql
sed -i 's/local   all             postgres                                peer/local   all             postgres                                trust/g' /etc/postgresql/14/main/pg_hba.conf
systemctl restart postgresql
psql -U postgres -c "Alter USER postgres WITH PASSWORD '$dbpassword';"
psql -U postgres -c "create database isil;"
sed -i 's/local   all             postgres                                trust/local   all             postgres                                md5/g' /etc/postgresql/14/main/pg_hba.conf
echo "CONFIGURATION DE LA SAUVEGARDE"
mkdir /backup
