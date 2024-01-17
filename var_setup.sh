#!/bin/sh

SETUPPATH="/etc/setup_config.conf"

export CONFIGPATH=$(cat $SETUPPATH | grep configpath | cut -d ':' -f 2)
export TEMPLATEPATH=$(cat $SETUPPATH | grep templatepath | cut -d ':' -f 2)
export ISOPATH=$(cat $SETUPPATH | grep isopath | cut -d ':' -f 2)
export IMAGESPATH=$(cat $SETUPPATH | grep imagepath | cut -d ':' -f 2)
