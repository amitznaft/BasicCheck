#!/bin/bash
folderName=$1
executeble=$2
shift 2
curentLocation=`pwd`
cd $folderName
make > /dev/null
cheakVal=$?
if [[ $cheakVal -gt 0 ]]; then
        echo "Compilation Error"
        exit 7
else
        echo "Compilation Pass"
fi

valgrind —-leak-check=full --error-exitcode=1 ./$executeble $@ &> /dev/null
valout=$?

valgrind --tool=helgrind —-error-exitcode=1 ./$executeble $@ &> /dev/null
threads=$?

echo $valout
echo $threads

if [[ $valout -eq 1 ]] && [[ $threads -eq 1 ]]; then
        echo "Memory leaks:FAIL, thread race: FAIL"
	cd $currentLocation
        exit 3
elif [[ $valout -eq 0 ]] && [[ $threads -eq 1 ]]; then
        echo "Memory leaks:PASS, thread race:FAIL"
	cd $currentLocation
	exit 1
elif [[ $valout -eq 1 ]] && [[ $threads -eq 0 ]]; then
        echo "Memory leaks:FAIL , thred race : PASS"
	cd $currentLocation
        exit 2
else
        echo "Memory leaks :PASS , thred race :PASS"
	cd $currentLocation
        exit 0
fi
