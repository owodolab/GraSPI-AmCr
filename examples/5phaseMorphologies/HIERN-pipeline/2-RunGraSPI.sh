#!/bin/bash

MAINDIR=$PWD

PIXELSIZE=1

GRASPI5Phases=/Users/olgawodo/MINE/PROJECTS/GraSPI/AmCrGraSPI/src/GRASPI5Phases


DATA="$MAINDIR/data"
DISTANCES="$MAINDIR/distances"
DESCS="$MAINDIR/descriptors"
VISMORPH="$MAINDIR/visualMorph"

cd $DATA

f=0;
for i in Morph*MorphoDesc.txt; do
    f=$(($f + 1))
    FILENAME=$i
    BASEFILENAME=`echo ${i} | sed 's/.txt//'` #remove txt-file extension
    echo ""
    echo "analyzing file $FILENAME"
    $GRASPI5Phases -a ${FILENAME} -p 1 -s ${PIXELSIZE} -n 5 > $DESCS/descriptors.$BASEFILENAME.log

    for j in *Distances*.txt; do
        cp $j $DISTANCES/${BASEFILENAME}-${j}
        mv $j $VISMORPH/${BASEFILENAME}-${j}
    done

    cp ${BASEFILENAME}-phiA.txt $VISMORPH/
    cp ${BASEFILENAME}-phiD.txt $VISMORPH/


    cp ${BASEFILENAME}-phiA.txt ../$VISMORPH/
    cp ${BASEFILENAME}-phiB.txt ../$VISMORPH/

    cp $i $VISMORPH/
    for j in *Ids*.txt; do
        mv $j $VISMORPH/${BASEFILENAME}-${j}
    done

done

cd $MAINDIR



