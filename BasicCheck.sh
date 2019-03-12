#!/bin/bash
folderName=$1
executable=$2
currentLocation=`pwd`
shift 2
cd $folderName
make 
checkMake=$?
if [ “$checkMake” -gt 0 ] ; then
        echo "Compilation Error"
        exit 7	
fi

valgrind —-leak-check=full --error-exitcode=1 ./$executable $@ &> /dev/null
valout=$?
if [ “$valout” -eq “0” ] ; then
	errorval=0
else 
	errorval=1
fi

valgrind --tool=helgrind —-error-exitcode=1 ./$executable $@ &> /dev/null
threads=$?
if [ “$threads” -eq “0” ] ; then
	errorHel=0
else 
	errorHel=1
fi


check=$errorval$errorHel
if [ "$check" -eq “00” ] ; then
        echo "Compilation PASS , Memory leaks :PASS , thred race :PASS"
        exit 0
elif [ "$check" -eq “10” ] ; then
        echo "Compilation PASS , Memory leaks:FAIL , thred race : PASS"
	exit 2
elif [ "$check" -eq “01” ] ; then
        echo "Compilation PASS , Memory leaks:PASS , thred race : FAIL”
        exit 1
else
        echo "Compilation PASS , Memory leaks :FAIL , thred race :FAIL”
        exit 3
fi
