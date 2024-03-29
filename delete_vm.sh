#!/bin/sh

if [ "$#" != 1 ]
then
	echo "Usage: ./cwm_gen.sh vm_name"
	exit 1
fi

. ./var_setup.sh

VMNAME=${1}-vm
ENTRY=${2}
COMMAND=${3}
CWMRC=~/.cwmrc
VMOS="$VMNAME".qcow2
VMHOME="$VMNAME"-home.qcow2
VMOSP="$IMAGESPATH"/"$VMOS"
VMHOMEP="$IMAGESPATH"/"$VMHOME"
CONF="$CONFIGPATH"/"$VMNAME".conf

if ! [[ -f "$CONF" ]]
then
	echo "VM with that name does not exist"
	echo "\nAvailable VMs:"
	./list_vms.sh
	exit 1
fi

if [[ $(vmctl status | grep $VMNAME | awk '{print $8}') == "running" ]]
then
	echo "VM is running. Stoping."
	vmctl stop -f $VMNAME
	sleep 1
fi

rm -v $CONF
rm -v $VMOSP
rm -v $VMHOMEP

vmctl reload

echo "done"
