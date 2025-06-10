#!/bin/bash --login

MATLABDIR=/Applications/MATLAB_R2024b.app/bin/matlab

cd visualMorph
    $MATLABDIR -nodisplay -nosplash - nodesktop -r "VisualizeAllMorphs; exit" > logOut.txt 2>&1
    mv *.png ../figs
cd ..

