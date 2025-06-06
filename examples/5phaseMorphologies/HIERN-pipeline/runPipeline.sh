#!/bin/bash --login

MATLABDIR=/Applications/MATLAB_R2024b.app/bin/matlab

CURRDIR=$PWD

DATA=${CURRDIR}/data
DESC=${CURRDIR}/descriptors

#Step 0
echo "Step 0: copy Data"
./0-copyData.sh

#Step 1
echo "Step 1: preprocess data"
cd $DATA
    $MATLABDIR -nodisplay -nosplash - nodesktop -r "PreProcessMorphs; exit" > logOut.txt 2>&1
cd ..

# visualize Data
echo "Step 1a: visualize morphs"
cd visualMorph
    $MATLABDIR -nodisplay -nosplash - nodesktop -r "VisualizeAllMorphs; exit" > logOut.txt 2>&1
    mv *.png ../figs
cd ..

#Step 2
echo "Step 2: runGraSPI"
./2-RunGraSPI.sh

#Step 3
echo "Step 3: calculate K recombination descriptor"
#copy data first
cp data/MorphParamSet**MorphoDesc.txt calculateKrec/
cp visualMorph/*-Ids*.txt calculateKrec/
cp data/MorphParamSet**MorphoDesc-phi*.txt calculateKrec/
cd calculateKrec
    $MATLABDIR -nodisplay -nosplash - nodesktop -r "CalculateDesc; exit" > logOut.txt 2>&1
    #save results
    mv *-krec.png ../figs/
    mv *-M.png ../figs/
    mv descKrec-*.txt ${DESC}
    #clean up
    rm *-Ids*.txt MorphParamSet**MorphoDesc-phi*.txt MorphParamSet**MorphoDesc.txt
cd ..

#FOR NOW COMMENTED, as it takes a lot of time
#Step 4
#echo "Step 4: calculate mobility descriptor, it takes a lot of time!!! "
#cp data/MorphParamSet**MorphoDesc.txt calculateMobility
#cp visualMorph/*-Ids*.txt calculateMobility
#cp data/MorphParamSet**MorphoDesc-phi*.txt calculateMobility/
#cd calculateMobility
#    $MATLABDIR -nodisplay -nosplash - nodesktop -r "CalculateDesc; exit" > logOut.txt 2>&1
#    mv *Mobilit*.png ../figs/
#    mv descMob-*.txt $DESC
#    mv HdepMob-*.txt $DESC
#    rm *-Ids*.txt MorphParamSet**MorphoDesc-phi*.txt MorphParamSet**MorphoDesc.txt MorphParamSet*-M.png
#cd ..

#Step 5
echo "Step 5: generate report with plots"
./5-ExtractDescriptors.sh
mv AllDescriptors.txt visualizeData
cd visualizeData
    $MATLABDIR -nodisplay -nosplash - nodesktop -r "VisualizeDescriptors; exit" > logOut.txt 2>&1
cd ..

