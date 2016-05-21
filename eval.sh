#!/bin/sh

# ba_eval.sh
# evaluates a bash arithmetics expression

CWD=.

cd $CWD
cd root


function traverse {
    TL_DIR="$1"
    cd "$TL_DIR"
    TL_DIR_ID=$(echo "$TL_DIR" | cut -d"_" -f1)
    TL_DIR_OP=$(echo "$TL_DIR" | cut -d"_" -f2)
    
    OPERANDS=()
    
    FILES=$(find . -maxdepth 1 -mindepth 1 -printf '%f\n')
    
    for FILE in $FILES; do
        VALUE=
        
        if [[ -d $FILE ]]; then
            VALUE=$(traverse "$FILE")
        else
            VALUE=$(cat "$FILE")
        fi
        
        OPERANDS+=("$VALUE")
    done
    
    RESULT=${OPERANDS[0]}
    
    for OPERAND in ${OPERANDS[@]:1}; do
        case $TL_DIR_OP in
        "add")
            (( RESULT+=OPERAND ))
            ;;
        "sub")
            (( RESULT-=OPERAND ))
            ;;
        "mul")
            (( RESULT*=OPERAND ))
            ;;
        "div")
            (( RESULT/=OPERAND ))
            ;;
        esac
    done
    
    cd ..
    
    echo "$RESULT"
}


DIRS=$(find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n')

for DIR in $DIRS; do
    traverse $DIR
done
