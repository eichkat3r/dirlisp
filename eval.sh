#!/bin/sh

# ba_eval.sh
# evaluates a bash arithmetics expression

CWD=.

cd $CWD
cd root

RESULT=

function evaluate {
    cd $1
    
    local OP=$(echo $DIR | cut -f2 -d'_')
    local DIRS=$(find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
    local OPERANDS=()
    
    if [ -n "$DIRS" ]; then
        for DIR in $DIRS; do
            DIRVAL=$(evaluate "$DIR")
            OPERANDS+=("$DIRVAL")
        done
    fi
    
    local FILES=$(find . -maxdepth 1 -mindepth 1 -type f -printf '%f\n')
    
    if [ -n "$FILES" ]; then
        for FILE in "$FILES"; do
            O="$(cat $FILE)"
            OPERANDS+=("$O")
        done
    fi
    
    RESULT=0
    
    case "$OP" in
    "add")
        RESULT=${OPERANDS[0]}
        ;;
    "sub")
        RESULT=${OPERANDS[0]}
        ;;
    "div")
        ;;
    "mul")
        RESULT=${OPERANDS[0]}
        ;;
    esac
    
    echo $RESULT
}

DIRS=$(find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n')

for DIR in $DIRS; do
    evaluate $DIR
done