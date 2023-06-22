#!/bin/sh

if [ "$#" != 1 ]
then
	echo "Usage: ./stop_vm.sh vm_name"
	exit 1
fi

VMNAME=${1}-vm
CONFIGPATH=/sandbox/config	
IMAGESPATH=/sandbox/images
VMOS="$VMNAME".qcow2
VMHOME="$VMNAME"-home.qcow2
VMOSP="$IMAGESPATH"/"$VMOS"
VMHOMEP="$IMAGESPATH"/"$VMHOME"
CONF="$CONFIGPATH"/"$VMNAME".conf

if ! [[ -e "$CONF" ]]
then
	echo "VM with that name does not exist or is not running"
	echo "\nAvailable VMs:"
	./list_vms.sh
	exit 1
fi

if ! [[ $(vmctl status | grep $VMNAME | awk '{print $8}') == "running" ]]
then
	echo "VM is not running."
	exit 1
fi

echo "Stopping ${1}..."
vmctl stop -w $VMNAME
echo "Cleanup..."
ID=$(grep -E '^#id:.*[0-9]$' "$CONF" | cut -d':' -f 2)
echo $ID
# Check if tap interface exists
if [[ -e /dev/tap$ID && $ID > 3 ]]
then
	rm /dev/tap$ID
fi
rm $VMOSP

echo "Done."
exit 0
