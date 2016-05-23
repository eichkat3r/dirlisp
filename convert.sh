#!/bin/sh

# convert.sh
# converts an arbitrary arithmetic expression to a directory structure

INPUT=
OUTPUT="a.out"

while getopts ":i:o:" OPT; do
    case $OPT in
    i)
        INPUT="$OPTARG"
        ;;
    o)
        OUTPUT="$OPTARG"
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
    INPUT=$(cat "$@")
fi

if [[ -z $INPUT ]]; then
    echo "No input specified." >&2
    exit
fi

set -f
TOKENS=$(echo $INPUT | grep -o "+\|-\|*\|/\|<=\|>=\|<\|>\|(\|)\|[[:digit:]]*\|[[:alpha:]][[:alnum:]]*")
unset -f

rm -rf "$OUTPUT"
mkdir "$OUTPUT"
cd "$OUTPUT"

ID=0

LIST=false

# create an operator directory
function write_op {
    mkdir "${ID}_${1}"
    cd "${ID}_${1}"
    (( ID++ ))
    LIST=false
}

for T in $TOKENS; do
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
    "(")
        LIST=true
        ;;
    ")")
        cd ..
        ;;
    [[:alpha:]][[:alnum:]]*)
        write_op "$T"
        ;;
    # symbols
    [[:digit:]]*|\'[[:alnum:]]*)
        if [[ $LIST == true ]]; then
            mkdir "${ID}_list"
            cd "${ID}_list"
            (( ID++ ))
            LIST=false
        fi
        touch "${ID}_sym"
        echo "$T" > "${ID}_sym"
        (( ID++ ))
        ;;
    [[:space:]])
        ;;
    *)
        echo "Unknown symbol $T"
        ;;
    esac
done
