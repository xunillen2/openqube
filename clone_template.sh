#!/bin/sh

if [ "$#" != 2 ]
then
	echo "Usage: ./clone_template.sh template new_template_name"
	exit 1
fi

TEMPLATEPATH=/sandbox/templates
IMAGESPATH=/sandbox/images
ISOPATH=/sandbox/iso
TEMPLATE=${1}
NEWTEMPLATE=${2}
TEMPLATEOS="$TEMPLATEPATH"/"$TEMPLATE".qcow2
TEMPLATEHOME="$TEMPLATEPATH"/"$TEMPLATE"-home.qcow2
NEWTEMPLATEOS="$TEMPLATEPATH"/"$NEWTEMPLATE".qcow2
NEWTEMPLATEHOME="$TEMPLATEPATH"/"$NEWTEMPLATE"-home.qcow2

if ! [[ -f "$TEMPLATEOS" || -f "$TEMPLATEHOME" ]]
then
	echo "\nGiven template does not exist."
	echo "Avilable Templates:"
	./list_templates.sh
	exit 1
fi

if [[ -f "$NEWTEMPLATEOS" || -f "$NEWTEMPLATEHOME" ]]
then
	echo "Template with that name already exists. Please use a difrent name."
	exit 1
fi
echo "Cloning template..."
cp $TEMPLATEOS $NEWTEMPLATEOS
cp $TEMPLATEHOME $NEWTEMPLATEHOME
echo "done"
exit 1
