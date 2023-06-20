#!/bin/sh

if [ "$#" != 3 ]
then
	echo "Usage: ./cwm_gen.sh vm_name entry command"
	exit 1
fi

VMNAME=${1}-vm
ENTRY=${2}
COMMAND=${3}
CONFIGPATH=/sandbox/vmconf
IMAGESPATH=/sandbox/images
CWMRC=~/.cwmrc
VMOS="$VMNAME".qcow2
VMHOME="$VMNAME"-home.qcow2
VMOSP="$IMAGESPATH"/"$VMOS"
VMHOMEP="$IMAGESPATH"/"$VMHOME"

if ! [[ -f "$VMOSP" && -f "$VMHOMEP" ]]
then
	echo "VM with that name does not exist"
	echo "\nAvailable VMs:"
	echo $(cat $CONFIGPATH | awk -F',' '{print $1}' | awk -F'-' '{print $1}')
	exit 1
fi

IP=$(cat $CONFIGPATH | grep "^\\"$VMNAME"," | cut -d',' -f3;)
TEMP="command $ENTRY-${1}	\"ssh user@$IP -Y $COMMAND\""
echo $TEMP
grep "$TEMP" $CWMRC
if [[ $(grep "$TEMP" $CWMRC) != "" ]]
then
	echo "Entry exists."
	exit 1
fi

cat <<EOF >>"${CWMRC}"
command $ENTRY-${1}	"ssh user@$IP -Y $COMMAND"
EOF
