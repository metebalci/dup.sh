#!/bin/bash

rm -rf test.a test.b test.samea test.folder
./dup.sh clean

echo a > test.a
echo b > test.b
echo a > test.samea
mkdir test.folder
echo b > test.folder/test.sameb

./dup.sh delete

if [ ! -f ./test.a ]; then
	echo "fail test.a does not exist"
	exit 1
else
	echo "success test.a do exist"
fi

if [ ! -f ./test.b ]; then
	echo "fail test.b does not exist"
	exit 1
else
	echo "success test.b do exist"
fi

if [ -f ./test.samea ]; then
	echo "fail test.samea do exist"
	exit 1
else
	echo "success test.samea does not exist"
fi

if [ -f ./test.folder/test.sameb ]; then
	echo "fail test.folder/test.sameb do exist"
	exit 1
else
	echo "success test.folder/test.sameb does not exist"
fi
