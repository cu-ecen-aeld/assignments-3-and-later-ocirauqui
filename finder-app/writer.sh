#!/bin/sh
#Script for assignment 1
#Instructions for the script:
#  -Accepts the following arguments: the first argument is a full path to a file (including #filename) on the filesystem, referred to below as writefile; the second argument is a text #string which will be written within this file, referred to below as writestr
#  -Exits with value 1 error and print statements if any of the arguments above were not #specified
#  -Creates a new file with name and path writefile with content writestr, overwriting any #existing file and creating the path if it doesn’t exist. Exits with value 1 and error print #statement if the file could not be created.

if [ "$#" != "2" ]; then
	echo "ERROR: invalid number of arguments"
	echo "Total number of arguments should be 2"
	exit 1
else
	#First argument
	writefile=$1
	#Second argument
	writestr=$2
	#echo "$(dirname $writefile)"
	mkdir -p "$(dirname $writefile)" 
	if ! touch "$writefile"; then
		echo "ERROR: could not create file"
		exit 1
	fi 
	echo "$writestr"> "$writefile"

fi
