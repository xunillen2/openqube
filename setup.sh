#!/bin/sh

TEMPLATEPATH=/sandbox/templates
IMAGESPATH=/sandbox/images
ISOPATH=/sandbox/iso

# Set up directories

if [[ -d  "$TEMPLATEPATH" ]]
then
	echo "$TEMPLATEPATH exists. Skipping..."
else
	mkdir "$TEMPLATEPATH"
fi
if [[ -d  "$IMAGESPATH" ]]
then
	echo "$IMAGESPATH exists. Skipping..."
else
	mkdir "$IMAGESPATH"
fi
if [[ -d  "$ISOPATH" ]]
then
	echo "$ISOPATH exists. Skipping..."
else
	mkdir "$ISOPATH"
fi

# Copy system configuration files
#cp config/pf.conf /etc/
#cp config/vn.conf /etc/

# Unpack and copy templates
echo "Unpacking Templates..."
for template in templates/*
do
	filename=$(basename "$template")
    echo "$filename"...
    if [[ -f "$TEMPLATEPATH"/${filename%.tar.gz}.qcow2 ]]
	then
		echo "Template already exists. Skipping..."
		continue
	fi 
	tar xvzf "$template" -C "$TEMPLATEPATH"
	chown root:wheel "$TEMPLATEPATH"/${filename%.tar.gz}.qcow2
	chown root:wheel "$TEMPLATEPATH"/${filename%.tar.gz}-home.qcow2
done
