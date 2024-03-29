#!/bin/sh

# Check if root
if [[ "$(id -u)" -ne "0" ]]
then
    echo "You need to run this script as root."
    exit 1
fi

echo "\nCopyright Xunillen"
echo "Scripts from this project use code from Solene Rapenne's project Openkubsd."
echo "Copyright ~solene\n\n"


# Ask user where to store stuff

# Config path
while true
do
	echo "Where do you want to store VM config folder?"
	echo -n "(note. this will create "config" folder in that path): "
	read CONFIGPATH
	if [ -d "$CONFIGPATH" ]; then
	        CONFIGPATH="${CONFIGPATH}/config"
		break
	fi
	echo "Path does not exits."
done

# Template path
while true
do
	echo "Where do you want to store VM template folder?"
	echo -n "(note. this will create "templates" folder in that path): "
	read TEMPLATEPATH
	if [ -d "$TEMPLATEPATH" ]; then
		TEMPLATEPATH="${TEMPLATEPATH}/templates"
		break
	fi
	echo "Path does not exits."
done

# Iso path
while true
do  
        echo -n "Where are your iso files stored: "
        read ISOPATH 
        if [ -d "$ISOPATH" ]; then
                break
        fi
        echo "Path does not exits."
done

# Image path
while true
do  
        echo "Where do you want to store VM images folder?"
        echo -n "(note. this will create "images" folder in that path): "
        read IMAGESPATH
        if [ -d "$IMAGESPATH" ]; then
                IMAGESPATH="${IMAGESPATH}/images"
                break
        fi
        echo "Path does not exits."
done

echo "\n\nFollowing will be stored in setup_config.conf"
echo "VM Config path: $CONFIGPATH"
echo "Temaplte path: $TEMPLATEPATH"
echo "Iso path: $ISOPATH"
echo "VM images path: $IMAGESPATH"
echo -n "This ok (y/n)? "
read STATUS

if [[ $STATUS == "n" ]]; then
	exit 1
fi

SETUPPATH="/etc/setup_config.conf"
touch "$SETUPPATH"
echo "configpath:$CONFIGPATH" >> $SETUPPATH
echo "templatepath:$TEMPLATEPATH" >> $SETUPPATH
echo "isopath:$ISOPATH" >> $SETUPPATH
echo "imagepath:$IMAGESPATH" >> $SETUPPATH
chmod 644 $SETUPPATH

# Setup up directories

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
if [[ -d  "$CONFIGPATH" ]]
then
	echo "$CONFIGPATH exists. Skipping..."
else
	mkdir "$CONFIGPATH"
fi
# Set chmod
chmod 705 $CONFIGPATH
chmod 700 $TEMPLATEPATH
chmod 700 $IMAGESPATH

# Unpack and copy templates
echo "\nUnpacking Templates..."
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
	#chown root:wheel "$TEMPLATEPATH"/${filename%.tar.gz}.qcow2
	#chown root:wheel "$TEMPLATEPATH"/${filename%.tar.gz}-home.qcow2
	chmod 400 "$TEMPLATEPATH"/${filename%.tar.gz}.qcow2
	chmod 400 "$TEMPLATEPATH"/${filename%.tar.gz}-home.qcow2 
done
