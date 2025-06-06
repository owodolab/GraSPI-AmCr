#!/bin/bash

MAINDIR=$PWD

PIXELSIZE=1

GRASPI5Phases=/Users/olgawodo/MINE/PROJECTS/GraSPI/AmCrGraSPI/src/GRASPI5Phases


DATA="$MAINDIR/data"
DISTANCES="$MAINDIR/distances"
FIGS="$MAINDIR/figs"
HISTO="$MAINDIR/histograms"
DESCS="$MAINDIR/descriptors"
VISDEBUG="$MAINDIR/visualMorph"
STATS="$MAINDIR/stats"
SRCDATA="$MAINDIR/src_data"

cd $DATA

f=0;
for i in Morph*MorphoDesc.txt; do
    f=$(($f + 1))
    FILENAME=$i
    BASEFILENAME=`echo ${i} | sed 's/.txt//'` #remove txt-file extension
    echo ""
    echo "analyzing file $FILENAME"
    $GRASPI5Phases -a ${FILENAME} -p 1 -s 1 -n 5 > $DESCS/descriptors.$BASEFILENAME.log

    for j in *Distances*.txt; do
        cp $j $DISTANCES/${BASEFILENAME}-${j}
        mv $j $VISDEBUG/${BASEFILENAME}-${j}
    done

    cp $i $VISDEBUG/
    for j in *Ids*.txt; do
        mv $j $VISDEBUG/${BASEFILENAME}-${j}
    done

done

cd $MAINDIR



