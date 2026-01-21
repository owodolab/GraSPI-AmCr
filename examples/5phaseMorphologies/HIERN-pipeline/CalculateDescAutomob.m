function [ MobEHT, IndEHT, MobEET, IndEET, MobEDesc, MobHDesc ] = CalculateDescAutomob (inputFile, NameFolderGraspi, PostParam )

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data and define filenames
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Names of the files (Graspi output) with the data we need
% ---------------------------------------------

filename = inputFile;
filenameWOext = extractBefore(filename, '.');

filenameDescETmixed=[filenameWOext '-IdsETmixed.txt'];
filenameDescEETacceptor=[filenameWOext '-IdsEETacceptor.txt'];
filenameDescEHTdonor=[filenameWOext '-IdsEHTdonor.txt'];
filenameEET=[filenameWOext '-IdsEET.txt'];
filenameEHT=[filenameWOext '-IdsEHT.txt'];

filenamePhiA=[filenameWOext '-phiA.txt'];
filenamePhiD=[filenameWOext '-phiD.txt'];

% ---------------------------------------------
% Load data
% ---------------------------------------------

% Morph =  readmatrix([NameFolderGraspi 'calculateMobility/' filename],'NumHeaderLines',1);
% sizeMorph = size(Morph);

% phiAMorph=importdata([NameFolderGraspi 'calculateMobility/' filenamePhiA]);
% phiDMorph=importdata([NameFolderGraspi 'calculateMobility/' filenamePhiD]);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matrices characterizing the different fields
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Matrix initialization
% ---------------------------------------------

MorphDesc=zeros(sizeMorph);
MorphEET=zeros(sizeMorph);
MorphEHT=zeros(sizeMorph);

MobEET=zeros(sizeMorph);
MobEHT=zeros(sizeMorph);

whphi2_EHT = zeros(size(Morph));
whphi2_EET = zeros(size(Morph));

HdepMobEHT=zeros(sizeMorph(1),1);
HdepMobEET=zeros(sizeMorph(1),1);
HEffdepMobEHT=zeros(sizeMorph(1),1);
HEffdepMobEET=zeros(sizeMorph(1),1);

% ---------------------------------------------
% Calculation: preparation
% ---------------------------------------------
% NB: part of this has already been done!!!

% % This is the effective electron transport phase
% EET=importdata([NameFolderGraspi 'calculateMobility/' filenameEET]);
% sizeEET=size(EET);
% for i=1:sizeEET(1)
%     x=EET(i,1);
%     y=EET(i,2);
%     color=EET(i,3);
%     MorphEET(y+1,x+1)=1;
% end

% % This is the effective hole transport phase
% EHT=importdata([NameFolderGraspi 'calculateMobility/' filenameEHT]);
% sizeEHT=size(EHT);
% for i=1:sizeEHT(1)
%     x=EHT(i,1);
%     y=EHT(i,2);
%     color=EHT(i,3);
%     MorphEHT(y+1,x+1)=1;
% end
% 
% % This is the ?mixed part of the CETP
% DETmixed=importdata([NameFolderGraspi 'calculateMobility/' filenameDescETmixed]);
% sizeDETmixed=size(DETmixed);
% for i=1:sizeDETmixed(1)
%     x=DETmixed(i,1);
%     y=DETmixed(i,2);
%     color=DETmixed(i,4);
%     MorphDesc(y+1,x+1)=2;
% end
% 
% % This is the part of the effective electron transport phase in the acceptor phases?
% DEETacceptor=importdata([NameFolderGraspi 'calculateMobility/' filenameDescEETacceptor]);
% sizeDEETacceptor=size(DEETacceptor);
% for i=1:sizeDEETacceptor(1)
%     x=DEETacceptor(i,1);
%     y=DEETacceptor(i,2);
%     color=DEETacceptor(i,4);
%     MorphDesc(y+1,x+1)=1;
% end
% 
% % This is the part of the effective hole transport phase in the donor phases?
% DEHTdonor=importdata([NameFolderGraspi 'calculateMobility/' filenameDescEHTdonor]);
% sizeDEHTdonor=size(DEHTdonor);
% for i=1:sizeDEHTdonor(1)
%     x=DEHTdonor(i,1);
%     y=DEHTdonor(i,2);
%     color=DEHTdonor(i,4);
%     MorphDesc(y+1,x+1)=3;
% end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identify useful domains
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IndMixed = find(Morph==3);
IndDam = find(Morph==0);
IndDcr = find(Morph==5);
IndAam = find(Morph==1);
IndAcr = find(Morph==7);
IndEHT = find(MorphEHT==1);
IndnotEHT = find(MorphEHT~=1);
IndEET = find(MorphEET==1);
IndnotEET = find(MorphEET~=1);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation of w_h*phi^2 at each point
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Crystallinity indicator
IndicCr_EHT = zeros(size(Morph));
IndicCr_EET = zeros(size(Morph));
IndicCr_EHT(IndDcr) = 1;
IndicCr_EET(IndAcr) = 1;

% ---------------------------------------------
% Local hole mobilities in the EHTP
% ---------------------------------------------

% Calculate mobility for direct neighbour, holes, transport in direction of increasing row subscripts

% Direct neighbour: circshift along dim 1, negative shift
whphi2_EHT_Neighb1 = circshift(whphi2_EHT,-1,1);
IndicCr_EHT_Neighb1 = circshift(IndicCr_EHT,-1,1);

% Now mobility for neighbour left
whphi2_EHT_Neighb2 = circshift(whphi2_EHT_Neighb1,1,2)*cos(-pi/4);
IndicCr_EHT_Neighb2 = circshift(IndicCr_EHT_Neighb1,1,2);
PhaseSwitch = IndicCr_EHT_Neighb2-IndicCr_EHT;
IndPhaseSwitch = find(IndicCr_EHT_Neighb2-IndicCr_EHT==1);
whphi2_EHT_Neighb2(IndPhaseSwitch) = PostParam.Elec.kpenA2C*whphi2_EHT_Neighb2(IndPhaseSwitch);

% Now mobility for neighbour right
whphi2_EHT_Neighb3 = circshift(whphi2_EHT_Neighb1,-1,2)*cos(pi/4);
IndicCr_EHT_Neighb3 = circshift(IndicCr_EHT_Neighb1,-1,2);
PhaseSwitch = IndicCr_EHT_Neighb3-IndicCr_EHT;
IndPhaseSwitch = find(IndicCr_EHT_Neighb3-IndicCr_EHT==1);
whphi2_EHT_Neighb3(IndPhaseSwitch) = PostParam.Elec.kpenA2C*whphi2_EHT_Neighb3(IndPhaseSwitch);

% Penalty on mobility along dim 1 do not move this line elsewhere !!
% Olivier: WHY THE HELL?
% This line is useless: PhaseSwitch = IndicCr_EHT_Neighb1-IndicCr_EHT;
% Olivier: I think both lines below could go up
IndPhaseSwitch = find(IndicCr_EHT_Neighb1-IndicCr_EHT==1);
whphi2_EHT_Neighb1(IndPhaseSwitch) = PostParam.Elec.kpenA2C*whphi2_EHT_Neighb1(IndPhaseSwitch);

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

% Calculate mobility for direct neighbour, holes, transport in direction of decreasing row subscripts

% then circshift along dim 1, positive shift
whphi2_EET_Neighb1 = circshift(whphi2_EET,1,1);
IndicCr_EET_Neighb1 = circshift(IndicCr_EET,1,1);

% Now mobility for neighbour left
whphi2_EET_Neighb2 = circshift(whphi2_EET_Neighb1,1,2)*cos(-pi/4);
IndicCr_EET_Neighb2 = circshift(IndicCr_EET_Neighb1,1,1);
PhaseSwitch = IndicCr_EET_Neighb2-IndicCr_EET;
IndPhaseSwitch = find(IndicCr_EET_Neighb2-IndicCr_EET==1);
whphi2_EET_Neighb2(IndPhaseSwitch) = PostParam.Elec.kpenA2C*whphi2_EET_Neighb2(IndPhaseSwitch);

% Now mobility for neighbour right
whphi2_EET_Neighb3 = circshift(whphi2_EET_Neighb1,-1,2)*cos(pi/4);
IndicCr_EET_Neighb3 = circshift(IndicCr_EET_Neighb1,1,1);
PhaseSwitch = IndicCr_EET_Neighb3-IndicCr_EET;
IndPhaseSwitch = find(IndicCr_EET_Neighb3-IndicCr_EET==1);
whphi2_EET_Neighb3(IndPhaseSwitch) = PostParam.Elec.kpenA2C*whphi2_EET_Neighb3(IndPhaseSwitch);

%penalty on mobility along dim 1 do not move this line elsewhere !!
PhaseSwitch = IndicCr_EET_Neighb1-IndicCr_EET;
IndPhaseSwitch = find(IndicCr_EET_Neighb1-IndicCr_EET==1);
whphi2_EET_Neighb1(IndPhaseSwitch) = PostParam.Elec.kpenA2C*whphi2_EET_Neighb1(IndPhaseSwitch);

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

[ MobEDesc ] = HarmonicAverage( MobEET(2:end,:), find(MorphEET(2:end,:)==1), MorphEET(2:end,:), PostParam.Elec.MobilityMinValue, PostParam.Elec.MobilityAveragingMode);
[ MobHDesc ] = HarmonicAverage( MobEHT(1:end-1,:), find(MorphEHT(1:end-1,:)==1), MorphEHT(1:end-1,:), PostParam.Elec.MobilityMinValue, PostParam.Elec.MobilityAveragingMode);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save the global descriptor values in a file
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filenameDesc=sprintf('descMob-%s',filename);
fileID = fopen([NameFolderGraspi 'calculateMobility/' filenameDesc], 'w');
fprintf(fileID, 'effMHole: %f\n', MobHDesc);
fprintf(fileID, 'effMEle: %f\n', MobEDesc);
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





% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Figures
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % ---------------------------------------------
% % Colormaps
% % ---------------------------------------------
% 
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
%     1 0 0];    % 1- Red (top)
% 
% customEET = [1 1 1;    % 0- White
%     0 0 1];    % 1- Blue (bottom)
% 
% ---------------------------------------------
% Figure of morphology
% ---------------------------------------------

%     imagesc(Morph(end:-1:1,:));
%     colormap(customMap);
%     caxis([0 7]);
%     imageFilename=sprintf('%s-M', filenameWOext);
%     print([NameWorkflowSave imageFilename],'-dpng');

% % ---------------------------------------------
% % Figures of local hole mobility
% % ---------------------------------------------
% 
% figure;
% %     imagesc(MobEHT(end:-1:1,:));
% Mobplot=-1*ones(size(MobEHT));
% Mobplot(IndEHT)=MobEHT(IndEHT);
% Zpad = [Mobplot; Mobplot(end,:)];         % Repeat last row
% Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
% [a,b]=size(MobEHT);
% x = 0:a;   % 21 x-coordinates
% y = 0:b;   % 11 y-coordinates
% [X, Y] = meshgrid(x, y);
% surf(X,Y,Zpad','EdgeColor','none')
% view(90,270)
% axis equal tight
% %     axis ([0.5:10.5 0.5 20.5])
% caxis([-0.01 1]);
% %    colormap(customMapDesc);
% colormap([ [1 1 1] ;jet(100)]);
% colorbar;
% xlabel('z [nm]')
% ylabel('x [nm]')
% 
% imageFilename=sprintf('_8%s_MobilityEHT', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave imageFilename '.fig'])
% 
% pause(1)
% 
% % ---------------------------------------------
% % Figures of local electron mobility
% % ---------------------------------------------
% 
% figure;
% Mobplot=-1*ones(size(MobEET));
% Mobplot(IndEET)=MobEET(IndEET);
% %     imagesc(MobEET(end:-1:1,:));
% Zpad = [Mobplot; Mobplot(end,:)];         % Repeat last row
% Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
% [a,b]=size(Mobplot);
% x = 0:a;   % 21 x-coordinates
% y = 0:b;   % 11 y-coordinates
% [X, Y] = meshgrid(x, y);
% surf(X,Y,Zpad','EdgeColor','none')
% view(90,270)
% axis equal tight
% caxis([-0.01 1]);
% colorbar;
% xlabel('z [nm]')
% ylabel('x [nm]')
% colormap([ [1 1 1] ;jet(100)]);
% 
% imageFilename=sprintf('_9%s_MobilityEET', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave imageFilename '.fig'])
% 
% pause(1)
% 
% % ---------------------------------------------
% % Figures of line-averaged electron and hole mobilities (a priori useless)
% % ---------------------------------------------
% 
% indexOfH=linspace(1,size(AvgMobEHT,1),size(AvgMobEHT,1));
% 
% figure; hold on;
% xlabel('Avg Hole Mobility');
% ylabel('Height');
% xlim([0 1]);
% plot(AvgMobEHT,indexOfH,'DisplayName','Av-gl');
% plot(HdepMobEHT,indexOfH,'DisplayName','Av-H');
% plot(HEffdepMobEHT,indexOfH,'DisplayName','Eff');
% legend;
% 
% imageFilename=sprintf('_10%s_AvgMobilityEHT', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave imageFilename '.fig'])
% 
% pause(1)
% 
% figure; hold on;
% xlabel('Avg Electron Mobility');
% ylabel('Height');
% xlim([0 1]);
% plot(AvgMobEET,indexOfH,'DisplayName','Av-gl');
% plot(HdepMobEET,indexOfH,'DisplayName','Av-H');
% plot(HEffdepMobEET,indexOfH,'DisplayName','Eff');
% legend;
% 
% imageFilename=sprintf('_11%s_AvgMobilityEET', filenameWOext);
% print([NameWorkflowSave imageFilename],'-dpng');
% savefig([NameWorkflowSave imageFilename '.fig'])
% 
% pause(1)

end

