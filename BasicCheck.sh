#Names of team members:
#Amit Znaft
#Yuval Cohen

#!/bin/bash
folderName=$1
executable=$2
currentLocation=`pwd`
shift 2
cd $folderName
make
isMake=$?
if [ "$isMake" -gt "0" ] ; then
        echo "Compilation FAIL"
        exit 7
fi

valgrind --leak-check=full --error-exitcode=1 ./$executable $@ &> /dev/null
valout=$?
if [ "$valout" -eq "0" ] ; then
        errorval=0
else
        errorval=1
fi

valgrind --tool=helgrind --error-exitcode=1 ./$executable $@ &> /dev/null
halout=$?
if [ "$halout" -eq "0" ] ; then
        errorhal=0
else
        errorhal=1
fi


check=$errorval$errorhal
if [ "$check" -eq "00" ] ; then
        echo "Compilation PASS  Memory leaks PASS       Tread race PASS"
        exit 0
elif [ "$check" -eq "10" ] ; then
        echo "Compilation PASS  Memory leaks FAIL       Tread race PASS"
        exit 2
elif [ "$check" -eq "01" ] ; then
        echo "Compilation PASS  Memory leaks PASS       Tread race FAIL"
        exit 1
else
        echo "Compilation PASS  Memory leaks FAIL       Tread race FAIL"
        exit 3
fi
