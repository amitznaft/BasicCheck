#!/bin/bash
folderName=$1
executeble=$2
shift 2
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

valgrind —-leak-check=full —-error-exitcode=1 ./$executeble $@ &> /dev/null
valout=$?
if [[ valout -eq '0' ]]; then
        leaks=0
else
        leaks=1

fi

valgrind --tool=helgrind —-error-exitcode=1 --log-file=/dev/null ./$executeble
threads=$?

if [[ threads -eq '0' ]]; then
        isthreads=0
else
        isthreads=1
fi
strCat=$leaks$isthreads
if [[ $strCat == '11' ]]; then
        echo "Memory leaks:FAIL, thread race: FAIL"
	cd $currentLocation
        exit 3
elif [[ $strCat == '01' ]]; then
        echo "Memory leaks:PASS, thread race:FAIL"
	cd $currentLocation
	exit 1
elif [[ $strCat == '10' ]]; then
        echo "Memory leaks:FAIL , thred race : PASS"
	cd $currentLocation
        exit 2
else
        echo "Memory leaks :PASS , thred race :PASS"
	cd $currentLocation
        exit 0
fi
