#!/bin/sh

# convert.sh
# converts an arbitrary arithmetic expression to a directory structure

input_file=
output_dir="a.out"
console_mode=false

while getopts ":i:o:c" OPT; do
    case $OPT in
    i)
        input_file="$OPTARG"
        ;;
    o)
        output_dir="$OPTARG"
        ;;
    c)
        # start interactive console
        console_mode=true
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
    input_file=$(cat "$@")
fi

if [[ -z $input_file ]]; then
    echo "No input_file specified." >&2
    exit
fi

set -f
tokens=$(echo $input_file | grep -o "+\|-\|*\|/\|<=\|>=\|<\|>\|(\|)\|[\|]\|#[[:digit:]]*\|[[:digit:]]*\|[[:alpha:]][[:alnum:]]*\|#[[:alnum:]]*\|'[[:alnum:]]*")
unset -f

rm -rf "$output_dir"
mkdir "$output_dir"
cd "$output_dir"

id=0

is_list=false

# create an operator directory
function write_op {
    mkdir "${id}_${1}"
    cd "${id}_${1}"
    (( id++ ))
    is_list=false
}

for T in $tokens; do
    case $T in
    # special char replacement
    "+")
        write_op "add"
        ;;
    "-")
        write_op "sub"
        ;;
    "*")
        write_op "mul"
        ;;
    "/")
        write_op "div"
        ;;
    "<=")
        write_op "lte"
        ;;
    "<")
        write_op "lt"
        ;;
    ">=")
        write_op "gte"
        ;;
    ">")
        write_op "gt"
        ;;
    "("|"[")
        is_list=true
        ;;
    ")"|"]")
        cd ..
        ;;
    [[:alpha:]][[:alnum:]]*)
        write_op "$T"
        ;;
    # symbols
    [[:digit:]]*|\'[[:alnum:]]*)
        if [[ $is_list == true ]]; then
            mkdir "${id}_is_list"
            cd "${id}_is_list"
            (( id++ ))
            is_list=false
        fi
        touch "${id}_sym"
        echo "$T" > "${id}_sym"
        (( id++ ))
        ;;
    # pointers
    \#[[:alnum:]]*)
        ;;
    [[:space:]])
        ;;
    *)
        echo "Unknown symbol $T"
        ;;
    esac
done
