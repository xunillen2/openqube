#!/bin/sh

CONFIGPATH=/sandbox/config

for vmconf in $CONFIGPATH/*
do
	filename=$(basename $vmconf)
	TEMPLATE=$(cat $vmconf | grep "#template" | cut -d':' -f2)
	echo "\t- ${filename%-vm.conf} \t template: $TEMPLATE"
done
exit 0
