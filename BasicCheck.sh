#!/bin/bash
folderName=$1
executeble=$2
curentLocation=`pwd`
shift 2
cd $folderName
make 
cheakVal=$?
if [ “$cheakVal” -gt “0” ] ; then
        echo "Compilation Error"
        exit 7	
fi

valgrind —-leak-check=full --error-exitcode=1 ./$executeble $@ &> /dev/null
valout=$?
if [ “$valout” -eq “0” ] ; then
	er=0
else 
	er=1
fi

valgrind --tool=helgrind —-error-exitcode=1 ./$executeble $@ &> /dev/null
threads=$?
if [ “$threads” -eq “0” ] ; then
	et=0
else 
	et=1
fi


valthr=$er$et
if [ "$valthr" -eq “00” ] ; then
        echo "Compilation PASS , Memory leaks :PASS , thred race :PASS"
        exit 0
elif [ "$valthr" -eq “10” ] ; then
        echo "Compilation PASS , Memory leaks:FAIL , thred race : PASS"
	exit 2
elif [ "$valthr" -eq “01” ] ; then
        echo "Compilation PASS , Memory leaks:PASS , thred race : FAIL”
        exit 1
else
        echo "Compilation PASS , Memory leaks :FAIL , thred race :FAIL”
        exit 3
fi
