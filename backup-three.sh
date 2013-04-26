#!/bin/bash

# database passwords
declare -A password
password[database1]=password1
password[database2]=password2
password[database3]=password3

date=$(date +%Y-%m-%d)
sdate=$(date +%Y-%m)
folder=backups/$sdate/

if [ ! -f $folder ];
then
	mkdir -p $folder
fi

for user in "${!password[@]}"
do
	path=$folder$user.$date.sql
	echo "backing up $path..."
	mysqldump -u$user -p${password[$user]} $user > $path
	echo "compressing..."
	xz $path
	echo "completed"
	rm $path
	echo
done
