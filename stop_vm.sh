#!/bin/sh

if [ "$#" != 1 ]
then
	echo "Usage: ./stop_vm.sh vm_name"
	exit 1
fi

VMNAME=${1}-vm
CONFIGPATH=/sandbox/config
VMOS="$VMNAME".qcow2
VMHOME="$VMNAME"-home.qcow2
VMOSP="$IMAGESPATH"/"$VMOS"
VMHOMEP="$IMAGESPATH"/"$VMHOME"
CONF="$CONFIGPATH"/"$VMNAME".conf

if ! [[ -f "$VMHOMEP" && -f "$VMOSP"  && -f "$CONF" ]]
then
	echo "VM with that name does not exist or is not running"
	echo "\nAvailable VMs:"
	./list_vms.sh
	exit 1
fi

vmctl stop $VMNAME
