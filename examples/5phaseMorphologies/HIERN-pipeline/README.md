### This is the major folder to process the data from phase field simulations

This folder contains a series of scripts organized into folder that takes as an input `.mat` file (outcome from phase field simulation), and returns a file with all descriptors (`AllDescriptors.txt`). As a part of the pipeline, scripts are provided to visualize the intermediate data, including the script to visualiza the descriptors for initial set of mophologies. The scripts are written to be generic, except of the step 5 that assumes the names of the input files when processing data.

To process the data, the following folders are needed. Script `runPipeline.sh` creates these folders, if you want to execute individual scripts make sure these folders are created beforehead:

- `data`
- `src_data`
- `visualizedData`
- `visualMorph`
- `descriptors`
- `distances`
- `figs`
- `calculateKrec`
- `calculateMobility`

### The pipeline requires few steps:

Given set of files from the phase field simulation in folder `src_data`

#### Step 0: copy data

Script `0-CopyData.sh`:

- copy files you are intersted to analyze from any location to `src_data` (for record, these files will not be modified, and are stored here as a copy) - 
- next copy `*.mat` files folder `data`


#### Step 1: pre-process daya

Script `1-PreprocessData.sh`:

- enter folder data:  `cd data`
- run Matlab using script `PreProcessMorphs.m`
- `MATLAB\R2024b\bin\matlab.exe" -nodisplay -nosplash - nodesktop -r "PreProcessMorphs; exit`

The script converts all `*.mat` files into input files for graspi: `Morph*.txt` 
    and two other files to be used in the next steps: `Morph*-phiA.txt`

#### Step 2: run Graspi

Script `./2-RunGraSPI.sh`
		
	Input: 
		data/*.txt
   	Outout:
   		descriptors/Descriptors.log 
   		visualMorph/IdsETmixed.txt;
   		visualMorph/IdsEETacceptor.txt;
   		visualMorph/IdsEHTdonor.txt; 
   		visualMorph/IdsEET.txt;
   		visualMorph/IdsEHT.txt;
        
 To visualize the data, you need to copy `phiA` and `phiB` files from data folder to visualMorph 
 Then run matlab scipt in visualMorph/visualizeAllMorphs.m
        
#### Step 3: compute recombination descriptors

- copy data 
		cp data/MorphParamSet\*\*MorphoDesc.txt calculateKrec/
		cp visualMorph/\*-Ids\*.txt calculateKrec/
		cp data/MorphParamSet\*\*MorphoDesc-phi*.txt calculateKrec/
- enter folder calculateKrec
- run matlab with script CalculateDesc
- clean the folder (move descKrec-\*.txt to folder ../descriptors
 
#### Step 4: compute mobility descriptors

	!!! see line 27 of script: CalculateDesc.m, for now processes only one morphology
	for fileId = 1:1%length(myFiles)

   
   - copy date before:
            cp data/MorphParamSet\*\*MorphoDesc.txt calculateMobility
            cp visualMorph/\*-Ids\*.txt calculateMobility
            cp data/MorphParamSet\*\*MorphoDesc-phi\*.txt calculateMobility/
   
   - This one takes few hours to run
            run matlab scipt calculateMobility/CalculateDesc.m


#### Step 5: generate figures
	
- collect all descriptors using bash script "5-ExtractDescriptors\.sh". 
- Go to folder visualizeData and run matlab using VisualizeDescriptors.m script. 
	
		It will produce 4 figures with descriptors: ETAdG.png KrG.png MUeG.png and MUhG.png


