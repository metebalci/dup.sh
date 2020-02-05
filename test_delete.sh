#!/bin/bash

rm -rf "te st.a" test.b test.samea "te st.folder"
./dup.sh clean

echo a > "te st.a"
echo b > test.b
echo a > test.samea
mkdir "te st.folder"
echo b > "te st.folder/te st.sameb"

./dup.sh delete

if [ ! -f "./te st.a" ]; then
	echo "fail te st.a does not exist"
	exit 1
else
	echo "success te st.a do exist"
fi

if [ -f test.b ]; then
	echo "fail test.b do exist"
	exit 1
else
	echo "success test.b does not exist"
fi

if [ -f test.samea ]; then
	echo "fail test.samea do exist"
	exit 1
else
	echo "success test.samea does not exist"
fi

if [ ! -f "te st.folder/te st.sameb" ]; then
	echo "fail te st.folder/te st.sameb does not exist"
	exit 1
else
	echo "success te st.folder/te st.sameb do exist"
fi
