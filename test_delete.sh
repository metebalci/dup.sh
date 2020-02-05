#!/bin/bash

rm -rf "te st.a" test.b test.samea "te st.folder"
./dup.sh clean

echo a > "te st.a"
echo b > test.b
echo a > test.samea
mkdir "te st.folder"
echo b > "te st.folder/te st.sameb"

./dup.sh delete

test_two () { 

	if [ -f "$1" ]; then
		if [ ! -f "$2" ]; then
			echo "success $1 do exist"
			echo "success $2 does not exist"
		else
			exit 1
		fi
	elif [ ! -f "$1" ]; then
		if [ -f "$2" ]; then
			echo "success $1 does not exist"
			echo "success $2 do exist"
		else
			exit 1
		fi
	else
		exit 1
	fi

}

test_two "te st.a" "test.samea"
test_two "test.b" "te st.folder/te st.sameb"
