#!/bin/bash
folderName=$1
executeble=$2
curentLocation=`pwd`

cd $folderName
make > /dev/null
cheakVal=$?
if [[ cheakVal -gt '0' ]]; then
        echo "Compilation Error"
        exit 7
else
        echo "Compilation Pass"
fi

valgrind —error-exitcode=1 —-leak-check=full-v ./$executeble $@
valout=$?
if [[ valout -eq '0' ]]; then
        leaks=0
else
        leaks=1

fi

valgrind —error-exitcode=1 —tool=helgrind ./$executeble
threads=$?

if [[ threads -eq '0' ]]; then
        isthreads=0
else
        isthreads=1
fi
strCat=$leaks$isthreads
if [[ $strCat == '11' ]]; then
        echo "Memory leaks:FAIL, thread race: FAIL"
        exit 3
elif [[ $strCat == '01' ]]; then
        echo "Memory leaks:PASS, thread race:FAIL"
elif [[ $strCat == '10' ]]; then
        echo "Memory leaks:FAIL , thred race : PASS"
        exit 2
else
        echo "Memory leaks :PASS , thred race :PASS"
        exit 0
fi
