#!/bin/sh

if [[ "$(id -u)" -ne "0" ]]
then
    echo "You need to run this script as root."
    exit 1
fi

if [ "$#" -ne 3 ]
then
#	echo "Usage: ./create_vm vm_name template_name home_image_size owner_name"
#	echo "\nExample: ./create_vm vm1 debian11 5G user1"
	echo "Usage: ./create_vm vm_name template_name owner_name"
	echo "\nExample: ./create_vm vm1 debian11 user1"
	exit 1
fi

. ./var_setup.sh

IFCFOLD=/tmp/if-old
IFCFNEW=/tmp/if-new
VMNAME=${1}-vm
TEMPLATENAME=${2}
#HOMESIZE=${3}
OWNERNAME=${3}
TEMPLATEOS="$TEMPLATENAME".qcow2
TEMPLATEHOME="$TEMPLATENAME"-home.qcow2
TEMPLATEOSP="$TEMPLATEPATH"/"$TEMPLATEOS"
TEMPLATEHOMEP="$TEMPLATEPATH"/"$TEMPLATEHOME"
VMOS="$VMNAME".qcow2
VMHOME="$VMNAME"-home.qcow2
VMOSP="$IMAGESPATH"/"$VMOS"
VMHOMEP="$IMAGESPATH"/"$VMHOME"
CONF="$CONFIGPATH"/"$VMNAME".conf

cleanup() {
	echo "VM creation failed."
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
if ! [[ -d  "$CONFIGPATH" ]]
then
	echo "$CONFIGPATH does not exist. Did you run setup.sh?"
	exit 1
fi

# Check if vm with same name exists 
if [[ -f "$VMOSP" || -f "$VMHOMEP" ]]
then
	echo "VM images with same name already exist. Please change vm name."
	exit 1
elif [[ -f "$CONF" ]]
then
	echo "VM config file for with that VM name already exists. Please change vm name."
	exit 1
#else
	#grep -v "^\\"$VMNAME"," "$CONFIGPATH" > "$CONFIGPATH" # Clear config 
fi

# Check if given template exists
if ! [[ -f "$TEMPLATEOSP" || -f "$TEMPLATEHOMEP" ]]
then
	echo "\nGiven template does not exist."
	echo "Avilable Templates:"
	./list_templates.sh
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
cp "$TEMPLATEHOMEP" "$VMHOMEP"

# generate a MAC address
MAC="$(hexdump -n3 -e'/3 "00:60:2F" 3/1 ":%02X"' /dev/random)"

# Get new ID
# TODO: Fix finding unused number as this finds bigest one and 
# there may be some unused
ID=0
for vmconf in $CONFIGPATH/*
do
	TEMPID=$(grep -E '^#id:.*[0-9]$' "$vmconf" | cut -d':' -f 2)
	if [[ $TEMPID > $ID ]]
	then
		ID=$TEMPID
	fi
done
ID=$((ID+1))
echo "ID: $ID"

# Backup old config
# cat /etc/vm.conf > $VMCFOLD 
# Create vm config
echo "Creating config..."
touch $CONF
cat <<EOF >>$CONF
#id:$ID
vm "${VMNAME}" {
    disk $VMOSP
    disk $VMHOMEP
    owner $OWNERNAME
    local interface tap$ID locked lladdr $MAC
    memory 1G
    disable
    #template:$TEMPLATENAME
}
EOF
# set config premissions
chmod 640 $CONF

# Check if tap interface exists
if ! [[ -f /dev/tap$ID ]]
then
	echo "Creating new tap interface (there is not one with given id $ID)."
	(cd /dev; sh MAKEDEV tap$ID)
fi

# reload vmd
vmctl load $CONF > /dev/null 2>&1
if ! [[ $? -eq 0 ]]
then
	echo "New config load failed."
	# Restore old config
	#cat $VMCFOLD > /etc/vm.conf
	rm $CONF
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
IFIP=$(diff /tmp/if-old /tmp/if-new | grep inet | awk -F' ' '{print $3}')
VMIP="${IFIP%.2}".3
echo "VMs IP: $VMIP"
# Copy ssh key to vm
#printf "Copying ssh keys"
#while true;
#do
#	ssh -o StrictHostKeyChecking=no user@$VMIP -t "mkdir ~/.ssh"
#	if [[ $? -eq 0  ]]
#	then
#		printf "."
#		sleep 1
#	fi
#done
#scp -o StrictHostKeyChecking=no ~/.ssh/id_ed25519.pub user@$VMIP:~/.ssh/authorized_keys

vmctl stop -w $VMNAME > /dev/null
# Save vm info
#echo "$VMNAME,$TEMPLATENAME,$VMIP" >> "$CONFIGPATH"	# Put template an ip info
#echo "$VMNAME,$TEMPLATENAME" >> "$CONFIGPATH"	# Put template an ip info

# Cleanup
rm $IFCFOLD $IFCFNEW

exit 0
