#!/bin/sh

# Check if root
if [[ "$(id -u)" -ne "0" ]]
then
    echo "You need to run this script as root."
    exit 1
fi

# Setup vars
. ./var_setup.sh

if [ "$#" != 1 ]
then
	echo "Usage: ./delete_template.sh template"
	exit 1
fi

TEMPLATE=${1}
TEMPLATEOS="$TEMPLATEPATH"/"$TEMPLATE".qcow2
TEMPLATEHOME="$TEMPLATEPATH"/"$TEMPLATE"-home.qcow2

if ! [[ -f "$TEMPLATEOS" || -f "$TEMPLATEHOME" ]]
then
	echo "\nGiven template does not exist."
	echo "Avilable Templates:"
	./list_templates.sh
	exit 1
fi

echo "Deleting template..."
rm $TEMPLATEOS
rm $TEMPLATEHOME
echo "done"
exit 1
