#!/bin/bash

rm -rf "te st.a" test.b test.samea "te st.folder"
./dup.sh clean

echo a > "te st.a"
echo b > test.b
echo a > test.samea
mkdir "te st.folder"
echo b > "te st.folder/te st.sameb"

./dup.sh prepare

test1=`grep "te st.a" .dup.file_hashes` 
test2=`grep test.b .dup.file_hashes` 
test3=`grep test.samea .dup.file_hashes` 
test4=`grep "te st.sameb" .dup.file_hashes` 

if [[ $test1 != "3f786850e387550fdab836ed7e6dc881de23001b  ./te st.a" ]]; then
	echo "fail te st.a"
	exit 1
else
	echo "success te st.a"
fi

if [[ $test2 != "89e6c98d92887913cadf06b2adb97f26cde4849b  ./test.b" ]]; then
	echo "fail test.b"
	exit 1
else
	echo "success test.b"
fi

if [[ $test3 != "3f786850e387550fdab836ed7e6dc881de23001b  ./test.samea" ]]; then
	echo "fail test.samea"
	exit 1
else
	echo "success test.samea"
fi

if [[ $test4 != "89e6c98d92887913cadf06b2adb97f26cde4849b  ./te st.folder/te st.sameb" ]]; then
	echo "fail te st.folder/te st.sameb"
	exit 1
else
	echo "success te st.folder/te st.sameb"
fi
