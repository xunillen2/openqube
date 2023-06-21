#!/bin/sh

if [ "$#" != 1 ]
then
	echo "Usage: ./cwm_gen.sh vm_name"
	exit 1
fi

VMNAME=${1}-vm
ENTRY=${2}
COMMAND=${3}
CONFIGPATH=/sandbox/config
IMAGESPATH=/sandbox/images
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
	#echo $(cat $CONFIGPATH | awk -F',' '{print $1}' | awk -F'-' '{print $1}')
	for vmconf in $CONFIGPATH/*
	do
		filename=$(basename $vmconf)
		echo "\t- ${filename%-vm.conf}"
	done
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
