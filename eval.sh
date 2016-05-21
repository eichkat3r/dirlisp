#!/bin/sh

# ba_eval.sh
# evaluates a bash arithmetics expression

INPUT=

while getopts ":i:" OPT; do
    case $OPT in
    i)
        INPUT="$OPTARG"
        ;;
    \?)
        echo "Unknown option -$OPTARG" >&2
        exit
        ;;
    :)
        echo "No argument given for -$OPTARG" >&2
        exit
        ;;
    esac
done

if [[ -z $INPUT ]]; then
    INPUT="$@"
fi

if [[ -z $INPUT ]]; then
    echo "$INPUT"
    echo "No input specified." >&2
    exit
fi

cd "$INPUT"

function traverse {
    TL_DIR="$1"
    cd "$TL_DIR"
    TL_DIR_ID=$(echo "$TL_DIR" | cut -d"_" -f1)
    TL_DIR_OP=$(echo "$TL_DIR" | cut -d"_" -f2)
    
    OPERANDS=()
    
    FILES=$(find . -maxdepth 1 -mindepth 1 -printf '%f\n' | sort -n)
    
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


DIRS=$(find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort -n)

for DIR in $DIRS; do
    traverse $DIR
done
