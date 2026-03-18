function [ MorphoElecAnalysis ] = Struct2Prop_ElecMorphoDescr_TP_disso_mu_krec( inputFile, NameFolderDataGraspi, PostParam )


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Help about the meaning of the variables below 
% Correspondance with Graspi's output, historical notations and notation in the paper
% This has been carefully crossed-checked!
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% The files:
% ---------------------------------------------
%
% ...IdsETMixed.txt: the list of nodes in the CETP, mixed phase part (/!\ the mixed phase ONLY)
% ...IdsEHTdonor.txt, /!\ THERE IS AN INVERSION: the list of nodes in the CETP, acceptor phase part at the interfaces between pure donor and acceptor regions
% ...IdsEETacceptor.txt, /!\ THERE IS AN INVERSION: the list of nodes in the CETP, donor phase part at the interfaces between pure donor and acceptor regions
% ...DistancesBlackOrangeGreyToGREEN.txt: the distances to the CETP for the nodes of the EHTP that do not belong to the mixed phase of the CETP
% ...DistancesWhiteYellowGreyToGREEN.txt: the distances to the CETP for the nodes of the EETP that do not belong to the mixed phase of the CETP
%
% ---------------------------------------------
% The number of nodes:
% ---------------------------------------------
%
% Ncetpmix (Olga's nMeff, what we historically called '3a' nodes): number of nodes in the CETP, mixed phase part (/!\ the mixed phase ONLY)
% Ncetpa (Olga's e_D_eff /!\ THERE IS AN INVERSION, what we historically called '3b' nodes): number of nodes in the CETP, acceptor phase part at the interfaces between pure donor and acceptor regions 
% Ncetpd (Olga's e_A_eff /!\ THERE IS AN INVERSION, what we historically called '3c' nodes): number of nodes in the CETP, donor phase part at the interfaces between pure donor and acceptor regions
% Nb: number of nodes that are in the EETP but not in the mixed phase part of the CETP (corresponding to Pb); NB: this contains 3b
% Nc: number of nodes that are in the EHTP but not in the mixed phase part of the CETP (corresponding to Pc); NB: this contains 3c
%
% Ncetp = Ncetpmix + Ncetpd + Ncetpa: number of nodes of the CETP
% Neetp = Nb + Ncetpmix: number of nodes of the EETP
% Nehtp = Nc + Ncetpmix: number of nodes of the EHTP
%
% Neetpehtp = Neetp + Nehtp - Ncetpmix = Nb + Nc + Ncetpmix: number of nodes of both effective transport phases together
%
% DissoPa: sum(exp(-Dist/L))=sum(1) over the nodes of the EETP that are in the mixed phase of the CETP; (nearly, except interface management) our 'Pa' of the paper
% DissoPb: sum(exp(-Dist/L)) over the nodes of the EETP that are not in the mixed phase of in the CETP; (nearly, except interface management) our 'Pb' of the paper
% DissoPc: sum(exp(-Dist/L)) over the nodes of the EHTP that are not in the mixed phase of in the CETP; (nearly, except interface management) our 'Pc' of the paper
%
% ---------------------------------------------
% The other way around, correspondance with Graspi's output of average values:
% ---------------------------------------------
%
% nMeff: Ncetpmix
% e_A_eff, /!\ THERE IS AN INVERSION: Ncetpd 
% e_D_eff,/!\ THERE IS AN INVERSION: Ncetpa
% Pb: sum(exp(-Dist/L)) over the nodes of the EETP that are not in the mixed phase of in the CETP; (nearly, except interface management) our 'Pb' of the paper, 'DissoPb' in the code
% Pc: sum(exp(-Dist/L)) over the nodes of the EHTP that are not in the mixed phase of in the CETP; (nearly, except interface management) our 'Pc' of the paper, 'DissoPc' in the code
% Nb: number of nodes in the EETP that are not in the CETP
% Nc: number of nodes in the EHTP that are not in the CETP
% n: total number of nodes
% 
% The average dissociation efficiency is calculated by Olga as: (nMeff+Pb+Pc)/n

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data and define filenames
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Names of the files (Graspi output) with the data we need

filename = inputFile;
filenameWOext = extractBefore(filename, ".");

% Files with the volume fractions
filenamePhiA=[filenameWOext '-phiA.txt']; % Acceptor volume fraction
filenamePhiD=[filenameWOext '-phiD.txt']; % Donor volume fraction

% Files with the nodes of the EETP and EHTP
filenameDescEHT=[filenameWOext '-IdsEHT.txt']; % EHTP
filenameDescEET=[filenameWOext '-IdsEET.txt']; % EETP

% TO BE CHECKED IN DETAIL BUT...
% THE CONFIGURATION OF FILES BELOW ALLOW TO RECOVER OLGA'S EXCITON DISSOCIATION EFFICIENCY VALUES
% SO THERE'S AN INVERSION OF FILE NAMES...

% Files with the nodes of the CETP; I think the files names are mixed up here!!!
filenameDescETmixed=[filenameWOext  '-IdsETmixed.txt']; % This is equivalent to region '3a'
% filenameDescEETacceptor=[filenameWOext  '-IdsEETacceptor.txt']; % This is equivalent to region '3b'; with this, we are wrong!!
% filenameDescEHTdonor=[filenameWOext '-IdsEHTdonor.txt']; % This is equivalent to region '3c'; with this, we are wrong!!
filenameDescEHTdonor=[filenameWOext  '-IdsEETacceptor.txt']; % This is equivalent to region '3c'
filenameDescEETacceptor=[filenameWOext '-IdsEHTdonor.txt']; % This is equivalent to region '3b'

% Files with the distances to CETP
filenameDistHole=[filenameWOext '-DistancesBlackOrangeGreyToGREEN.txt'];
filenameDistElec=[filenameWOext '-DistancesWhiteYellowGreyToGREEN.txt'];

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matrices with raw morphology and functional phases
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Raw morphology data
% ---------------------------------------------

phiAMorph = importdata([NameFolderDataGraspi filenamePhiA ]);
phiDMorph = importdata([NameFolderDataGraspi filenamePhiD ]);

Morph =  readmatrix([NameFolderDataGraspi filename],'NumHeaderLines',1);
sizeMorph = size(Morph);
Ntot = numel(Morph);
IndMixed = find(Morph==3);
IndDam = find(Morph==0);
IndDcr = find(Morph==5);
IndAam = find(Morph==1);
IndAcr = find(Morph==7);
ND = numel(union(IndDam,IndDcr));
NA = numel(union(IndAam,IndAcr));

% ---------------------------------------------
% Matrix initialization
% ---------------------------------------------

MorphDesc3=zeros(sizeMorph);
MorphEET=zeros(sizeMorph);
MorphEHT=zeros(sizeMorph);
MorphDistHole=zeros(sizeMorph);
MorphDistElec=zeros(sizeMorph);
DistHole = nan*zeros(sizeMorph);
DistElec = nan*zeros(sizeMorph);

% % ---------------------------------------------
% % The EETP and EHTP
% % ---------------------------------------------
% % NO!!! actually this contains nodes that are not in the ETP
% % e.g. domains that are in contact with the proper electrode, but fully surrounded by lost domain of the other TP 
% % (a region of the other TP which is not 'effective')
% 
% % This is the effective electron transport phase
% EET = importdata([NameFolderDataGraspi filenameDescEET]);
% EET = unique(EET,'rows'); % because I think there's a mistake in Olga's file
% if ~isempty(EET)
% 	ind = sub2ind(sizeMorph,EET(:,2)+1,EET(:,1)+1);
% 	MorphEET(ind) = 1;
% end
% IndEET=find(MorphEET==1);
% IndnotEET = find(MorphEET~=1);
% 
% % This is the effective hole transport phase
% EHT=importdata([NameFolderDataGraspi filenameDescEHT]);
% EHT = unique(EHT,'rows'); % because I think there's a mistake in Olga's file
% if ~isempty(EHT)
% 	ind = sub2ind(sizeMorph,EHT(:,2)+1,EHT(:,1)+1);
% 	MorphEHT(ind) = 1;
% end
% IndEHT=find(MorphEHT==1);
% IndnotEHT = find(MorphEHT~=1);
% 
% Neetp = numel(IndEET);
% Nehtp = numel(IndEHT);
% Neetpehtp = numel(union(IndEET,IndEHT));

% ---------------------------------------------
% The CETP
% ---------------------------------------------

% This is the mixed part of the CETP
DETmixed=importdata([NameFolderDataGraspi filenameDescETmixed]);
if ~isempty(DETmixed)
	ind = sub2ind(sizeMorph,DETmixed(:,2)+1,DETmixed(:,1)+1);
	MorphDesc3(ind) = 2;
end
IndCETPMixed = find(MorphDesc3==2); % finds the nodes in the Common region to effective transport phases (CRETP)
IndMixedNotCETP = setdiff(IndMixed,IndCETPMixed);

% This is the pure acceptor phase part of the CETP
DEETacceptor=importdata([NameFolderDataGraspi filenameDescEETacceptor]);
if ~isempty(DEETacceptor)
	ind = sub2ind(sizeMorph,DEETacceptor(:,2)+1,DEETacceptor(:,1)+1);
	MorphDesc3(ind) = 1;
end
IndCETPAcc = find(MorphDesc3==1); % finds the nodes in the Common region to effective transport phases (CETP)

% This is the pure donor phase part of the CETP
DEHTdonor=importdata([NameFolderDataGraspi filenameDescEHTdonor]);
if ~isempty(DEHTdonor)
	ind = sub2ind(sizeMorph,DEHTdonor(:,2)+1,DEHTdonor(:,1)+1);
	MorphDesc3(ind) = 3;
end
IndCETPDon = find(MorphDesc3==3); % finds the nodes in the Common region to effective transport phases (CETP)

IndCETP = find(MorphDesc3~=0); % finds the nodes in the Common region to effective transport phases (CETP)
Ncetp = numel(IndCETP);
Ncetpmix = numel(IndCETPMixed); % 'n_M_eff', 3a
Ncetpa = numel(IndCETPAcc); % 'e_A_eff', 3b
Ncetpd = numel(IndCETPDon); % 'e_D_eff', 3c
Nmixnotcetp = numel(IndMixedNotCETP);

% ---------------------------------------------
% Distances to EETP and EHTP for electrons and holes
% ---------------------------------------------

DistEET=importdata([NameFolderDataGraspi filenameDistElec]);
if ~isempty(DistEET)
	ind = sub2ind(sizeMorph,DistEET(:,2)+1,DistEET(:,1)+1);
	DistElec(ind) = DistEET(:,3);
end
Indb = find(isnan(DistElec)==0);
Nb = numel(Indb);

DistEHT=importdata([NameFolderDataGraspi filenameDistHole]);
if ~isempty(DistEHT)
	ind = sub2ind(sizeMorph,DistEHT(:,2)+1,DistEHT(:,1)+1);
	DistHole(ind) = DistEHT(:,3);
end
Indc = find(isnan(DistHole)==0);
Nc = numel(Indc);

% ---------------------------------------------
% Now, we can reconstruct the EETP and EHTP
% ---------------------------------------------

% This is the effective electron transport phase
MorphEET(Indb) = 1; % the nodes that are in the EETP but not in the mixed phase part of the CETP (corresponding to Pb, Nb); NB: this contains 3b
MorphEET(IndCETPMixed) = 2; % The nodes 3a
MorphEET(IndCETPAcc) = 3; % The nodes '3b'; should be in Indb already, but to be on the safe side...
IndEET=find(MorphEET~=0);
IndnotEET = find(MorphEET==0);

% This is the effective hole transport phase
MorphEHT(Indc) = 1; % the nodes that are in the EHTP but not in the mixed phase part of the CETP (corresponding to Pc, Nc); NB: this contains 3c
MorphEHT(IndCETPMixed) = 2; % The nodes 3a
MorphEHT(IndCETPDon) = 3; % The nodes '3c'; should be in Indc already, but to be on the safe side...
IndEHT=find(MorphEHT~=0);
IndnotEHT = find(MorphEHT==0);

Neetp = numel(IndEET);
Nehtp = numel(IndEHT);
Neetpehtp = numel(union(IndEET,IndEHT));

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exciton dissociation
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Exciton diffusion efficiency field
% ---------------------------------------------

DissoEfficiency = zeros(sizeMorph);

% NB: this is 1D... discrepancy with 2D/3D MC or DD results because of lacking integration over solid angle
% So, we overestimate Etad...
DissoEfficiency(IndEHT) = exp(-DistHole(IndEHT)/PostParam.Elec.Ld(1));
DissoEfficiency(IndEET) = exp(-DistElec(IndEET)/PostParam.Elec.Ld(2));
DissoEfficiency(IndCETPMixed) = 1; % Necessary!! DistHole, DistElec are nans @ IndCETPMixed

% % A 'random walk' version (but not consistent with the fact that people measure Ld by fitting a diffusion equation)
% PostParam.Elec.Ld = PostParam.Elec.Ld/sqrt(6);
% Etad = @(r,L)  1 - ( erf(r/2/L)-r/(sqrt(pi)*L).*exp(-(r./(2*L)).^2) );
% DissoEfficiency(IndEHT) = Etad(DistHole(IndEHT),PostParam.Elec.Ld(1));
% DissoEfficiency(IndEET) = Etad(DistElec(IndEET),PostParam.Elec.Ld(2));

% IndAcceptornoETP = find(((Morph == 1 ) | (Morph == 7 )) & (MorphEET==0)); %finds acceptor phase outside EETP (Electron effective transport phase)
% IndDonornoETP = find(((Morph == 0 ) | (Morph == 5 ) ) & (MorphEHT==0));  %finds donor phase outside EHTP (Hole  effective transport phase)
% IndmixednoETP = find(((Morph == 3 ) | (MorphEET == 0 ) ) & (MorphEHT==0)); % finds mixed phase outside both effective transport phases (EHTP and EETP)

% DissoEfficiency(IndAcceptornoETP) = 0;
% DissoEfficiency(IndDonornoETP) = 0;
% DissoEfficiency(IndmixednoETP) = 0;

% ---------------------------------------------
% Exciton diffusion efficiency, average values
% ---------------------------------------------

Etadm = mean(mean(DissoEfficiency));

DissoPa = sum(DissoEfficiency(IndCETPMixed));
IndEHTPnoCETP = setdiff(IndEHT,IndCETPMixed);
DissoPc = sum(DissoEfficiency(IndEHTPnoCETP));
IndEETPnoCETP = setdiff(IndEET,IndCETPMixed);
DissoPb = sum(DissoEfficiency(IndEETPnoCETP));
% IndEHTPnoCETP = setdiff(Indc,IndCETPMixed);
% DissoPc = sum(DissoEfficiency(IndEHTPnoCETP));
% IndEETPnoCETP = setdiff(Indb,IndCETPMixed);
% DissoPb = sum(DissoEfficiency(IndEETPnoCETP));

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Recombination
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Matrix initialization
% ---------------------------------------------

CalcKrecFinal = zeros(sizeMorph);
CalcKrecTrape = zeros(sizeMorph);
CalcKrecTraph = zeros(sizeMorph);

% ---------------------------------------------
% Calculation: bimolecular recombination prefactor
% ---------------------------------------------

% IndET = find(MorphDesc3~=0); % finds the nodes in the effective transport phases (EETP or EHTP)
% CalcKrecFinal(IndET) = 4*phiAMorph(IndET).*phiDMorph(IndET);
CalcKrecFinal(IndCETP) = 4*phiAMorph(IndCETP).*phiDMorph(IndCETP);
krecm = sum(sum(CalcKrecFinal))/Neetpehtp;

% Associated fields for plots
krecDescPlot=-1*ones(size(CalcKrecFinal));
krecDescPlot(IndEHT)=CalcKrecFinal(IndEHT);
krecDescPlot(IndEET)=CalcKrecFinal(IndEET);

% ---------------------------------------------
% Calculation: trap recombination prefactors
% ---------------------------------------------

CalcKrecTrape(IndEET) = (1-phiAMorph(IndEET));
krecTrapem = sum(sum(CalcKrecTrape(IndEET)))/Neetp;
CalcKrecTraph(IndEHT) = (1-phiDMorph(IndEHT));
krecTraphm = sum(sum(CalcKrecTraph(IndEHT)))/Nehtp;
krecTrapehm = (Neetp*krecTrapem + Nehtp*krecTraphm)/(Neetp+Nehtp);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Electrons and holes mobilities
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matrix initialization
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MobEET=zeros(sizeMorph);
MobEHT=zeros(sizeMorph);

whphi2_EHT = zeros(size(Morph));
whphi2_EET = zeros(size(Morph));

HdepMobEHT=zeros(sizeMorph(1),1);
HdepMobEET=zeros(sizeMorph(1),1);
HEffdepMobEHT=zeros(sizeMorph(1),1);
HEffdepMobEET=zeros(sizeMorph(1),1);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation of w_h*phi^2 at each point
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% The following allows for calculation of mobilities in 'Single materials' layer 
% (more precisely: 'Single transport phase' layer, either donor transport phase or acceptor transport phase)
% ---------------------------------------------

if ( NA==Ntot )
	IndEET = (1:Ntot)';
	IndnotEET = [];	
	MorphEET(:,:) = 1;
elseif ( ND==Ntot )
	IndEHT = (1:Ntot)';
	IndnotEHT = [];
	MorphEHT(:,:) = 1;
end
	
% ---------------------------------------------
% For hole mobilities in the EHTP, calculate w_h*phiD^2
% ---------------------------------------------

% Fill with mobility values of crystalline/amorphous donor
whphi2_EHT(IndMixed) = PostParam.Elec.Weights(1);
whphi2_EHT(IndDam) = PostParam.Elec.Weights(1);
whphi2_EHT(IndDcr) = PostParam.Elec.Weights(3);
% Multiply by phi^2
whphi2_EHT = whphi2_EHT.*phiDMorph.^2;
% Set to zero outside EHT
whphi2_EHT(IndnotEHT) = 0;

% ---------------------------------------------
% For electron mobilities in the EETP, calculate w_h*phiA^2
% ---------------------------------------------

% Fill with wh
whphi2_EET(IndMixed) = PostParam.Elec.Weights(2);
whphi2_EET(IndAam) = PostParam.Elec.Weights(2);
whphi2_EET(IndAcr) = PostParam.Elec.Weights(3);
% Multiply by phi^2
whphi2_EET = whphi2_EET.*phiAMorph.^2;
% Set to zero outside EET
whphi2_EET(IndnotEET) = 0;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation of highest mobilities depending on the hopping direction
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For those who wonder: the consistency of charge transport direction and circshift signs has been checked and rechecked

% Crystallinity indicator
IndicCr_EHT = zeros(size(Morph));
IndicCr_EET = zeros(size(Morph));
IndicCr_EHT(IndDcr) = 1;
IndicCr_EET(IndAcr) = 1;

% ---------------------------------------------
% Local hole mobilities in the EHTP
% ---------------------------------------------
% Calculate mobility for direct neighbour, holes, transport in direction of increasing row subscripts
% Hole collecting electrode (anode) is at the highest row, row=nzmax+1
% On images, the anode is at the top, though

% Direct neighbour: circshift along dim 1, negative shift
whphi2_EHT_Neighb1 = circshift(whphi2_EHT,-1,1);
IndicCr_EHT_Neighb1 = circshift(IndicCr_EHT,-1,1);

% Now mobility for neighbour left
whphi2_EHT_Neighb2 = circshift(whphi2_EHT_Neighb1,1,2)*cos(-pi/4);
IndicCr_EHT_Neighb2 = circshift(IndicCr_EHT_Neighb1,1,2);
PhaseSwitch = IndicCr_EHT_Neighb2-IndicCr_EHT;
IndPhaseSwitch_A2C = find(IndicCr_EHT_Neighb2-IndicCr_EHT==1);
whphi2_EHT_Neighb2(IndPhaseSwitch_A2C) = PostParam.Elec.kpenA2C_D*whphi2_EHT_Neighb2(IndPhaseSwitch_A2C);
IndPhaseSwitch_C2A = find(IndicCr_EHT_Neighb2-IndicCr_EHT==-1);
whphi2_EHT_Neighb2(IndPhaseSwitch_C2A) = PostParam.Elec.kpenC2A_D*whphi2_EHT_Neighb2(IndPhaseSwitch_C2A);

% Now mobility for neighbour right
whphi2_EHT_Neighb3 = circshift(whphi2_EHT_Neighb1,-1,2)*cos(pi/4);
IndicCr_EHT_Neighb3 = circshift(IndicCr_EHT_Neighb1,-1,2);
PhaseSwitch = IndicCr_EHT_Neighb3-IndicCr_EHT;
IndPhaseSwitch_A2C = find(IndicCr_EHT_Neighb3-IndicCr_EHT==1);
whphi2_EHT_Neighb3(IndPhaseSwitch_A2C) = PostParam.Elec.kpenA2C_D*whphi2_EHT_Neighb3(IndPhaseSwitch_A2C);
IndPhaseSwitch_C2A = find(IndicCr_EHT_Neighb3-IndicCr_EHT==-1);
whphi2_EHT_Neighb3(IndPhaseSwitch_C2A) = PostParam.Elec.kpenC2A_D*whphi2_EHT_Neighb3(IndPhaseSwitch_C2A);

% Penalty on mobility along dim 1 do not move this line elsewhere !!
% Olivier: WHY THE HELL?
% This line is useless: PhaseSwitch = IndicCr_EHT_Neighb1-IndicCr_EHT;
% Olivier: I think both lines below could go up
IndPhaseSwitch_A2C = find(IndicCr_EHT_Neighb1-IndicCr_EHT==1);
whphi2_EHT_Neighb1(IndPhaseSwitch_A2C) = PostParam.Elec.kpenA2C_D*whphi2_EHT_Neighb1(IndPhaseSwitch_A2C);
IndPhaseSwitch_C2A = find(IndicCr_EHT_Neighb1-IndicCr_EHT==-1);
whphi2_EHT_Neighb1(IndPhaseSwitch_C2A) = PostParam.Elec.kpenC2A_D*whphi2_EHT_Neighb1(IndPhaseSwitch_C2A);

% Take the max
whphi2_EHT_AllNeighb = max(whphi2_EHT_Neighb1,whphi2_EHT_Neighb2);
whphi2_EHT_AllNeighb = max(whphi2_EHT_AllNeighb,whphi2_EHT_Neighb3);
% Remove last line
whphi2_EHT_AllNeighb(sizeMorph(1),:) = 0;
% Fill only in EHT
MobEHT(IndEHT) = whphi2_EHT_AllNeighb(IndEHT);

% ---------------------------------------------
% Local electron mobilities in the EETP
% ---------------------------------------------
% Calculate mobility for direct neighbour, electrons, transport in direction of decreasing row subscripts
% Electron collecting electrode (cathode) is at the lowest row, row=1
% On images, the cathode is at the bottom, though

% then circshift along dim 1, positive shift
whphi2_EET_Neighb1 = circshift(whphi2_EET,1,1);
IndicCr_EET_Neighb1 = circshift(IndicCr_EET,1,1);

% Now mobility for neighbour left
whphi2_EET_Neighb2 = circshift(whphi2_EET_Neighb1,1,2)*cos(-pi/4);
IndicCr_EET_Neighb2 = circshift(IndicCr_EET_Neighb1,1,1);
PhaseSwitch = IndicCr_EET_Neighb2-IndicCr_EET;
IndPhaseSwitch_A2C = find(IndicCr_EET_Neighb2-IndicCr_EET==1);
whphi2_EET_Neighb2(IndPhaseSwitch_A2C) = PostParam.Elec.kpenA2C_A*whphi2_EET_Neighb2(IndPhaseSwitch_A2C);
IndPhaseSwitch_C2A = find(IndicCr_EET_Neighb2-IndicCr_EET==-1);
whphi2_EET_Neighb2(IndPhaseSwitch_C2A) = PostParam.Elec.kpenC2A_A*whphi2_EET_Neighb2(IndPhaseSwitch_C2A);

% Now mobility for neighbour right
whphi2_EET_Neighb3 = circshift(whphi2_EET_Neighb1,-1,2)*cos(pi/4);
IndicCr_EET_Neighb3 = circshift(IndicCr_EET_Neighb1,1,1);
PhaseSwitch = IndicCr_EET_Neighb3-IndicCr_EET;
IndPhaseSwitch_A2C = find(IndicCr_EET_Neighb3-IndicCr_EET==1);
whphi2_EET_Neighb3(IndPhaseSwitch_A2C) = PostParam.Elec.kpenA2C_A*whphi2_EET_Neighb3(IndPhaseSwitch_A2C);
IndPhaseSwitch_C2A = find(IndicCr_EET_Neighb3-IndicCr_EET==-1);
whphi2_EET_Neighb3(IndPhaseSwitch_C2A) = PostParam.Elec.kpenC2A_A*whphi2_EET_Neighb3(IndPhaseSwitch_C2A);

%penalty on mobility along dim 1 do not move this line elsewhere !!
PhaseSwitch = IndicCr_EET_Neighb1-IndicCr_EET;
IndPhaseSwitch_A2C = find(IndicCr_EET_Neighb1-IndicCr_EET==1);
whphi2_EET_Neighb1(IndPhaseSwitch_A2C) = PostParam.Elec.kpenA2C_A*whphi2_EET_Neighb1(IndPhaseSwitch_A2C);
IndPhaseSwitch_C2A = find(IndicCr_EET_Neighb1-IndicCr_EET==-1);
whphi2_EET_Neighb1(IndPhaseSwitch_C2A) = PostParam.Elec.kpenC2A_A*whphi2_EET_Neighb1(IndPhaseSwitch_C2A);

% Take the max
whphi2_EET_AllNeighb = max(whphi2_EET_Neighb1,whphi2_EET_Neighb2);
whphi2_EET_AllNeighb = max(whphi2_EET_AllNeighb,whphi2_EET_Neighb3);
% Remove first line
whphi2_EET_AllNeighb(1,:) = 0;
% Fill only in EET
MobEET(IndEET) = whphi2_EET_AllNeighb(IndEET);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Averaging
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Only mode 1 should be used...

% Indices within ETP and with zero mobilities, in the whole morphology node list : set mobility to a minimal value (to avoid inf in the averaging)
toto = MobEET(2:end,:);
Ind2 = find(MorphEET(2:end,:)~=0 & toto==0);
toto(Ind2) = PostParam.Elec.MobilityAveragingMode;
MobEET(2:end,:) = toto;

% Indices within ETP and with zero mobilities, in the whole morphology node list 
toto = MobEHT(1:end-1,:);
Ind2 = find(MorphEHT(1:end-1,:)~=0 & toto==0);
toto(Ind2) = PostParam.Elec.MobilityAveragingMode;
MobEHT(1:end-1,:) = toto;

% Average
[ Muem ] = Struct2Prop_ElecMorphoDescr_muavg( MobEET(2:end,:), find(MorphEET(2:end,:)~=0), PostParam.Elec.MobilityMinValue, PostParam.Elec.MobilityAveragingMode);
[ Muhm ] = Struct2Prop_ElecMorphoDescr_muavg( MobEHT(1:end-1,:), find(MorphEHT(1:end-1,:)~=0), PostParam.Elec.MobilityMinValue, PostParam.Elec.MobilityAveragingMode);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save the global descriptor values in files
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filenameDesc=sprintf('descKrec-%s',filename);
fileID = fopen([NameFolderDataGraspi filenameDesc], 'w');
fprintf(fileID, '%f\n', krecm);
fclose(fileID);

filenameDesc=sprintf('descMob-%s',filename);
fileID = fopen([NameFolderDataGraspi filenameDesc], 'w');
fprintf(fileID, 'effMHole: %f\n', Muhm);
fprintf(fileID, 'effMEle: %f\n', Muem);
fclose(fileID);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Old averaging, this is now all useless...
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Hole mobilities
% ---------------------------------------------

% Average per line, whole field (a priori not used, this was dvpt)
HdepMobEHT = mean(MobEHT,2);
AvgMobEHT=mean(MobEHT,2);

% Average per line, restricted to EHTP (a priori not used, this was dvpt)
Matdum = zeros(size(Morph));
Matdum(IndEHT) = 1;
nnzperline = sum(Matdum,2);
HEffdepMobEHT = sum(MobEHT,2)./nnzperline;
Indnonode=find(nnzperline==0);
HEffdepMobEHT(Indnonode)=0;

% ---------------------------------------------
% Electron mobilities
% ---------------------------------------------

% Average per line, whole field (a priori not used, this was dvpt)
HdepMobEET = mean(MobEET,2);
AvgMobEET=mean(MobEET,2);

% Average per line, restricted to EETP (a priori not used, this was dvpt)
Matdum = zeros(size(Morph));
Matdum(IndEET) = 1;
nnzperline = sum(Matdum,2);
HEffdepMobEET = sum(MobEET,2)./nnzperline;
Indnonode=find(nnzperline==0);
HEffdepMobEET(Indnonode)=0;

% % ---------------------------------------------
% % Save the profiles (a priori useless)
% % ---------------------------------------------
%  
% filenameDesc=sprintf('HdepMob-%s',filename);
% fileID = fopen([NameFolderGraspi 'calculateMobility/' filenameDesc], 'w');
% fprintf(fileID,'iH HEffdepMobEHT HdepMobEHT HEffdepMobEET HdepMobEET\n');
% for iH=1:size(indexOfH,2)
%     fprintf(fileID,'%d %f %f %f %f\n',indexOfH(iH),HEffdepMobEHT(iH),HdepMobEHT(iH),HEffdepMobEET(iH),HdepMobEET(iH));
% end
% fclose(fileID);

%     % -----------------------------------------------------------------------
%     % ORYA code: Preparation of neighbors for CCL and of point to point distances
%     % -----------------------------------------------------------------------
%
%     % Il faut avoir la taille des images nxyz
%  nxyz = [sizeMorph(2) sizeMorph(1) 1]; % longueur  hauteur epaisseur
%
%
%     dxyz = [1 1 1];
%
%     % Define bondary conditions
%
% %     FlagBC = Inputs.Mesh.FlagBC;
%
%     FlagBC=[0 1 1]; %  % FlagBC = 0 (periodic), 1 (Neuman), 2 (Dirichlet)
%     % Choose connectivity
%     Connectivity = 'extended';
%
%     cd([RefCode '1-Core/'])
%
%     % Needed for CCL (do not touch)
%     Nnodes = prod(nxyz); Ndim = numel(find(nxyz>1));
%     [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz );
%     Nblocs=[1 1 1]; Ncpu=prod(Nblocs);
%     [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
%      Halosize = 2; ProcNum = 1;
%     [ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum);
%     [ LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, HaloNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers, IndLoc_Halo1, IndLoc_Halo2 ] = DomainDecompo_MappingsPerWorker( ProcNum, nxyz, FlagBC, Ncpu, Nblocs, Halosize, StartStopInd_percpu );
%     [ NEI.NoNeighb ] = Mesh_NoNeighbours( AllNodes_GlobalCarto_ord, AllShiftDirs, nxyz, FlagBC );
%     NEI.NNeighb = size(NEI.NoNeighb,2);
%
%     [ MeshCoord ] = MeshCoordinate ( nxyz, dxyz );
%     MeshCoord = MeshCoord + 0.5;
%     DeltaX = zeros(nxyz(1),nxyz(1)); % distances x taking into account BC along x direction
%     for ix = 1:nxyz(1)
%         PointCoord = [ix 1 1];
%         [ PointMeshCoordXYZ ] = MeshClosestCoordToPoint(nxyz, dxyz, MeshCoord, PointCoord, FlagBC);
%         IndUseful = find(PointMeshCoordXYZ(:,2)==1);
%         DeltaX(ix,:) = PointMeshCoordXYZ(IndUseful,1);
%     end
%
%     MorphoTypesD = [0 3 5]; % [0 3 5] for up (donor), [1 3 7] for down,
%     MorphoTypesA = [1 3 7]; % [0 3 5] for up (acceptor), [1 3 7] for down,
%     SourceTargetPlanesUp = [1 2]; % Number of source and target planes; [1 2] for up, [2,1] for down
%     SourceTargetPlanesDown = [2 1]; % Number of source and target planes;
%     [1 2] for up, [2,1] for down
%
%     for iy=2:sizeMorph(1)-1
%         iy
%
%         sumEffEH=0; itEffH=0;
%         sumEffEE=0; itEffE=0;
%
%         for ix=1:sizeMorph(2)
%
% %             twoLayersUp=MorphEHT(iy:iy+1,:);
% %             twoLayersDown=MorphEET(iy-1:iy,:);
%             if ix==1
%                 twoLayersUp=MorphEHT(iy:iy+1,[sizeMorph(2) ix ix+1]);
%                 twoLayersDown=MorphEET(iy-1:iy,[sizeMorph(2) ix ix+1]);
%
%             elseif ix==sizeMorph(2)
%                 twoLayersUp=MorphEHT(iy:iy+1,[ix-1 ix 1]);
%                 twoLayersDown=MorphEET(iy-1:iy,[ix-1 ix 1]);
%             else
%                 twoLayersUp=MorphEHT(iy:iy+1,ix-1:ix+1);
%                 twoLayersDown=MorphEET(iy-1:iy,ix-1:ix+1);
%             end
%
%             currPhase=Morph(iy,ix);
%             if ( (currPhase == 0 ) || (currPhase == 3 ) || (currPhase == 5 ))
%                 % locMuH=ComputeLocMuH(ix,iy,twoLayersUp,  phiDMorph(iy:iy+1,:),Morph(iy:iy+1,:));
%                 locMuH = ComputeLocMuH_ORYA(ix,iy,twoLayersUp,  phiDMorph(iy:iy+1,:),Morph(iy:iy+1,:),NEI,Ndim,Connectivity,DeltaX,MorphoTypesD,PostParam.Elec.Weights,SourceTargetPlanesUp);
%                 if(MorphEHT(iy,ix)==1)
%                     sumEffEH=sumEffEH+locMuH;
%                     itEffH=itEffH+1;
%                     MobEHT(iy,ix)=locMuH;
%                 end
%             end
%
%             if ( (currPhase == 1 ) || (currPhase == 3 ) || (currPhase == 7 ))
%                 % locMuE=ComputeLocMuE(ix,iy,twoLayersDown,phiAMorph(iy-1:iy,:),Morph(iy-1:iy,:));
%                 locMuE=ComputeLocMuH_ORYA(ix,iy,twoLayersDown,phiAMorph(i
%                 y-1:iy,:),Morph(iy-1:iy,:),NEI,Ndim,Connectivity,DeltaX,MorphoTypesA,PostParam.Elec.Weights,SourceTargetPlanesDown);
%                 if (MorphEET(iy,ix) == 1)
%                     sumEffEE=sumEffEE+locMuE;
%                     itEffE=itEffE+1;
%                     MobEET(iy,ix)=locMuE;
%                 end
%             end
%
%         end
%
%         HdepMobEHT(iy)=mean(MobEHT(iy,:));
%         HdepMobEET(iy)=mean(MobEET(iy,:));
%         if(itEffH ~= 0)
%             HEffdepMobEHT(iy)=sumEffEH/itEffH;
%         end
%         if(itEffE ~=0)
%             HEffdepMobEET(iy)=sumEffEE/itEffE;
%         end
%         %        fprintf('Avg: %f sum: %f, it: %d, effAvg: %f\n', HdepMobEHT(iy), sumEffEH, itEffH, HEffdepMobEHT(iy) );
%         %        fprintf('Avg: %f sum: %f, it: %d, effAvg: %f\n', HdepMobEET(iy), sumEffEE, itEffE, HEffdepMobEET(iy) );
%
%     end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write output
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NB:
% Ncetp = Ncetpmix + Ncetpd + Ncetpa
% Neetp = Nb + Ncetpmix
% Nehtp = Nc + Ncetpmix
% Neetpehtp = Neetp + Nehtp - Ncetpmix = Nb + Nc + Ncetpmix

% Fields
MorphoElecAnalysis.PhaseType.Morph = Morph;
MorphoElecAnalysis.PhaseType.MorphDesc3 = MorphDesc3;
MorphoElecAnalysis.PhaseType.MorphEET = MorphEET;
MorphoElecAnalysis.PhaseType.MorphEHT = MorphEHT;
MorphoElecAnalysis.Dissociation.DistHole = DistHole;
MorphoElecAnalysis.Dissociation.DistElec = DistElec;
MorphoElecAnalysis.Dissociation.DissoEfficiency = DissoEfficiency;
MorphoElecAnalysis.Recombination.CalcKrecFinal = CalcKrecFinal;
MorphoElecAnalysis.Recombination.krecDescPlot = krecDescPlot;
MorphoElecAnalysis.Recombination.CalcKrecTrape = CalcKrecTrape;
MorphoElecAnalysis.Recombination.CalcKrecTraph = CalcKrecTraph;
MorphoElecAnalysis.Mobilities.MobEHT = MobEHT;
MorphoElecAnalysis.Mobilities.MobEET = MobEET;

% Indices (useful later for plots only)
MorphoElecAnalysis.PhaseType.IndEHT = IndEHT;
MorphoElecAnalysis.PhaseType.IndEET = IndEET;

% Average / integrated values
MorphoElecAnalysis.PhaseType.Ntot = Ntot;
MorphoElecAnalysis.PhaseType.Neetpehtp = Neetpehtp;
MorphoElecAnalysis.PhaseType.Neetp = Neetp;
MorphoElecAnalysis.PhaseType.Nehtp = Nehtp;
MorphoElecAnalysis.PhaseType.Ncetp = Ncetp;
MorphoElecAnalysis.PhaseType.Ncetpmix = Ncetpmix;
MorphoElecAnalysis.PhaseType.Nmixnotcetp = Nmixnotcetp;
MorphoElecAnalysis.PhaseType.Ncetpd = Ncetpd;
MorphoElecAnalysis.PhaseType.Ncetpa = Ncetpa;
MorphoElecAnalysis.PhaseType.Nb = Nb;
MorphoElecAnalysis.PhaseType.Nc = Nc;
MorphoElecAnalysis.Dissociation.DissoPa = DissoPa;
MorphoElecAnalysis.Dissociation.DissoPb = DissoPb;
MorphoElecAnalysis.Dissociation.DissoPc = DissoPc;
MorphoElecAnalysis.Dissociation.Etadm = Etadm;
MorphoElecAnalysis.Recombination.krecm = krecm;
MorphoElecAnalysis.Recombination.krecTrapem = krecTrapem;
MorphoElecAnalysis.Recombination.krecTraphm = krecTraphm;
MorphoElecAnalysis.Recombination.krecTrapehm = krecTrapehm;
MorphoElecAnalysis.Mobilities.Muem = Muem;
MorphoElecAnalysis.Mobilities.Muhm = Muhm;

% Correspondance with Olga's variables
%  
% - ...IdsETMixed.txt: the list of nodes in the 'mixed phase part' of the CETP (not including the nodes neighbouring interfaces between pure donor and acceptor regions)
% - ...IdsEETacceptor.txt: list of nodes at the DA interface in the 'acceptor part' of the CETP; what we called '3b'
% - ...IdsEHTdonor.txt: list of nodes at the DA interface in the 'donor part' of the CETP; what we called '3c'
%
% - the ...DistancesWhiteYellowGreyToGREEN.txt: this is the field of smallest distances to the CETP for the nodes that are in the EETP but not in the mixed phase part of the CETP (corresponding to Pb, Nb); NB: this contains 3b
% - the ...DistancesBlackOrangeGreyToGREEN.txt: this is the field of smallest distances to the CETP for the nodes that are in the EHTP but not in themixed phase part of the CETP (corresponding to Pc, Nc); NB: this contains 3c
%
% - nMeff = Ncetpmixed: number of nodes in the 'mixed phase part' of the CETP (not including the nodes neighbouring interfaces between pure donor and acceptor regions, those we called 3b and 3c). nMeff is also equal to our 'Pa'
% - eAeff = Ncetpa: number of nodes at the DA interface in the 'acceptor part' of the CETP; what we called '3b'
% - eDeff = Ncetpd: number of nodes at the DA interface in the 'donor part' of the CETP; what we called '3c'
% - Pb = DissoPb: sum(exp(-Dist/L)) over the nodes of the EETP that are not in the mixed phase part of the CETP; our 'Pb' of the paper 
% - Pc = DissoPc: sum(exp(-Dist/L)) over the nodes of the EHTP that are not in the mixed phase part of the CETP; our 'Pc' of the paper
% - Nb: number of nodes in the EETP that are not in the CETP
% - Nc: number of nodes in the EHTP that are not in the CETP
% - n: total number of nodes
% 
% The average dissociation efficiency is calculated as: (nMeff+Pb+Pc)/n

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Figures
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % ---------------------------------------------
% % Colormaps
% % ---------------------------------------------
% 
% % For the different phases
% customMap = [0 0 0;    % 0- Black
%     1 1 1;    % 1- White
%     0.5 0.5 0.5;    % 2- grey (void)
%     0.5 0.5 0.5;    % 3- grey
%     0.5 0.5 0.5;    % 4- (void)
%     1 0.64 0;    % 5- Orange 100% red, 64.7% green, and 0% blue.
%     1 0.64 0;    % 6- Orange (void)
%     1 1 0];   % 7- Yellow
% 
% customMapDesc = [0 0 0;    % 0- Black
%     1 1 1;    % 1- White
%     0.5 0.5 0.5   % 2- grey (void)
%     1 1 0];   % 3- Yellow
% 
% customEHT = [1 1 1;    % 0- White
%     255/255 197/255 203/255];    % 1- Red (top)
% 
% customEET = [1 1 1;    % 0- White
%     0 141/255 171/255];    % 1- Blue (bottom)
% 
% % ---------------------------------------------
% % Image of the phase type
% % ---------------------------------------------
% 
% imagesc(Morph);
% colormap(customMap);
% caxis([0 7]);
% imageFilename=sprintf('%s-M.png', filenameWOext);
% print([NameFolderGraspi 'visualMorph2/' imageFilename],'-dpng');
% 
% % ---------------------------------------------
% % Image of region common to both effective transport phases (CETP)
% % ---------------------------------------------
% % Sure about that???
% 
% figure;
% %     hIm=imagesc(0.5:1:x+0.5,0.5:1:y-0.5,MorphDesc3);
% Zpad = [MorphDesc3; MorphDesc3(end,:)];         % Repeat last row
% Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
% [a,b]=size(MorphDesc3);
% x = 0:a;   % 21 x-coordinates
% y = 0:b;   % 11 y-coordinates
% [X, Y] = meshgrid(x, y);
% surf(X,Y,Zpad','EdgeColor','none')
% view(90,270)
% axis equal tight
% %     caxis([0 3]);
% caxis([0 1]);
% xlabel('z [nm]')
% ylabel('x [nm]')
% myColors = [
%     1 1 1;         % 0 white
%     153/255 153/255 255/255      % non-zero purple
%     ];
% colormap(myColors)
% %     colormap(customMapDesc);
% %     colorbar
% imageFilename=sprintf('_1%s_DescCRETP.png', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])
% 
% pause(1);
% 
% % ---------------------------------------------
% % Image of effective electron transport phases (EETP)
% % ---------------------------------------------
% 
% figure;
% %     hIm=imagesc(MorphEET(end:-1:1,:));
% Zpad = [MorphEET; MorphEET(end,:)];         % Repeat last row
% Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
% [a,b]=size(MorphEET);
% x = 0:a;   % 21 x-coordinates
% y = 0:b;   % 11 y-coordinates
% [X, Y] = meshgrid(x, y);
% surf(X,Y,Zpad','EdgeColor','none')
% view(90,270)
% axis equal tight
% caxis([0 1]);
% xlabel('z [nm]')
% ylabel('x [nm]')
% colormap(customEET);
% imageFilename=sprintf('_2%s_EET.png', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])
% 
% pause(1);
% 
% % ---------------------------------------------
% % Image of effective hole transport phases (EETP)
% % ---------------------------------------------
% 
% figure;
% %     hIm=imagesc(MorphEHT(end:-1:1,:));
% Zpad = [MorphEHT; MorphEHT(end,:)];         % Repeat last row
% Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
% [a,b]=size(MorphEHT);
% x = 0:a;   % 21 x-coordinates
% y = 0:b;   % 11 y-coordinates
% [X, Y] = meshgrid(x, y);
% surf(X,Y,Zpad','EdgeColor','none')
% view(90,270)
% axis equal tight
% caxis([0 1]);
% xlabel('z [nm]')
% ylabel('x [nm]')
% colormap(customEHT);
% imageFilename=sprintf('_3%s_EHT.png', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])
% 
% pause(1);
% 
% % ---------------------------------------------
% % Image of distance between exciton and EHTP
% % ---------------------------------------------
% 
% figure;
% %     hIm=imagesc(DistHole(end:-1:1,:));
% Zpad = [DistHole; DistHole(end,:)];         % Repeat last row
% Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
% [a,b]=size(DistHole);
% x = 0:a;   % 21 x-coordinates
% y = 0:b;   % 11 y-coordinates
% [X, Y] = meshgrid(x, y);
% surf(X,Y,Zpad','EdgeColor','none')
% view(90,270)
% axis equal tight
% caxis([0 20]);
% %     colormap(customMapDesc);
% xlabel('z [nm]')
% ylabel('x [nm]')
% colorbar
% colormap(jet(21));
% imageFilename=sprintf('_4%s_DistHol.png', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])
% 
% pause(1);
% 
% % ---------------------------------------------
% % Image of distance between exciton and EETP
% % ---------------------------------------------
% 
% figure;
% %    hIm=imagesc(DistElec);
% Zpad = [DistElec; DistElec(end,:)];         % Repeat last row
% Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
% [a,b]=size(DistElec);
% x = 0:a;   % 21 x-coordinates
% y = 0:b;   % 11 y-coordinates
% [X, Y] = meshgrid(x, y);
% surf(X,Y,Zpad','EdgeColor','none')
% view(90,270)
% axis equal tight
% caxis([0 20]);
% colorbar
% %    colormap(customMapDesc);
% colormap(jet(100));
% xlabel('z [nm]')
% ylabel('x [nm]')
% imageFilename=sprintf('_5%s_DistElec.png', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])
% 
% pause(1);
% 
% % ---------------------------------------------
% % Image of exciton diffusion efficiency
% % ---------------------------------------------
% 
% figure;
% %    hIm=imagesc(DistElec);
% Zpad = [DissoEfficiency; DissoEfficiency(end,:)];         % Repeat last row
% Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
% [a,b]=size(DissoEfficiency);
% x = 0:a;   % 21 x-coordinates
% y = 0:b;   % 11 y-coordinates
% [X, Y] = meshgrid(x, y);
% surf(X,Y,Zpad','EdgeColor','none');
% view(90,270)
% axis equal tight
% caxis([-0.01 1]);
% colorbar
% %    colormap(customMapDesc);
% xlabel('z [nm]')
% ylabel('x [nm]')
% colormap([ [1 1 1]; jet(121)]);
% imageFilename=sprintf('_6%s_DissoEfficiency.png', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave  imageFilename(1:end-4) '.fig'])
% 
% pause(1);
% 
% close all;

end