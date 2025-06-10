#!/bin/bash --login

MATLABDIR=/Applications/MATLAB_R2024b.app/bin/matlab

#copy data first
cp data/MorphParamSet**MorphoDesc.txt calculateKrec/
cp visualMorph/*-Ids*.txt calculateKrec/
cp data/MorphParamSet**MorphoDesc-phi*.txt calculateKrec/
cd calculateKrec
    $MATLABDIR -nodisplay -nosplash - nodesktop -r "CalculateDesc; exit" > logOut.txt 2>&1
    #save results
    mv *-krec.png ../figs/
    mv *-M.png ../figs/
    mv descKrec-*.txt ../descriptors/
    #clean up
    rm *-Ids*.txt MorphParamSet**MorphoDesc-phi*.txt MorphParamSet**MorphoDesc.txt

cd ..
