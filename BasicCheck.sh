#!/bin/bash

folderName=$1

executeble=$2

shift 2

curentLocation=`pwd`

cd $folderName

make > /dev/null

cheakVal=$?

if [ “$cheakVal” -gt “0” ] ; then

        echo "Compilation Error"

        exit 7

else

        echo "Compilation Pass"

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

	cd $currentLocation

        exit 0

elif [ "$valthr" -eq “10” ] ; then

        echo "Compilation PASS , Memory leaks:FAIL , thred race : PASS"

	cd $currentLocation

	exit 2

elif [ "$valthr" -eq “01” ] ; then

        echo "Compilation PASS , Memory leaks:PASS , thred race : FAIL”

	cd $currentLocation

        exit 1

else

        echo "Compilation PASS , Memory leaks :FAIL , thred race :FAIL”

	cd $currentLocation

        exit 3

fi
