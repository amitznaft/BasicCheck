#!/bin/bash
folderName=$1
executeble=$2
curentLocation=`pwd`

cd $folderName
make > /dev/null
isfullMake=$?
if [[ isfullMake -gt '0' ]]; then
        echo "Compilation Fail"
        exit 7
else
        echo "Compilation Pass"
fi

valgrind --log-file=/dev/null ./$executeble $@
valgridout=$?
if [[ valgridout -eq '0' ]]; then
        leaks=0
else
        leaks=1

fi

valgrind --tool=helgrind --log-file=/dev/null ./$executeble
thredrace=$?

if [[ thredrace -eq '0' ]]; then
        isthredrace=0
else
        isthredrace=1
fi
result=$leaks$isthredrace
if [[ $result == '00' ]]; then
        echo "Memory leaks:PASS, thread race: PASS"
        exit 0
elif [[ $result == '01' ]]; then
        echo "Memory leaks:PASS, thread race:FAIL"
elif [[ $result == '10' ]]; then
        echo "Memory leaks:FAIL , thred race : PASS"
        exit 2
else
        echo "Memory leaks :FAIL , thred race :FAIL"
        exit 3
fi
