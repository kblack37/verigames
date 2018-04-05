#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage:"
  echo "generate.sh <checker> <file>"
  exit
fi

checkerarg="-P infChecker=$1"

absfile=`readlink -f $2`

filearg="-P infArgs=\"$absfile\""

gradle infer $checkerarg $filearg
