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
CONFIGPATH=/sandbox/vmconf
TEMPLATEPATH=/sandbox/templates
VMNAME=${1}-vm
VMOS="$VMNAME".qcow2
VMHOME="$VMNAME"-home.qcow2
VMOSP="$IMAGESPATH"/"$VMOS"
VMHOMEP="$IMAGESPATH"/"$VMHOME"
TEMPLATENAME=$(grep "^\\"$VMNAME"," "$CONFIGPATH" | cut -d',' -f2;)
TEMPLATEOS="$TEMPLATENAME".qcow2
TEMPLATEHOME="$TEMPLATENAME"-home.qcow2
TEMPLATEOSP="$TEMPLATEPATH"/"$TEMPLATEOS"
TEMPLATEHOMEP="$TEMPLATEPATH"/"$TEMPLATEHOME"

if ! [[ TEMPLATENAME != "" &&  -f "$VMOSP" && -f "$VMHOMEP" ]]
then
	echo "VM with that name does not exist"
	echo "\nAvailable VMs:"
	echo $(cat $CONFIGPATH | awk -F',' '{print $1}' | awk -F'-' '{print $1}')
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
vmctl create -b "$TEMPLATEOSP" "$VMOSP" > /dev/null 2>&1
if ! [[ $? -eq 0 ]]
then
	echo "Error while creating OS image... Cleaning up."
fi

# Start and open terminal
vmctl start "$VMNAME" > /dev/null 2>&1
su xuni -c "xterm -T $VMNAME -bg black -fg white -e \"vmctl console $VMNAME\" &" 

exit 1
