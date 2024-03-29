#!/bin/sh

. ./var_setup.sh

for template in $TEMPLATEPATH/*
do
	filename=$(basename "$template")
	if [[ $filename != *-home.qcow2 && $filename == *.qcow2 ]]
	then
		echo "\t-${filename%.qcow2}"
	fi
done

exit 0
