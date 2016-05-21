#!/bin/sh

# ba_eval.sh
# evaluates a bash arithmetics expression


INPUT=

### handle command line arguments ###

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

# evaluate the file tree recursively
function traverse {
    # function takes directory name as argument
    TL_DIR="$1"
    cd "$TL_DIR"
    # split name into id and operator
    TL_DIR_ID=$(echo "$TL_DIR" | cut -d"_" -f1)
    TL_DIR_OP=$(echo "$TL_DIR" | cut -d"_" -f2)
    
    OPERANDS=()
    
    FILES=$(find . -maxdepth 1 -mindepth 1 -printf '%f\n' | sort -n)
    
    for FILE in $FILES; do
        VALUE=
        
        # directories will be evaluated (recursion)
        if [[ -d $FILE ]]; then
            VALUE=$(traverse "$FILE")
        # files = leaves in syntax tree
        else
            VALUE=$(cat "$FILE")
        fi
        
        OPERANDS+=("$VALUE")
    done
    
    ### evaluate current directory by folding all values ###
    
    case $TL_DIR_OP in
    # number of operands >= 2
    "add"|"sub"|"mul"|"div")
        RESULT=${OPERANDS[0]}
        
        for OPERAND in ${OPERANDS[@]:1}; do
            case $TL_DIR_OP in
            "add")
                RESULT=$(echo "$RESULT+$OPERAND" | bc -l)
                ;;
            "sub")
                RESULT=$(echo "$RESULT-$OPERAND" | bc -l)
                ;;
            "mul")
                RESULT=$(echo "$RESULT*$OPERAND" | bc -l)
                ;;
            "div")
                RESULT=$(echo "$RESULT/$OPERAND" | bc -l)
                ;;
            esac
        done
        ;;
    
    # unary operators
    "not")
        RESULT=$(echo "!${OPERANDS[0]}" | bc -l)
        ;;
    "sqrt")
        RESULT=$(echo "sqrt(${OPERANDS[0]})" | bc -l)
        ;;
    
    # binary operators
    "lte")
        RESULT=$(echo "${OPERANDS[0]}<=${OPERANDS[1]}" | bc -l)
        ;;
    "lt")
        RESULT=$(echo "${OPERANDS[0]}<${OPERANDS[1]}" | bc -l)
        ;;
    "gte")
        RESULT=$(echo "${OPERANDS[0]}>=${OPERANDS[1]}" | bc -l)
        ;;
    "gt")
        RESULT=$(echo "${OPERANDS[0]}>${OPERANDS[1]}" | bc -l)
        ;;
    "eq")
        RESULT=$(echo "${OPERANDS[0]}==${OPERANDS[1]}" | bc -l)
        ;;
    "or")
        RESULT=$(echo "${OPERANDS[0]}||${OPERANDS[1]}" | bc -l)
        ;;
    "and")
        RESULT=$(echo "${OPERANDS[0]}&&${OPERANDS[1]}" | bc -l)
        ;;
    
    # ternary operators
    "if")
        CONDITION=${OPERANDS[0]}
        if [[ $CONDITION != "0" ]]; then
            RESULT=${OPERANDS[1]}
        else
            RESULT=${OPERANDS[2]}
        fi
        ;;
    esac

    cd ..
    echo "$RESULT"
}


DIRS=$(find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort -n)

for DIR in $DIRS; do
    traverse $DIR
done
