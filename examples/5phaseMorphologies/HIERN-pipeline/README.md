Analysis pipeline requires few steps:


given set of files from the phase field simulation in folder src\_data

Step 0: copy data

- copy files you are interst to analyze from folder any location to src\_data (for record, these files should not be modified, hence you need to copy them) - script 0-copyData.sh
- next copy all files you are interested in analyzing to folder data


Step 1: pre-process daya

- enter folder data:  cd data
- run Matlab using script PreProcessMorphs.m
- "MATLAB\R2024b\bin\matlab.exe" -nodisplay -nosplash - nodesktop -r "PreProcessMorphs; exit"

The script converts all mat files into input files for graspi: Morph\*.txt 
    and two other files to be used in Step: Morph\*-phiA.txt

Step 2: run Graspi

 ./2-RunGraSPI.sh
       
       Outout:
            descriptors/Descriptors.log 
            visualMorph/IdsETmixed.txt;
            visualMorph/IdsEETacceptor.txt;
            visualMorph/IdsEHTdonor.txt; 
            visualMorph/IdsEET.txt;
            visualMorph/IdsEHT.txt;
        
 To visualize the data, you need to copy phiA and phiB files from data folder to visualMorph 
 Then run matlab scipt in visualMorph/visualizeAllMorphs.m
        
Step 3: compute recombination descriptors

- copy data 
		cp data/MorphParamSet\*\*MorphoDesc.txt calculateKrec/
		cp visualMorph/\*-Ids\*.txt calculateKrec/
		cp data/MorphParamSet\*\*MorphoDesc-phi*.txt calculateKrec/
- enter folder calculateKrec
- run matlab with script CalculateDesc
- clean the folder (move descKrec-\*.txt to folder ../descriptors
 
Step 4: compute mobility descriptors
   
   - copy date before:
            cp data/MorphParamSet\*\*MorphoDesc.txt calculateMobility
            cp visualMorph/\*-Ids\*.txt calculateMobility
            cp data/MorphParamSet\*\*MorphoDesc-phi\*.txt calculateMobility/
   
   - This one takes few hours to run
            run matlab scipt calculateMobility/CalculateDesc.m


Step 5: generate figures
	
- collect all descriptors using bash script "5-ExtractDescriptors\.sh". 
- Go to folder visualizeData and run matlab using VisualizeDescriptors.m script. 
	
		It will produce 4 figures with descriptors: ETAdG.png KrG.png MUeG.png and MUhG.png

