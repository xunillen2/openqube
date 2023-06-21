#!/bin/sh

if [ "$#" != 3 ]
then
	echo "Usage: ./cwm_gen.sh vm_name entry command"
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

if ! [[ -f "$VMHOMEP"  && -f "$CONF" ]]
then
	echo "VM with that name does not exist"
	echo "\nAvailable VMs:"
	./list_vms.sh
	exit 1
fi

ID=$(vmctl status | grep $VMNAME | awk '{print $1}')
#IP=$(cat $CONFIGPATH | grep "^\\"$VMNAME"," | cut -d',' -f3;)
IP=100.64.$ID.3
TEMP="command $ENTRY-${1}	\"ssh -o StrictHostKeyChecking=no user@$IP -Y $COMMAND\""
echo $TEMP
grep "user@$IP -Y $COMMAND" $CWMRC
if [[ $(grep "user@$IP -Y $COMMAND" $CWMRC) != "" ]]
then
	echo "Entry exists."
	exit 1
fi

cat <<EOF >>"${CWMRC}"
command $ENTRY-${1}	"ssh -o StrictHostKeyChecking=no user@$IP -Y $COMMAND"
EOF
