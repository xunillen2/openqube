#!/bin/sh

CONFIGPATH=/sandbox/config

for vmconf in $CONFIGPATH/*
do
	filename=$(basename $vmconf)
	vmname=${filename%-vm.conf}-vm
	template=$(cat $vmconf | grep "#template" | cut -d':' -f2)
	status=$(vmctl status | grep $vmname | awk '{print $8}')
	if [[ status == "" || status == "stopped" ]]
	then		
		echo "\t- ${filename%-vm.conf} \t template: $template \t status: not running"
	elif
	then
		echo "\t- ${filename%-vm.conf} \t template: $template \t status: $status"
	fi
done
exit 0
