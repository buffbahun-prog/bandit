#!/bin/bash

dir_path=$(mktemp -d)
#echo $dir_path

xxd -r "$1" > "$dir_path"/data
cd "$dir_path"

while :; do
	file data | grep 'ASCII' > /dev/null
	if [ "$?" -eq "0" ]; then
		cat data | cut -d' ' -f4
		exit 0
	fi

	file data | grep 'gzip' > /dev/null
	if [ "$?" -eq "0" ]; then
		mv data data.gz
		gzip -d data
	fi

	file data | grep 'bzip2' > /dev/null
	if [ "$?" -eq "0" ]; then
		mv data data.bz2
		bzip2 -dc data.bz2 >> data
		rm data.bz2
	fi


	file data | grep 'tar' > /dev/null
	if [ "$?" -eq "0" ]; then
		mkdir trs
		tar -xf data -C trs/
		cat trs/* >> cat_data
		rm -rf trs
		cat cat_data > data
		rm cat_data
	fi
done

