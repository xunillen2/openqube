#!/bin/sh

CONFIGPATH=/sandbox/config

for vmconf in $CONFIGPATH/*
do
	filename=$(basename $vmconf)
	vmname=${filename%-vm.conf}-vm
	template=$(cat $vmconf | grep "#template" | cut -d':' -f2)
	status=$(vmctl status | grep $vmname | awk '{print $8}')
	ID=$(grep -E '^#id:.*[0-9]$' "$vmconf" | cut -d':' -f 2)
	if [[ $status == "" || $status == "stopped" ]]
	then
		printf "\t - %-10s%-10s%10s%25s\n" "${filename%-vm.conf}" "id:$ID" "template: $template" "status: not running"
	elif
	then
		printf "\t - %-10s%-10s%10s%20s\n" "${filename%-vm.conf}" "id:$ID" "template: $template" "status: $status"
	fi
done
exit 0
