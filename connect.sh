#!/bin/sh

if [ "$#" -ne 1 ]
then
	echo "Usage: ./connect.sh vm_name"
	exit 1
fi

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

if ! [[ $(vmctl status | grep $VMNAME | awk '{print $8}') == "running" ]]
then
	echo "VM is not running."
	read input\?"Do you want to start it?[y/n] (needs root): "

	if [[ "$input" != "y" ]]
	then
		exit 1
	fi
		./start_vm.sh ${1}
		exit 1
fi

xterm -T $VMNAME -bg black -fg white -e "vmctl console $VMNAME" &
