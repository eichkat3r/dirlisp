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
    INPUT="$@"
fi

if [[ -z $INPUT ]]; then
    echo "$INPUT"
    echo "No input specified." >&2
    exit
fi

set -f
TOKENS=$(echo $INPUT | grep -o "+\|-\|*\|/\|(\|)\|[0-9]*")
unset -f

rm -rf "$OUTPUT"
mkdir "$OUTPUT"
cd "$OUTPUT"

ID=0

for T in $TOKENS; do
    case $T in
    "+")
        mkdir "${ID}_add"
        cd "${ID}_add"
        (( ID++ ))
        ;;
    "-")
        mkdir "${ID}_sub"
        cd "${ID}_sub"
        (( ID++ ))
        ;;
    "*")
        mkdir "${ID}_mul"
        cd "${ID}_mul"
        (( ID++ ))
        ;;
    "/")
        mkdir "${ID}_div"
        cd "${ID}_div"
        (( ID++ ))
        ;;
    ")")
        cd ..
        ;;
    [0-9]*)
        touch "${ID}_val"
        echo "$T" > "${ID}_val"
        (( ID++ ))
        ;;
    esac
done
