#!/bin/bash

#Creer un dossier /backup, dans celui ci va se retrouver les dossiers exportdb, scripts, temp, uploads, data.
#Dans temp mettre un autre dossier uploads et dans data mettre les dossiers uploads, db et vm .
#Mettre le fichier export.sh et errorhandler.sh dans /backup/scripts/
#Créer un fichier .psswd avec le mot de passe de la base de donnée.
#Créer un fichier .psswd2 avec le mot de passe de chiffrement de la sauvegarde.
#sudo apt install ssmtp
#Il est nécessaire d'installer et configurer ssmtp pour ce script.
#Après l'execution du cron job ajouter un autre job "ssmtp [e-mail expediteur] < /backup/script/sendmail
#

#====FUNCTION VARIABLES====
password="/backup/scripts/.psswd"
password2="/backup/scripts/.psswd2"
executiontype="/backup/scripts/executiontype"
executionmode=$(cat $executiontype)
current_date=$(date +"%Y%m%d-%H%M%S")
current_year=$(date +"%Y")
last_year=$(date --date="1 year ago" +"%Y")
current_month=$(date +"%m")
current_day=$(date +"%d")
#====ERROR HANDLER VARIABLE====
status=0
stamp=$(date +"%Y%m%d")
#====MAILING====
sender="" #Expediteur du mail
recipients=""
site="" #Apparait dans le sujet du mail : "[SUJET][SITE] Info"
sujet="" #Apparait dans le sujet du mail : "[SUJET][SITE] Info"
#====OTHER====
sqluser="isc" #Changer ici utilisateur SQL
vmarrayfile="/backup/scripts/vmlist"
vmlist=$(cat $vmarrayfile)


echo "${stamp}${status}" > /backup/scripts/status
echo "${current_date} - Démarrage de la sauvegarde." >> /backup/history.log

function savedb
{
	export PGPASSWORD=$(cat "$password") PGUSER=$sqluser ; pg_dump -U $sqluser isil > /backup/data/sqllatest.sql
	echo $(cat "$password2")| gpg --batch --yes --passphrase-fd 0 -c /backup/data/sqllatest.sql
	rm /backup/data/sqllatest.sql
	mkdir /backup/data/sql/$current_year
	mkdir /backup/data/sql/$current_year/$current_month
	mkdir /backup/data/sql/$current_year/$current_month/$current_day
	rm -rf /backup/data/sql/$last_year/$current_month/$current_day
	cp /backup/data/sqllatest.sql.gpg /backup/data/sql/$current_year/$current_month/$current_day/export-$current_date.sql.gpg
	echo "${current_date} - Sauvegarde de la BDD effectuée." >> /backup/history.log
	echo "${current_date} - Votre sauvegarde de la BDD est disponible au chemin suivant : /backup/data/sql${current_year}/${current_month}/${current_day}/export-${current_date}.sql.gpg" >> /backup/history.log
	status=1
	echo "${stamp}${status}" > /backup/scripts/status
}



function fullsave
{
	rm -rf /backup/temp/uploads
	cp -r /backup/uploads/ /backup/temp/
	tar -zcvf /backup/temp/uploads.tar.gz /backup/temp/uploads/
	echo $(cat "$password2")| gpg --batch --yes --passphrase-fd 0 -c /backup/temp/uploads.tar.gz
	mkdir /backup/data/uploads/$current_year
	mkdir /backup/data/uploads/$current_year/$current_month
	mkdir /backup/data/uploads/$current_year/$current_month/$current_day
	cp /backup/temp/uploads.tar.gz.gpg /backup/data/uploads/$current_year/$current_month/$current_day/uploads-full-$current_date.tar.gz.gpg
	mv /backup/temp/uploads.tar.gz.gpg /backup/data/uploads/uploads-full-latest.tar.gz.gpg
	rm /backup/temp/uploads.tar.gz
	echo "${current_date} - Sauvegarde des uploads effectuée." >> /backup/history.log
	echo "${current_date} - Votre sauvegarde des uploads est disponible au chemin suivant : /backup/data/${current_year}/${current_month}/${current_day}/uploads-full-${current_date}.sql.gpg" >> /backup/history.log
}

function saveuploads
{
	if [ $current_day -eq 1 ] ; then
		fullsave
	fi
	if [ $executionmode -eq 1 ] ; then
		rm -rf /backup/temp/copy
		mkdir /backup/temp/copy
		find /backup/uploads -mtime -2 -type f -exec cp "{}" /backup/temp/copy \;
		tar -zcvf /backup/temp/uploads-incremental.tar.gz /backup/temp/copy/
		echo $(cat "$password2")| gpg --batch --yes --passphrase-fd 0 -c /backup/temp/uploads-incremental.tar.gz
		cp /backup/temp/uploads-incremental.tar.gz.gpg /backup/data/uploads/$current_year/$current_month/$current_day/uploads-incremental-$current_date.tar.gz.gpg
		mv /backup/temp/uploads-incremental.tar.gz.gpg /backup/data/uploads/uploads-incremental-latest.tar.gz.gpg
		rm /backup/temp/uploads-incremental.tar.gz
		echo "${current_date} - Sauvegarde des uploads effectuée." >> /backup/history.log
		echo "${current_date} - Votre sauvegarde des uploads est disponible au chemin suivant : /backup/data/${current_year}/${current_month}/${current_day}/uploads-incremental-${current_date}.sql.gpg" >> /backup/history.log
	fi
	if [ $executionmode -eq 2 ] ; then 
		fullsave
	fi
}

function errorhandler
{
	#echo "${status}"
	if [ $status -eq 0 ] ; then
		echo "${current_date} - ERREUR DE SAUVEGARDE" >> /backup/history.log
	fi
}

function savevms
{
	for i in "${vmlist[@]}"
	do
		echo "$i"
		virsh snapshot-delete $i latest
		virsh snapshot-create-as $i latest
		mkdir /backup/data/vm/$i
		cp /var/lib/libvirt/images/$i.qcow2 /backup/data/vm/$i/latest.qcow2
		echo $(cat "$password2")| gpg --batch --yes --passphrase-fd 0 -c /backup/data/vm/$i/latest.qcow2
		rm /backup/data/vm/$i/latest.qcow2
		virsh dumpxml $i >> /backup/data/vm/$i/latestconfig.xml
		# or do whatever with individual element of the array
	done
}

function sendmail
{

	echo "To: ${recipients}" >> /backup/scripts/sendmail
	echo "From: ${sender}" >> /backup/scripts/sendmail
        if [ $status -eq 0 ] ; then
		echo "Subject: [${sujet}][${site}] ECHEC - La sauvegarde des donnees ISIL ne s'est pas effectuee." >> /backup/scripts/sendmail #Changer ici au besoin
		echo "Bonjour," >> /backup/scripts/sendmail
		echo "La sauvegarde du serveur ISIL du site ${site} n'a pas aboutie." >> /backup/scripts/sendmail #Changer ici au besoin
		echo "Bonne journee," >> /backup/scripts/sendmail
		echo "SFF 1.0 - " >> /backup/scripts/sendmail
        fi
        if [ $status -eq 1 ] ; then
		echo "Subject: [${sujet}][${site}] SUCCES - La sauvegarde des donnees ISIL s'est effectuee." >> /backup/scripts/sendmail #Changer ici au besoin
		echo "Bonjour," >> /backup/scripts/sendmail
		echo "La sauvegarde du serveur ISIL du site ${site} s'est effectuee correctement." >> /backup/scripts/sendmail #Changer ici au besoin
		echo "Bonne journee," >> /backup/scripts/sendmail
                echo "SFF 1.0" >> /backup/scripts/sendmail
        fi
	/usr/sbin/ssmtp $sender < /backup/scripts/sendmail
	rm /backup/scripts/sendmail
	echo "${current_date} - Envoi du mail effectué." >> /backup/history.log
}

savedb
saveuploads
savevms
errorhandler
#sendmail
