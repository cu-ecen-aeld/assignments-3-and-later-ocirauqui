#!/bin/sh
#Script for assignment 1
#These are the instructions for this script:
# -Accepts the following runtime arguments: the first argument is a path to a directory on the filesystem, referred to below as filesdir; the second argument is a text string which will be searched #within these files, referred to below as searchstr
# - Exits with return value 1 error and print statements if any of the parameters above were not specified
#
# - Exits with return value 1 error and print statements if filesdir does not represent a directory on the filesystem
#
# - Prints a message "The number of files are X and the number of matching lines are Y" where X is the number of files in the directory and all subdirectories and Y is the number of matching lines found in respective files, where a matching line refers to a line which contains searchstr (and may also contain additional content).


if [ "$#" != "2" ]; then
	echo "ERROR: invalid number of arguments"
	echo "Total number of arguments should be 2"
	exit 1
else
	#First argument
	filesdir=$1
	#Second argument
	searchstr=$2
	
	if [ ! -d "$filesdir" ]; then
		echo "directory does not exist"
		exit 1
	fi
fi

#Buscar todos los ficheros
X=$(find  "$filesdir" -type f | wc -l)
Y=$(grep -r -o "$searchstr" "$filesdir" | wc -l)

echo "The number of files are $X and the number of matching lines are $Y"


