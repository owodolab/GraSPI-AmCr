function [ ElecDescriptorValues, ElecDescriptorNames ] = Struct2Prop_ElecMorphoDescr_Synth( NameWorkflowSave, NameMorpho )

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the data from the file written by Olga's Graspi routine 5-ExtractDescriptors2.sh
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File ResultsSaveFile with location/Name: [NameFolderGraspi 'visualizeData/Descriptors' NameFileSave '_' num2str(numworkflow) '.txt']
% THIS IS THE IMPORTANT FILE WE USE THE DATA FROM IN THE DD1D SIMULATIONS!!!
% This contains the four electronic descriptors for several morphologies

% Descriptor Names
ElecDescriptorNames = {'Ntot','Neetpehtp','Neetp','Nehtp','Ncetp','Ncetpmix','Ncetpd','Ncetpa','DissoPa','DissoPb','DissoPc','EtadmReconstr','Muem','Muhm','krecm','krecTrapem','krecTraphm','krecTrapehm','n_M_eff // Ncetpmixed','DissoPbOlga','DissoPcOlga','EtadmOlga'};

% Load the traps values from the .mat file (on long term, we should extract everything from the .mat file...
Nmorpho = numel(NameMorpho);
Nvalues = numel(ElecDescriptorNames); % Number of results per morphology
ElecDescriptorValues = zeros(Nmorpho,Nvalues);

for hhh = 1:Nmorpho
	load([NameWorkflowSave NameMorpho{hhh} '_MorphoElecAnalysis.mat'])
	ElecDescriptorValues(hhh,1) = MorphoElecAnalysis.PhaseType.Ntot;
	ElecDescriptorValues(hhh,2) = MorphoElecAnalysis.PhaseType.Neetpehtp;
	ElecDescriptorValues(hhh,3) = MorphoElecAnalysis.PhaseType.Neetp;
	ElecDescriptorValues(hhh,4) = MorphoElecAnalysis.PhaseType.Nehtp;
	ElecDescriptorValues(hhh,5) = MorphoElecAnalysis.PhaseType.Ncetp;
	
	ElecDescriptorValues(hhh,6) = MorphoElecAnalysis.PhaseType.Ncetpmix;
	ElecDescriptorValues(hhh,7) = MorphoElecAnalysis.PhaseType.Ncetpd;
	ElecDescriptorValues(hhh,8) = MorphoElecAnalysis.PhaseType.Ncetpa;

	ElecDescriptorValues(hhh,9) = MorphoElecAnalysis.Dissociation.DissoPa;
	ElecDescriptorValues(hhh,10) = MorphoElecAnalysis.Dissociation.DissoPb;
	ElecDescriptorValues(hhh,11) = MorphoElecAnalysis.Dissociation.DissoPc;
	ElecDescriptorValues(hhh,12) = MorphoElecAnalysis.Dissociation.Etadm;
	ElecDescriptorValues(hhh,13) = MorphoElecAnalysis.Mobilities.Muem;
	ElecDescriptorValues(hhh,14) = MorphoElecAnalysis.Mobilities.Muhm;
	ElecDescriptorValues(hhh,15) = MorphoElecAnalysis.Recombination.krecm;
	ElecDescriptorValues(hhh,16) = MorphoElecAnalysis.Recombination.krecTrapem;
	ElecDescriptorValues(hhh,17) = MorphoElecAnalysis.Recombination.krecTraphm;
	ElecDescriptorValues(hhh,18) = MorphoElecAnalysis.Recombination.krecTrapehm;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug: just to check that Etad reconstructed from the fields and calculated from Graspi output file are consistent...
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for hhh = 1:Nmorpho
	ResultsSaveFile = [NameWorkflowSave 'DataGraspi/descriptors.' NameMorpho{hhh} '.log']; 
	fid = fopen(ResultsSaveFile,'r');
	[A,count] = textscan(fid, ['%s' '%f'], 'delimiter',':');
	fclose(fid);
	Values = A{2};
	n_M_eff = Values(1);
	e_A_eff = Values(2);
	e_D_eff = Values(3);
	Pb = Values(4);
	Pc = Values(5);
	Nb = Values(6);
	Nc = Values(7);
	n = Values(8);
	ElecDescriptorValues(hhh,19) = n_M_eff;
	ElecDescriptorValues(hhh,20) = Pb;
	ElecDescriptorValues(hhh,21) = Pc;
	ElecDescriptorValues(hhh,22) = (n_M_eff+Pb+Pc)/n;
end

end
