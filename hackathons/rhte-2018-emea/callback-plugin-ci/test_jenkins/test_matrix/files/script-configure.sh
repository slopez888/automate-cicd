#!/bin/bash
# Dummy configure script for tests
# Default return codes etc can be overwritten by the right files in /var/tmp
# Call this script with --help to get a list of possible files

BASE=/var/tmp/$(basename $0)

if [ "$1" == "--help" ]
then
	echo "Usage: $0 --result <failed|success> --conf </path/to/sdk.conf>" >&2
	echo "Influenced by ${BASE}.<stdout|stderr|rc>" >&2
	echo "Writes to ${BASE}.log" >&2
	exit 0
fi

function get_value()
{
	if [ -e "${BASE}.$1" ]
	then
		cat "${BASE}.$1"
	else
		echo "$2"
	fi
}

if [ -e "${BASE}.stdout" ]
then
	cat "${BASE}.stdout"
fi

if [ -e "${BASE}.stderr" ]
then
	cat "${BASE}.stderr" >&2
fi

rc=$(get_value rc 0)

echo "$(date) - '$0' called with '$@', rc=${rc}" >> ${BASE}.log

exit ${rc}
