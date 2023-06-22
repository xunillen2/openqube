#!/bin/sh

if [[ "$(id -u)" -ne "0" ]]
then
    echo "You need to run this script as root."
    exit 1
fi

if [ "$#" -ne 1 ]
then
	echo "Usage: ./start_vm vm_name"
	exit 1
fi

# VM name = vmname-templatename
IMAGESPATH=/sandbox/images
CONFIGPATH=/sandbox/config
TEMPLATEPATH=/sandbox/templates
VMNAME=${1}-vm
VMOS="$VMNAME".qcow2
VMHOME="$VMNAME"-home.qcow2
VMOSP="$IMAGESPATH"/"$VMOS"
VMHOMEP="$IMAGESPATH"/"$VMHOME"
CONF="$CONFIGPATH"/"$VMNAME".conf

if ! [[ -f "$VMHOMEP"  && -f "$CONF" ]]
then
	echo "VM with that name does not exist"
	echo "\nAvailable VMs:"
	./list_vms.sh
	exit 1
fi
if [[ $(vmctl status | grep $VMNAME | awk '{print $8}') == "running" ]]
then
	echo "VM is already running"
	exit 1
fi

echo "Starting VM..."

if [[ -f "$VMOSP" ]]
then
	rm "$VMOSP"
fi

TEMPLATE=$(cat $CONF | grep "#template" | cut -d':' -f2)
TEMPLATEOSP="$TEMPLATEPATH"/$TEMPLATE.qcow2

vmctl create -b "$TEMPLATEOSP" "$VMOSP" > /dev/null 2>&1
if ! [[ $? -eq 0 ]]
then
	echo "Error while creating OS image... Cleaning up."
fi

# Get ID
ID=$(grep -E '^#id:.*[0-9]$' "$CONF" | cut -d':' -f 2)
echo $ID

# Check if tap interface exists
if ! [[ -e /dev/tap$ID ]]
then
	echo "Creating new tap interface (there is not one with given id)."
	(cd /dev; sh MAKEDEV tap$ID)
fi

# Start and open terminal
vmctl load $CONF
vmctl start "$VMNAME" > /dev/null 2>&1
su xuni -c "xterm -T $VMNAME -bg black -fg white -e \"vmctl console $VMNAME\" &" 

exit 1
