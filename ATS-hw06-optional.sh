#!/bin/sh
#Ambry's testing script for PRP Homeworks
#Version 3.0, 30.10.2020

HW=06
REPEAT=25
GENERATOR="./b0b36prp-hw$HW-genref -optional"
FOLDER_NAME=files
TESTED_PROGRAM=./hw$HW-b0b36prp
VERBOSE=0

# We use "$@" instead of $* to preserve argument-boundary information
ARGS=$(getopt -o 'vh' --long 'verbose,help' -- "$@") || exit
eval "set -- $ARGS"
while true; do
    case $1 in
        (-v|--verbose)
            VERBOSE=$(($VERBOSE+1)); shift;;
        (--)  shift; break;;
        (*)   exit 1;;           # error
    esac
done

remaining=$("$@")

if [ $VERBOSE -ge 1 ];then
    echo "Welcome to Ambry's (amborjak) script for testing PRP HW, Version 3.0 - 30.10.2020"
    echo "If you want the latest version or you have found some issues/bugs go to:"
    echo "https://gitlab.fel.cvut.cz/ambrojak/prp_hw_tester"
    echo "https://github.com/AmbryTheBlue/PRP_HW_tester"
    echo "You can also request new features, but ..."
fi


if [ "$1" = "-osx" ]
then
	echo "Build for osx has been selected."
	GENERATOR=./b0b36prp-hw$HW-genref-osx
fi

rm -rf $FOLDER_NAME
mkdir $FOLDER_NAME
echo "Directory was creted: $FOLDER_NAME"
echo "------ $GENERATOR will be used for creating $REPEAT examples ------"

for i in $(seq 0 $REPEAT)
do
   PROBLEM=$FOLDER_NAME/hw$HW-$i
   if [ $VERBOSE -ge 1 ];then
   echo "Generate random input '$PROBLEM.in'"
   fi
   $GENERATOR -generate > $PROBLEM.in 2>/dev/null #lol - all errors to NULL
   if [ $VERBOSE -ge 1 ];then
   echo "Solve '$PROBLEM.in' and store the reference solution to '$PROBLEM.out' and reference errors to $PROBLEM.err"
   fi
   $GENERATOR < $PROBLEM.in > $PROBLEM.out 2>$PROBLEM.err
done
echo "------  Generating complete! ---------\n"

echo "Now creating solutions by '$TESTED_PROGRAM':"
if test -f $TESTED_PROGRAM;then
    for i in `seq 0 $REPEAT`
    do
        PROBLEM=$FOLDER_NAME/hw$HW-$i
        if [ $VERBOSE -ge 1 ];then
        echo "Solving '$PROBLEM.in', solution to '$PROBLEM-my.out', errors to $PROBLEM-my.err"
        fi
        $TESTED_PROGRAM < $PROBLEM.in > $PROBLEM-my.out 2>$PROBLEM-my.err
    done
else
    echo "File $TESTED_PROGRAM does not exists and cannot be used to solve the problems.\n Aborting!"
    return 1
fi

echo "Comparing results using diff"
FOUND_ISSUES=0
for i in `seq 0 $REPEAT`
do
    PROBLEM=$FOLDER_NAME/hw$HW-$i
    DIFFERNCE=$(diff $PROBLEM.out $PROBLEM-my.out)
    if [ $VERBOSE -ge 1 ];then
        echo "Comparing '$PROBLEM.out' and '$PROBLEM-my.out':"
        if [ "$DIFFERNCE" != "" ]; then
            FOUND_ISSUES=$(($FOUND_ISSUES+1))
            echo $DIFFERNCE
        fi
    else
        if [ "$DIFFERNCE" != "" ]; then
            echo "Comparing '$PROBLEM.out' and '$PROBLEM-my.out':$DIFFERNECE"
            echo $DIFFERNCE
            FOUND_ISSUES=$(($FOUND_ISSUES+1))
        fi
    fi

    DIFFERNCE=$(diff $PROBLEM.err $PROBLEM-my.err)
    if [ $VERBOSE -ge 1 ];then
        echo "Comparing '$PROBLEM.err' and '$PROBLEM-my.err':"
        if [ "$DIFFERNCE" != "" ]; then
        echo $DIFFERNCE
        FOUND_ISSUES=$(($FOUND_ISSUES+1))
        fi
    else
        if [ "$DIFFERNCE" != "" ]; then
        echo "Comparing '$PROBLEM.err' and '$PROBLEM-my.err':"
        echo $DIFFERNCE
        FOUND_ISSUES=$(($FOUND_ISSUES+1))
        fi
    fi
done
echo "Overall $FOUND_ISSUES issues were found!"
PUBLIC_PATH=data/opt
echo "-------- Using public examples --------"
if [ -e $PUBLIC_PATH ];then
    i=1
    FOUND_ISSUES=0
    while :
    do
        if [ $i -le 9 ];then
            PUB_FILE=$PUBLIC_PATH/pub0"$i"-o
        else
            PUB_FILE=$PUBLIC_PATH/pub"$i"-o
        fi

        if [ -f $PUB_FILE.in ];then
            $TESTED_PROGRAM <$PUB_FILE.in >$PUB_FILE-my.out 2> $PUB_FILE-my.err
            if [ $VERBOSE -ge 1 ];then
                echo "Solving '$PUB_FILE.in', solution to '$PUB_FILE-my.out', errors to $PUB_FILE-my.err"
                DIFFERNCE=$(diff $PUB_FILE.out $PUB_FILE-my.out)
                echo "Comaparing $PUB_FILE.out $PUB_FILE-my.out :"
                if [ "$DIFFERNCE" != "" ]; then
                    echo $DIFFERNCE
                    FOUND_ISSUES=$(($FOUND_ISSUES+1))
                fi
                DIFFERNCE=$(diff $PUB_FILE.err $PUB_FILE-my.err)
                echo "Comaparing $PUB_FILE.err $PUB_FILE-my.err :"
                if [ "$DIFFERNCE" != "" ]; then
                    echo $DIFFERNCE
                    FOUND_ISSUES=$(($FOUND_ISSUES+1))
                fi
            else
                DIFFERNCE=$(diff $PUB_FILE.out $PUB_FILE-my.out)
                if [ "$DIFFERNCE" != "" ]; then
                    echo "Comaparing $PUB_FILE.out $PUB_FILE-my.out :"
                    echo $DIFFERNCE
                    FOUND_ISSUES=$(($FOUND_ISSUES+1))
                fi
                DIFFERNCE=$(diff $PUB_FILE.err $PUB_FILE-my.err)
                if [ "$DIFFERNCE" != "" ]; then
                    echo "Comaparing $PUB_FILE.err $PUB_FILE-my.err :"
                    echo $DIFFERNCE
                    FOUND_ISSUES=$(($FOUND_ISSUES+1))
                fi
            fi
        else
            if [ $VERBOSE -ge 1 ];then
                echo "Public file $PUB_FILE.in doesn't exist. Testing pub files ends here."
            fi
            echo "Overall $FOUND_ISSUES issues were found!"
            break
        fi
        i=$(($i+1))
    done
else
    echo "Folder ($PUBLIC_PATH) used for public examples not found"
fi
echo "Testing complete! If any errors ocurred go to following URL and raise issue"
echo "https://gitlab.fel.cvut.cz/ambrojak/prp_hw_tester"
return 0
