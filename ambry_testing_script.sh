#!/bin/sh

HW=04
REPEAT=5
GENERATOR=./b0b36prp-hw$HW-genref
FOLDER_NAME=files
TESTED_PROGRAM=./hw$HW-b0b36prp

echo "Welcome to Ambry's (amborjak) script for testing PRP HW"

if [ "$1" = "-osx" ]
then
	echo "Build for osx has been selected."
	GENERATOR=./b0b36prp-hw$HW-genref-osx
fi

rm -rf $FOLDER_NAME
mkdir $FOLDER_NAME
echo "Directory was creted: $FOLDER_NAME"
echo "------ $GENERATOR use for creating $REPEAT examples ------\n"

for i in `seq 0 $REPEAT`
do
   PROBLEM=$FOLDER_NAME/hw$HW-$i
   echo "Generate random input '$PROBLEM.in'"
   $GENERATOR -generate > $PROBLEM.in 2>/dev/null #lol - all errors to NULL
   echo "Solve '$PROBLEM.in' and store the reference solution to '$PROBLEM.out' and reference errors to $PROBLEM.err"
   $GENERATOR < $PROBLEM.in > $PROBLEM.out 2>$PROBLEM.err
done
echo "------  Generating complete! ---------\n"

echo "Now creating solutions by '$TESTED_PROGRAM':"
if test -f $TESTED_PROGRAM;then
    for i in `seq 0 $REPEAT`
    do
        PROBLEM=$FOLDER_NAME/hw$HW-$i
        echo "Solving '$PROBLEM.in', solution to '$PROBLEM-my.out', errors to $PROBLEM-my.err"
        $TESTED_PROGRAM < $PROBLEM.in > $PROBLEM-my.out 2>$PROBLEM-my.err
    done
else
    echo "File $TESTED_PROGRAM does not exists and cannot be used to solve the problems.\n Aborting!"
    return 1
fi
echo "-------- Success! -----------\n"

echo "Comparing results using diff"
for i in `seq 0 $REPEAT`
do
    PROBLEM=$FOLDER_NAME/hw$HW-$i
    echo "Comparing '$PROBLEM.out' and '$PROBLEM-my.out':"
    diff $PROBLEM.out $PROBLEM-my.out
    echo "Comparing '$PROBLEM.err' and '$PROBLEM-my.err':"
    diff $PROBLEM.err $PROBLEM-my.err
done
echo "Testing complete. This script terminates here!"
return 0