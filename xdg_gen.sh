

#!/bin/sh

if [ "$#" -ne 4 ]
then
	echo "Usage: ./cwm_gen.sh vm_name vm_ip entry program"
	exit 1
fi

CWMRC="~/.cwmrc"
VMNAME=${1}-vm
IP=${2}
ENTRY=${3}
COMMAND=${4}
CONFIGPATH=/sandbox/vmconf
IMAGESPATH=/sandbox/images
VMOS="$VMNAME".qcow2
VMHOME="$VMNAME"-home.qcow2
VMOSP="$IMAGESPATH"/"$VMOS"
VMHOMEP="$IMAGESPATH"/"$VMHOME"

if ! [[ -f "$VMOSP" && -f "$VMHOMEP" ]]
then
	echo "VM with that name does not exist"
	echo "\nAvailable VMs:"
	./list_vms.sh
	exit 1
fi

mkdir -p ~/.local/share/applications

DEST="~/.local/share/applications/${VMNAME}-${ENTRY}.desktop"
TMPFILE="/tmp/${VMNAME}-${ENTRY}.desktop"

test -f "$DEST" && xdg-desktop-menu uninstall "$DEST"

cat <<EOF > "${TMPFILE}"
[Desktop Entry]
Type=Application
Exec=ssh user@$IP -Y $COMMAND
Name=$VMNAME-${ENTRY}
Categories=OpenQube
Terminal=False
Type=Application
EOF

xdg-desktop-menu install "${TMPFILE}"
rm "${TMPFILE}"

echo "$2 on $1 desktop file generated"

