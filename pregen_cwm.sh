#!/bin/sh

if [ "$#" -ne 2 ]
then
	echo "Usage: ./pregen_cwm.sh vm_name vm_ip"
	exit 1
fi

PROGRAMS=""
PROGRAMS="${PROGRAMS} firefox"
PROGRAMS="${PROGRAMS} chrome"
PROGRAMS="${PROGRAMS} libreoffice"
PROGRAMS="${PROGRAMS} mpv"
PROGRAMS="${PROGRAMS} dillo"
PROGRAMS="${PROGRAMS} xterm"
PROGRAMS="${PROGRAMS} thunar"


VMNAME=${1}
IP=${2}
for prog in ${PROGRAMS};
do
	./cwm_gen.sh $VMNAME $IP ${prog} ${prog}
done

