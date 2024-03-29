#!/bin/sh
if [ "$#" != 1 ]
then
	echo "Usage: ./connect_xephyr.sh vm_name"
	exit 1
fi

. ./var_setup.sh

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

if ! [[ $(vmctl status | grep $VMNAME | awk '{print $8}') == "running" ]]
then
	echo "VM is not running."
	exit 1
fi
ID=$(vmctl status | grep $VMNAME | awk '{print $1}')
#IP=$(cat $CONFIGPATH | grep "^\\"$VMNAME"," | cut -d',' -f3;)
IP=100.64.$ID.3
echo $IP
Xephyr -resizeable -screen 1920x1080 :$ID &
sleep 1
DISPLAY=:$ID ssh -o StrictHostKeyChecking=no user@$IP -Y startxfce4 > /dev/null 2>&1 & 
