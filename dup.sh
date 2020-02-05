#!/bin/bash

clean() {
	
	rm -f .dup.file_list .dup.file_hashes .dup.duplicate_hashes .dup.duplicate_files .dup.remaining_files

}

file_list () {

	if [ -f .dup.file_list ]; then

		echo ".reusing existing file_list"

	else

		echo "creating file_list"

		# processes only regular files (type f)
		find . -type f > .dup.file_list

		if [ $? -ne 0 ]; then
			echo "error: find failed"
			exit 1
		fi

	fi

	echo ".number of files: $(wc -l .dup.file_list | xargs | cut -f1 -d' ')"

}

file_hashes () {

	file_list

	echo "calculating file_hashes"

	if [ -f .dup.file_hashes ]; then

		echo ".using existing file_hashes to find what is missing and only calculating their hashes"

		# combine existing file names in .dup.file_hashes and .dup.file_list
		# sort and find uniq ones (so it only exists in .dup.file_list)
		# calculate hashes only for that files and append to .dup.file_hashes
		cut -c43- .dup.file_hashes | cat .dup.file_list - | sort | uniq -u > .dup.remaining_files

		echo ".number of hashes missing to calculate: $(wc -l .dup.remaining_files | xargs | cut -f1 -d' ')"

		cat .dup.remaining_files | parallel --bar --max-args 1 sha1sum {}">>" .dup.file_hashes

		# exit here if there is a problem in paralel execution
		if [ $? -ne 0 ]; then
			echo "error: parallel failed"
			exit 1
		fi

	else

		echo ".calculating hashes of all files"

		# create an empty file
		touch .dup.file_hashes

		# calculates sha1 for every file in file list in parallel
		cat .dup.file_list | parallel --bar --max-args 1 shasum {} ">>" .dup.file_hashes

		# exit here if there is a problem in paralel execution
		if [ $? -ne 0 ]; then
			echo "error: parallel failed"
			exit 1
		fi

	fi

}

duplicate_hashes () {

	if [ -f .dup.duplicate_hashes ]; then

		echo ".using existing duplicate_hashes"

	else

		file_hashes

		echo "finding duplicate_hashes"

		# finds duplicate hashes, unique files are excluded from processing here
		sort .dup.file_hashes | cut -c-40 | uniq -d > .dup.duplicate_hashes
		
	fi

}

duplicate_files () {

	if [ -f .dup.duplicate_files ]; then

		echo ".using existing duplicate_files"

	else 

		echo "finding duplicate_files"

		duplicate_hashes
		
		# reseting the file first because only appending below
		rm -f .dup.duplicate_files
		touch .dup.duplicate_files

		cat .dup.duplicate_hashes | while read hash; do

			# append the files having same hash
			grep $hash .dup.file_hashes | cut -c43- | sort >> .dup.duplicate_files
			# append an empty line
			echo "" >> .dup.duplicate_files

		done

	fi

}

prepare() {

	duplicate_files
	
	numfiles=$(wc -l .dup.file_list | xargs | cut -f1 -d' ')
	numsets=$(wc -l .dup.duplicate_hashes | xargs | cut -f1 -d' ')
	numfilesinsets=$(grep -f .dup.duplicate_hashes .dup.file_hashes | wc -l | xargs | cut -f1 -d' ')

	echo "number of files: $numfiles"
	echo "number of duplicate sets (set=files having same hash): $numsets"
	echo "number of files in duplicate sets: $numfilesinsets"

}

move () {

	# true if real move requested
	mode=$1

	file_hashes
	duplicate_hashes

	# create the move folder if real move requested
	if $mode; then
		mkdir .dup.moved_files
	fi

	# for each hash
	cat .dup.duplicate_hashes | while read hash; do

		first=true

		# find the files with this hash value
		grep $hash .dup.file_hashes | cut -c43- | sort | while read file; do

			# omit the first file
			if $first; then
				first=false
				continue
			fi

			# find the dir and base of file
			dir=$(dirname "$file")
			base=$(basename "$file")

			if $mode; then

				# create the intermediate directory
				mkdir -p ".dup.moved_files/$dir"
				# move the file
				mv "$file" ".dup.moved_files/$dir/$base"

			else

				# just print the potential move command
				echo "mv $(file) .dup.moved_files/$dir/$base"

			fi

		done

	done

}

delete () {

	# true if real delete requested
	mode=$1

	file_hashes
	duplicate_hashes

	# for each hash
	cat .dup.duplicate_hashes | while read hash; do

		first=true

		# find the files with this hash value
		grep $hash .dup.file_hashes | cut -c43- | sort | while read file; do

			# omit the first file
			if $first; then
				first=false
				continue
			fi

			if $mode; then

				rm -f "$file"

			else

				# just print the potential delete command
				echo "rm -f $file"

			fi

		done

	done

}

if [ ! -x "$(command -v shasum)" ]; then
	echo "error: please install shasum program."
	exit 1
fi

if [ ! -x "$(command -v parallel)" ]; then
	echo "error: please install gnu parallel program."
	exit 1 
fi

# the move folder should not already exist
if [ -d .dup.moved_files ]; then
	echo "error: .dup.moved_files folder exists. please move it somewhere else or remove it."
	exit 1
fi

case "$1" in

	clean)
		clean
		;;

	file_list)
		file_list
		;;

	file_hashes)
		file_hashes
		;;

	duplicate_hashes)
		duplicate_hashes
		;;

	duplicate_files)
		duplicate_files
		;;

	prepare)
		prepare
		;;

	testmove)
		move false
		;;

	move)
		move true
		;;

	testdelete)
		delete false
		;;

	delete)
		delete true
		;;

	*)
		echo ""
		echo "dup.sh: finds duplicate regular files in folders, uses sha1 and gnu parallel"
		echo "				optionally moves all duplicate files but one to a folder"
		echo ""
		echo "description: dups.sh it runs in stages:"
		echo "				1) creates file list: output .dup.file_list"
		echo "				2) calculates file hashes: output .dup.file_hashes"
		echo "				3) finds duplicate hashes: output .dup.duplicate_hashes"
		echo "				4) finds duplicate files: output .dup.duplicate_files"
		echo "				the order is like this but you can delete individual files and they will be recreated using previous files as it is."
		echo "				.dup.file_list and .dup.file_hashes are always compared, and if a difference is found, these hashes arecalculated."
		echo "				move (and test) uses only .dup.duplicate_hashes"
		echo ""
		echo "usage: dup.sh clean|prepare|test|move"
		echo ""
		echo "	clean: removes the dup processing and temporary files, but not moved files folder"
		echo "	prepare: creates dup processing files, it can be used to break the processing into calculating hashes and actually moving files."
		echo "	test: shows the mv commands, does not execute them, nothing is moved, creates processing files if needed"
		echo "	move: actually moves all duplicate files but one, creates processing files if needed"
		echo ""
		echo "	processing files are created if they do not exist, this allows partial processing. the files are:"
		echo ""		 
		echo "	- .dup.file_list: list of all regular files in all subfolders"
		echo "	- .dup.file_hashes: (sha1) hashes of all files in file_list"
		echo "	- .dup.duplicate_hashes: list of duplicate hashes in file_hashes"
		echo "	- .dup.duplicate_files: list of duplicate files grouped and groups are separeted by one empty line"
		echo ""
		echo "	recommended use:"
		echo "		- run dup.sh clean"
		echo "		- run dup.sh prepare, and check .dup.duplicate_files"
		echo "		- run dup.sh move, and check files remained and .dup.moved_files folder"
		echo "		- delete .dup.moved_files folder if you are sure all are OK"
		echo ""
		echo "  temporary files:"
		echo "	- dup.remaining_files"
		echo ""
		echo "  it is possible to run each stage individually by file_list, file_hashes, duplicate_hashes, duplicate_files commands"
		echo ""

esac
