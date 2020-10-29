#!/bin/sh
#Ambry's testing script for PRP Homeworks
#Version 0.2, 24.10.2020

HW=04
REPEAT=50
GENERATOR=./b0b36prp-hw$HW-genref
FOLDER_NAME=files
TESTED_PROGRAM=./hw$HW-b0b36prp

if [ "$1" = "-osx" ]
then
	echo "Build for osx has been selected."
	GENERATOR=./b0b36prp-hw$HW-genref-osx
fi

rm -rf $FOLDER_NAME
mkdir $FOLDER_NAME
echo "Directory was creted: $FOLDER_NAME"
echo "------ $GENERATOR use for creating $REPEAT examples ------"

for i in $(seq 0 $REPEAT)
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

echo "Comparing results using diff"
for i in `seq 0 $REPEAT`
do
    PROBLEM=$FOLDER_NAME/hw$HW-$i
    echo "Comparing '$PROBLEM.out' and '$PROBLEM-my.out':"
    diff $PROBLEM.out $PROBLEM-my.out
    echo "Comparing '$PROBLEM.err' and '$PROBLEM-my.err':"
    diff $PROBLEM.err $PROBLEM-my.err
done
PUBLIC_PATH=data
echo "Using public examples"
if [ -e $PUBLIC_PATH ];then
    i=1
    while :
    do
        if [ $i -le 9 ];then
            PUB_FILE=data/pub0"$i"
        else
            PUB_FILE=data/pub"$i"
        fi
        if [ -f $PUB_FILE.in ];then
            echo "Solving '$PUB_FILE.in', solution to '$PUB_FILE-my.out', errors to $PUB_FILE-my.err"
            $TESTED_PROGRAM <$PUB_FILE.in >$PUB_FILE-my.out 2> $PUB_FILE-my.err
            echo "Comaparing $PUB_FILE.out $PUB_FILE-my.out :"
            diff $PUB_FILE.out $PUB_FILE-my.out
            echo "Comaparing $PUB_FILE.err $PUB_FILE-my.err :"
            diff $PUB_FILE.err $PUB_FILE-my.err
        else
            echo "Public file $PUB_FILE.in doesn't exist"
            break
        fi
        i=$(($i+1))
    done
else
    echo "Folder ($PUBLIC_PATH) used for public examples not found"
fi
echo "Testing complete. This script terminates here!"
return 0