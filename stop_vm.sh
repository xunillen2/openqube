#!/bin/sh

if [[ "$(id -u)" -ne "0" ]]
then
    echo "You need to run this script as root."
    exit 1
fi

if [ "$#" -ne 1 ]
then
	echo "Usage: ./stop_vm vm_name"
	exit 1
fi

. ./var_setup.sh

# VM name = vmname-templatename
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
if [[ $(vmctl status | grep $VMNAME | awk '{print $8}') == "stopped" ]]
then
	echo "VM is not running"
	exit 1
fi

echo "Stoping VM..."
vmctl stop -f $VMNAME

if [[ -f "$VMOSP" ]]
then
	rm "$VMOSP"
fi

exit 1
