#!/bin/bash --login

MATLABDIR=/Applications/MATLAB_R2024b.app/bin/matlab

cp data/MorphParamSet**MorphoDesc.txt calculateMobility/
cp visualMorph/*-Ids*.txt calculateMobility/
cp data/MorphParamSet**MorphoDesc-phi*.txt calculateMobility/

cd calculateMobility
    $MATLABDIR -nodisplay -nosplash - nodesktop -r "CalculateDesc; exit" > logOut.txt 2>&1
    mv *Mobilit*.png ../figs/
    mv descMob-*.txt ../descriptors/
    mv HdepMob-*.txt ../descriptors/
    rm *-Ids*.txt MorphParamSet**MorphoDesc-phi*.txt MorphParamSet**MorphoDesc.txt MorphParamSet*-M.png
cd ..

