#!/bin/bash

rm -rf test.a test.b test.samea test.folder
./dup.sh clean

echo a > test.a
echo b > test.b
echo a > test.samea
mkdir test.folder
echo b > test.folder/test.sameb

./dup.sh move

if [ -f ./test.a ]; then
	echo "success test.a do exist"
else
	echo "fail test.a does not exist"
	exit 1
fi

if [ -f ./test.b ]; then
	echo "success test.b do exist"
else
	echo "fail test.b does not exist"
	exit 1
fi

if [ -f .dup.moved_files/test.samea ]; then
	echo "success test.samea is at moved folder"
else
	echo "test.samea is not at moved folder"
	exit 1
fi

if [ -f .dup.moved_files/test.folder/test.sameb ]; then
	echo "success test.folder/test.sameb is at moved folder"
else
	echo "test.folder/test.sameb is not at moved folder"
	exit 1
fi
