#!/bin/bash

rm -rf "te st.a" test.b test.samea "te st.folder"
./dup.sh clean

echo a > "te st.a"
echo b > test.b
echo a > test.samea
mkdir "te st.folder"
echo b > "te st.folder/te st.sameb"

./dup.sh move

if [ -f "te st.a" ]; then
	echo "success te st.a do exist"
else
	echo "fail te st.a does not exist"
	exit 1
fi

if [ -f .dup.moved_files/test.b ]; then
	echo "success test.b is at moved folder"
else
	echo "fail test.b is not at moved folder"
	exit 1
fi

if [ -f .dup.moved_files/test.samea ]; then
	echo "success test.samea is at moved folder"
else
	echo "fail test.samea is not at moved folder"
	exit 1
fi

if [ -f "te st.folder/te st.sameb" ]; then
	echo "success te st.folder/te st.sameb do exist"
else
	echo "fail te st.folder/te st.sameb does not exist"
	exit 1
fi
