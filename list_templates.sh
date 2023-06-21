#!/bin/sh


TEMPLATEPATH=/sandbox/templates

for template in $TEMPLATEPATH/*
do
	filename=$(basename "$template")
	if [[ $filename != *-home.qcow2 && $filename == *.qcow2 ]]
	then
		echo "\t-${filename%.qcow2}"
	fi
done

exit 0
