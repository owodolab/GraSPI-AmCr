#!/bin/bash

MAINDIR=$PWD


# paths to GraSPI and external tools used to pre or post process data
GRASPI5Phases=$MAINDIR/../../../../src-v1/GRASPI5Phases

# file to analyze
FILENAME=data_6_6
# run GraSPI analysis
$GRASPI5Phases -a ${FILENAME}.txt -s 1 -n 5 -p 0 > descriptors-${FILENAME}.txt 2>&1
