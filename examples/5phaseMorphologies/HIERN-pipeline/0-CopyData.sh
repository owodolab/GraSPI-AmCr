#!/bin/bash --login
#This scripts copy the data from the folder with multiple tests: here ParamSet
#Only one file is copied: *.mat


CURRFOLDER=$PWD

SRCFOLDER="/Users/olgawodo/MINE/PROJECTS/HIERN-descriptors/12Morphs4Analysis/PostProc_MorphoDescriptors"
TARGETFOLDER=${CURRFOLDER}/src_data

cd $SRCFOLDER

for i in ParamSet*; do
    PARAMSETNAME=$i
    echo "ParamSetName: $PARAMSETNAME"
    cd $PARAMSETNAME
    for j in *.mat; do
         MORPHNAME=$j
#         echo "MorphNane: $MORPHNAME"
#         echo "cp $MORPHNAME $TARGETFOLDER/${PARAMSETNAME}${MORPHNAME}"
         cp $MORPHNAME $TARGETFOLDER/${PARAMSETNAME}${MORPHNAME}
    done
    
    cd ..
done

