#!/bin/bash --login

MATLABDIR=/Applications/MATLAB_R2024b.app/bin/matlab

cp AllDescriptors.txt visualizeData
cd visualizeData
    $MATLABDIR -nodisplay -nosplash - nodesktop -r "VisualizeDescriptors; exit" > logOut.txt 2>&1
cd ..

