#!/bin/bash --login

MATLABDIR=/Applications/MATLAB_R2024b.app/bin/matlab

mkdir -p distances
mkdir -p descriptors
mkdir -p figs

echo "Step 0: copy Data"
./0-CopyData.sh
echo "Step 1: preprocess data"
./1-PreprocessData.sh
echo "Step 2: runGraSPI"
./2-RunGraSPI.sh
echo "Step 2a: visualize morphs"
./2a-VisualizeMorphs.sh
echo "Step 3: calculate K recombination descriptor"
./3-CalculateKrecDesc.sh
#FOR NOW COMMENTED, as it takes a lot of time
echo "Step 4: calculate mobility related descriptors"
./4-CalculateMobDesc.sh
echo "Step 5: generate report with plots"
./5-ExtractDescriptors.sh
echo "Step 5a: visualize descriptors data"
./5a-VisualizeDescriptors.sh
