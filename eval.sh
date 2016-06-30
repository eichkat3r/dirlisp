#!/bin/sh

# ba_eval.sh
# evaluates a bash arithmetics expression


input_file=

### handle command line arguments ###

while getopts ":i:" opt; do
    case $opt in
    i)
        input_file="$OPTARG"
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

if [[ -z $input_file ]]; then
    input_file="$@"
fi

if [[ -z $input_file ]]; then
    echo "$input_file"
    echo "No input_file specified." >&2
    exit
fi



cd "$input_file"

# evaluate the file tree recursively
function traverse {
    # function takes directory name as argument
    tl_dir="$1"
    cd "$tl_dir"
    # split name into id and operator
    tl_dir_id=$(echo "$tl_dir" | cut -d"_" -f1)
    tl_dir_op=$(echo "$tl_dir" | cut -d"_" -f2)
    
    operands=()
    
    files=$(find . -maxdepth 1 -mindepth 1 -printf '%f\n' | sort -n)
    
    for file in $files; do
        value=
        
        # directories will be evaluated (recursion)
        if [[ -d $file ]]; then
            value=$(traverse "$file")
        # files = leaves in syntax tree
        else
            value=$(cat "$file")
        fi
        
        operands+=("$value")
    done
    
    ### evaluate current directory by folding all values ###
    
    case $tl_dir_op in
    # number of operands >= 2
    "add"|"sub"|"mul"|"div")
        result=${operands[0]}
        
        for OPERAND in ${operands[@]:1}; do
            case $tl_dir_op in
            "add")
                result=$(echo "$result+$OPERAND" | bc -l)
                ;;
            "sub")
                result=$(echo "$result-$OPERAND" | bc -l)
                ;;
            "mul")
                result=$(echo "$result*$OPERAND" | bc -l)
                ;;
            "div")
                result=$(echo "$result/$OPERAND" | bc -l)
                ;;
            esac
        done
        ;;
    
    # unary operators
    "not")
        result=$(echo "!${operands[0]}" | bc -l)
        ;;
    "sqrt")
        result=$(echo "sqrt(${operands[0]})" | bc -l)
        ;;
    "print")
        echo "${operands[0]}" >&2
        ;;
    
    # binary operators
    "lte")
        result=$(echo "${operands[0]}<=${operands[1]}" | bc -l)
        ;;
    "lt")
        result=$(echo "${operands[0]}<${operands[1]}" | bc -l)
        ;;
    "gte")
        result=$(echo "${operands[0]}>=${operands[1]}" | bc -l)
        ;;
    "gt")
        result=$(echo "${operands[0]}>${operands[1]}" | bc -l)
        ;;
    "eq")
        result=$(echo "${operands[0]}==${operands[1]}" | bc -l)
        ;;
    "or")
        result=$(echo "${operands[0]}||${operands[1]}" | bc -l)
        ;;
    "and")
        result=$(echo "${operands[0]}&&${operands[1]}" | bc -l)
        ;;
    
    # ternary operators
    "if")
        condition=${operands[0]}
        if [[ $condition != "0" ]]; then
            result="${operands[1]}"
        else
            result="${operands[2]}"
        fi
        ;;
    
    # lists
    "list")
        result="${operands[@]}"
        ;;
    *)
        ;;
    esac

    cd ..
    echo "$result"
}


dirs=$(find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort -n)

for dir in $dirs; do
    traverse $dir
done
