#!/bin/sh

if [[ "$(id -u)" -ne "0" ]]
then
    echo "You need to run this script as root."
    exit 1
fi

if [ "$#" -ne 1 ]
then
	echo "Usage: ./start_template template_name"
	exit 1
fi

# VM name = vmname-templatename
IMAGESPATH=/sandbox/images
CONFIGPATH=/sandbox/config
TEMPLATEPATH=/sandbox/templates
TEMPLATENAME=${1}
TEMPLATEOS=$TEMPLATEPATH/"$TEMPLATENAME".qcow2
TEMPLATEHOME=$TEMPLATEPATH/"$TEMPLATENAME"-home.qcow2

if ! [[ -f "$TEMPLATEOS" || -f "$TEMPLATEHOME" ]]
then
	echo "\nGiven template does not exist."
	echo "Avilable Templates:"
	for template in $TEMPLATEPATH/*
	do
		filename=$(basename "$template")
		if [[ $filename != *-home.qcow2 && $filename == *.qcow2 ]]
		then
			echo "\t-${filename%.qcow2}"
		fi
	done
	exit 1
fi

vmctl start -c -L -d $TEMPLATEOS -d $TEMPLATEHOME "$TEMPLATENAME"
