mkdir -p /var/log/isil
chown root:root /var/log/isil
chmod 755 /var/log/isil

git clone https://github.com/floflodu59/iff.git /srv/iff
mkdir /usr/local/share/cockpit
mkdir /usr/local/share/cockpit/cockpit-files
cp /srv/iff/bin/cockpit-files/* /usr/local/share/cockpit/cockpit-files/

cp /srv/iff/bin/isil/start_isil.sh /usr/local/bin/start_isil.sh
chmod +x /usr/local/bin/start_isil.sh
cp /srv/iff/bin/isil/isil.service /etc/systemd/system/isil.service

sed -i 's/-Xmx24g/-Xmx¤g/g' /usr/local/bin/start_isil.sh