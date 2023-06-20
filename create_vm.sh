#!/bin/sh

if [[ "$(id -u)" -ne "0" ]]
then
    echo "You need to run this script as root."
    exit 1
fi

if [ "$#" -ne 4 ]
then
	echo "Usage: ./create_vm vm_name template_name home_image_size owner_name"
	echo "\nExample: ./create_vm vm1 debian11 5G user1"
	exit 1
fi

TEMPLATEPATH=/sandbox/templates
IMAGESPATH=/sandbox/images
ISOPATH=/sandbox/iso
CONFIGPATH=/sandbox/vmconf
IFCFOLD=/tmp/if-old
IFCFNEW=/tmp/if-new
VMCFOLD=/tmp/vm.conf.temp
VMNAME=${1}-vm
TEMPLATENAME=${2}
HOMESIZE=${3}
OWNERNAME=${4}
TEMPLATEOS="$TEMPLATENAME".qcow2
TEMPLATEHOME="$TEMPLATENAME"-home.qcow2
TEMPLATEOSP="$TEMPLATEPATH"/"$TEMPLATEOS"
TEMPLATEHOMEP="$TEMPLATEPATH"/"$TEMPLATEHOME"
VMOS="$VMNAME".qcow2
VMHOME="$VMNAME"-home.qcow2
VMOSP="$IMAGESPATH"/"$VMOS"
VMHOMEP="$IMAGESPATH"/"$VMHOME"

cleanup() {
	if [[ -f "$VMOSP" ]]
	then
		rm "$VMOSP"
	fi
	if [[ -f "$VMHOMEP" ]]
	then
		rm "$VMHOMEP"
	fi
	exit 1;
}

# Check if required directories exist
if ! [[ -d  "$TEMPLATEPATH" ]]
then
	echo "$TEMPLATEPATH does not exist. Did you run setup.sh?"
	exit 1
fi
if ! [[ -d  "$IMAGESPATH" ]]
then
	echo "$IMAGESPATH does not exist. Did you run setup.sh?"
	exit 1
fi
if ! [[ -d  "$ISOPATH" ]]
then
	echo "$ISOPATH does not exist. Did you run setup.sh?"
	exit 1
fi

# Check if vm with same name exists 
if [[ -f "$VMOSP" || -f "$VMHOMEP" ]]
then
	echo "VM images with same name already exist. Please change vm name."
	exit 1
#else
	#grep -v "^\\"$VMNAME"," "$CONFIGPATH" > "$CONFIGPATH" # Clear config 
fi

# Check if given template exists
if ! [[ -f "$TEMPLATEOSP" || -f "$TEMPLATEHOMEP" ]]
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

# Check if user exists
if ! id "$OWNERNAME" >/dev/null 2>&1;
then
    echo "User $OWNERNAME does not exist."
    exit 1
fi

# Create vm images from templates
# vmctl returns 0 on success and >0 on error.
# Check if vmd is enabled.
echo "Creating VM OS image..."
vmctl create -b "$TEMPLATEOSP" "$VMOSP" > /dev/null 2>&1
if ! [[ $? -eq 0 ]]
then
	echo "Error while creating OS image... Cleaning up."
	cleanup;
fi
echo "Creating VM persistent(private) image..."
#vmctl -v create -i "$TEMPLATEHOMEP" -s "$HOMESIZE" "$VMHOMEP"
#if ! [[ $? -eq 0 ]]
#then
#	echo "Error while creating persistent(private) image... Cleaning up."
#	cleanup;
#fi
cp "$TEMPLATEHOMEP" "$VMHOMEP"

# generate a MAC address
MAC="$(hexdump -n3 -e'/3 "00:60:2F" 3/1 ":%02X"' /dev/random)"

# Backup old config
cat /etc/vm.conf > $VMCFOLD 
# Create vm config
echo "Creating config..."
cat <<EOF >>/etc/vm.conf
vm "${VMNAME}" {
    disk $VMOSP
    disk $VMHOMEP
    owner $OWNERNAME
    local interface locked lladdr $MAC
    memory 1G
    disable
}
EOF

# reload vmd
vmctl reload
if ! [[ $? -eq 0 ]]
then
	echo "Reloading failed."
	# Restore old config
	cat $VMCFOLD > /etc/vm.conf
	cleanup;
	exit 1
fi

echo "Starting vm for the first time to finish configuration..."
# Get vm ip by detecting change in ifconfig
ifconfig > $IFCFOLD
vmctl start $VMNAME
sleep 1
ifconfig > $IFCFNEW
sleep 1
vmctl stop -w $VMNAME > /dev/null
VMIP=$(diff /tmp/if-old /tmp/if-new | grep inet | awk -F' ' '{print $3}')
echo $VMIP
# Save vm info
#echo "$VMNAME,$TEMPLATENAME,$VMIP" >> "$CONFIGPATH"	# Put template an ip info
echo "$VMNAME,$TEMPLATENAME" >> "$CONFIGPATH"	# Put template an ip info

# Cleanup
rm $IFCFOLD $IFCFNEW $VMCFOLD

exit 0
