#!/bin/bash --login

MATLABDIR=/Applications/MATLAB_R2024b.app/bin/matlab

cd data
    $MATLABDIR -nodisplay -nosplash - nodesktop -r "PreProcessMorphs; exit" > logOut.txt 2>&1
cd ..

