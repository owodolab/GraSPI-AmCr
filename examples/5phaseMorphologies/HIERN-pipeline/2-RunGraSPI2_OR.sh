#!/bin/bash

MAINDIR=$PWD

PIXELSIZE=1

#GRASPI5Phases=/Users/olgawodo/MINE/PROJECTS/GraSPI/AmCrGraSPI/src/GRASPI5Phases
#GRASPI5Phases=/data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/src/graspi5phases
GRASPI5Phases=$1

#DATA="$MAINDIR/src_data"
#DISTANCES="$MAINDIR/distances"
DESCS="$MAINDIR/descriptors"
#VISMORPH="$MAINDIR/visualMorph2"

cd $DESCS

f=0;
#for i in Morph*sv_1.txt; do
for i in $2; do
    f=$(($f + 1))
    FILENAME=$i
 
    BASEFILENAME=`echo ${i} | sed 's/.txt//'` #remove txt-file extension
    echo ""
    echo "analyzing file $FILENAME"
    #$GRASPI5Phases -a ${FILENAME} -p 1 -s ${PIXELSIZE} -n 5 > $DESCS/descriptors.$BASEFILENAME.log
    #$GRASPI5Phases -a ${FILENAME} -p 1 -s ${PIXELSIZE} -n 5 -ldD 15 -ldA 40 > $DESCS/descriptors.$BASEFILENAME.log
    $GRASPI5Phases -a ${FILENAME} -p 1 -s ${PIXELSIZE} -n 5 -ldD $3 -ldA $4 > $DESCS/descriptors.$BASEFILENAME.log

    #cp ${BASEFILENAME}-phiA.txt $DESCS/
    #cp ${BASEFILENAME}-phiD.txt $DESCS/
    #cp ${BASEFILENAME}.txt $DESCS/

    for j in *Distances*.txt; do
        mv $j $DESCS/${BASEFILENAME}-${j}
        #mv $j $VISMORPH/${BASEFILENAME}-${j}
    done

    #cp ${BASEFILENAME}-phiA.txt $VISMORPH/
    #cp ${BASEFILENAME}-phiD.txt $VISMORPH/


    #cp ${BASEFILENAME}-phiA.txt ../$VISMORPH/
    #cp ${BASEFILENAME}-phiB.txt ../$VISMORPH/

    #cp $i $VISMORPH/
    for j in *Ids*.txt; do
        #mv $j $VISMORPH/${BASEFILENAME}-${j}
        mv $j $DESCS/${BASEFILENAME}-${j}
    done

done

cd $MAINDIR



