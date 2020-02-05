#!/bin/bash

rm -rf test.a test.b test.samea test.folder
./dup.sh clean

echo a > test.a
echo b > test.b
echo a > test.samea
mkdir test.folder
echo b > test.folder/test.sameb

./dup.sh prepare

test1=`grep test.a .dup.file_hashes` 
test2=`grep test.b .dup.file_hashes` 
test3=`grep test.sameb .dup.file_hashes` 
test4=`grep test.samea .dup.file_hashes` 

if [[ $test1 != "3f786850e387550fdab836ed7e6dc881de23001b  ./test.a" ]]; then
	echo "fail"
	exit 1
fi

if [[ $test2 != "89e6c98d92887913cadf06b2adb97f26cde4849b  ./test.b" ]]; then
	echo "fail"
	exit 1
fi

if [[ $test3 != "89e6c98d92887913cadf06b2adb97f26cde4849b  ./test.folder/test.sameb" ]]; then
	echo "fail"
	exit 1
fi

if [[ $test4 != "3f786850e387550fdab836ed7e6dc881de23001b  ./test.samea" ]]; then
	echo "fail"
	exit 1
fi
