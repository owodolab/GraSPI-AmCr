clear;

myFiles = dir('MorphParamSet*MorphoDesc.txt'); %gets all mat files in struct
nMorph = length(myFiles);

customMap = [0 0 0;    % 0- Black
             1 1 1;    % 1- White
             0.5 0.5 0.5;    % 2- grey (void)
             0.5 0.5 0.5;    % 3- grey
             0.5 0.5 0.5;    % 4- (void)
             1 0.64 0;    % 5- Orange 100% red, 64.7% green, and 0% blue.
             1 0.64 0;    % 6- Orange (void)
             1 1 0];   % 7- Yellow

customMapDesc = [0 0 0;    % 0- Black
                 1 1 1;    % 1- White
                 0.5 0.5 0.5   % 2- grey (void)
                 1 1 0];   % 3- Yellow

customEHT = [1 1 1;    % 0- White
             1 0 0];    % 1- Red (top)

customEET = [1 1 1;    % 0- White
             0 0 1];    % 1- Blue (bottom)


for fileId = 1:length(myFiles)
    fileId
    filename = myFiles(fileId).name;
    filenameWOext = extractBefore(filename, ".");

    Morph =  readmatrix(filename,'NumHeaderLines',1);
    sizeMorph = size(Morph);
    imagesc(Morph);
    colormap(customMap);
    clim([0 7]);
    imageFilename=sprintf('%s-M.png', filenameWOext);
    print(imageFilename,'-dpng');

    MorphDesc=zeros(sizeMorph);
    CalcKrec=zeros(sizeMorph);
    MobEET=zeros(sizeMorph);
    MobEHT=zeros(sizeMorph);
    MorphEET=zeros(sizeMorph);
    MorphEHT=zeros(sizeMorph);
    
    % -----------------------------------------------------------------------
    % ORYA code: Preparation of neighbors for CCL and of point to point distances
    % -----------------------------------------------------------------------
    
%     % Il faut avoir la taille des images nxyz
%     nxyz = [sizeMorph(2) sizeMorph(1) 1]; 
%     dxyz = [1 1 1];
% 
%     % Define boundary conditions
%     FlagBC = [0 1 1]; 
% 
%     % Choose connectivity
%     Connectivity = 'extended';
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
    
    k_pen_A2C = 1; % penalty prefactor on mobility when travelling from amorphous to crystalline
    Weights = [0.1 0.1 1]; % [0.1 0.1 1] for up and down 
    MorphoTypesD = [0 3 5]; % [0 3 5] for up (donor), [1 3 7] for down, 
    MorphoTypesA = [1 3 7]; % [0 3 5] for up (acceptor), [1 3 7] for down, 
%     SourceTargetPlanesUp = [1 2]; % Number of source and target planes; [1 2] for up, [2,1] for down
%     SourceTargetPlanesDown = [2 1]; % Number of source and target planes; [1 2] for up, [2,1] for down   

    % -----------------------------------------------------------------------
    % Back to Olga's code
    % -----------------------------------------------------------------------
    
    filenameDescETmixed=convertCharsToStrings(filenameWOext)+'-IdsETmixed.txt';
    filenameDescEETacceptor=convertCharsToStrings(filenameWOext)+'-IdsEETacceptor.txt';
    filenameDescEHTdonor=convertCharsToStrings(filenameWOext)+'-IdsEHTdonor.txt';
    
    filenamePhiA=convertCharsToStrings(filenameWOext)+'-phiA.txt';
    filenamePhiD=convertCharsToStrings(filenameWOext)+'-phiD.txt';
    
    phiAMorph=importdata(filenamePhiA);
    phiDMorph=importdata(filenamePhiD);

    filenameEET=convertCharsToStrings(filenameWOext)+'-IdsEET.txt';
    filenameEHT=convertCharsToStrings(filenameWOext)+'-IdsEHT.txt';
   
    EET=importdata(filenameEET);
    EHT=importdata(filenameEHT);
    sizeEET=size(EET);
    sizeEHT=size(EHT);
    for i=1:sizeEET(1)
        x=EET(i,1);
        y=EET(i,2);
        color=EET(i,3);
        MorphEET(y+1,x+1)=1;
    end
    for i=1:sizeEHT(1)
        x=EHT(i,1);
        y=EHT(i,2);
        color=EHT(i,3);
        MorphEHT(y+1,x+1)=1;
    end


    DETmixed=importdata(filenameDescETmixed);
    sizeDETmixed=size(DETmixed);
    for i=1:sizeDETmixed(1)
        x=DETmixed(i,1);
        y=DETmixed(i,2);
        color=DETmixed(i,4);
        MorphDesc(y+1,x+1)=2;
    end

    DEETacceptor=importdata(filenameDescEETacceptor);
    sizeDEETacceptor=size(DEETacceptor);
    for i=1:sizeDEETacceptor(1)
        x=DEETacceptor(i,1);
        y=DEETacceptor(i,2);
        color=DEETacceptor(i,4);
        MorphDesc(y+1,x+1)=1;
    end

    DEHTdonor=importdata(filenameDescEHTdonor);
    sizeDEHTdonor=size(DEHTdonor);
    for i=1:sizeDEHTdonor(1)
        x=DEHTdonor(i,1);
        y=DEHTdonor(i,2);
        color=DEHTdonor(i,4);
        MorphDesc(y+1,x+1)=3;
    end

    HdepMobEHT=zeros(sizeMorph(1),1);
    HdepMobEET=zeros(sizeMorph(1),1);
    HEffdepMobEHT=zeros(sizeMorph(1),1);
    HEffdepMobEET=zeros(sizeMorph(1),1);
    
    % Calculate w_h*phi^2 everywhere ---------------------------------------------------
    
    whphi2_EHT = zeros(size(Morph));
    whphi2_EET = zeros(size(Morph));

    IndMixed = find(Morph==3);
    
    % Fill with wh
    whphi2_EHT(IndMixed) = Weights(2);
    IndDam = find(Morph==0);
    whphi2_EHT(IndDam) = Weights(1);
    IndDcr = find(Morph==5);
    whphi2_EHT(IndDcr) = Weights(3);
    
    % Multiply by phi^2
    whphi2_EHT = whphi2_EHT.*phiDMorph.^2;
    
    % Set to zero outside EHT
    IndEHT = find(MorphEHT==1);
    IndnotEHT = find(MorphEHT~=1);
    whphi2_EHT(IndnotEHT) = 0;

    % Fill with wh
    whphi2_EET(IndMixed) = Weights(2);
    IndAam = find(Morph==1);
    whphi2_EET(IndAam) = Weights(1);
    IndAcr = find(Morph==7);
    whphi2_EET(IndAcr) = Weights(3);
    
    % Multiply by phi^2
    whphi2_EET = whphi2_EET.*phiAMorph.^2;

    % Set to zero outside EET
    IndEET = find(MorphEET==1);
    IndnotEET = find(MorphEET~=1);
    whphi2_EET(IndnotEET) = 0;

    % Crystallinity indicator
    IndicCr_EHT = zeros(size(Morph));
    IndicCr_EET = zeros(size(Morph));
    IndicCr_EHT(IndDcr) = 1;
    IndicCr_EET(IndAcr) = 1;
    
    % Calculate mobility in HTP ---------------------------------------

    % Calculate mobility for direct neighbour, holes, transport in direction of increasing row subscripts
    % then circshift along dim 1, negative shift
    whphi2_EHT_Neighb1 = circshift(whphi2_EHT,-1,1);
    IndicCr_EHT_Neighb1 = circshift(IndicCr_EHT,-1,1);
    PhaseSwitch = IndicCr_EHT_Neighb1-IndicCr_EHT;
    IndPhaseSwitch = find(IndicCr_EHT_Neighb1-IndicCr_EHT==1);
    whphi2_EHT_Neighb1(IndPhaseSwitch) = k_pen_A2C*whphi2_EHT_Neighb1(IndPhaseSwitch);
    % Now mobility for neighbour left
    whphi2_EHT_Neighb2 = circshift(whphi2_EHT_Neighb1,1,2)*cos(-pi/4);
    IndicCr_EHT_Neighb2 = circshift(IndicCr_EHT_Neighb1,1,2);
    PhaseSwitch = IndicCr_EHT_Neighb2-IndicCr_EHT;
    IndPhaseSwitch = find(IndicCr_EHT_Neighb2-IndicCr_EHT==1);
    whphi2_EHT_Neighb2(IndPhaseSwitch) = k_pen_A2C*whphi2_EHT_Neighb2(IndPhaseSwitch);
    % Now mobility for neighbour right
    whphi2_EHT_Neighb3 = circshift(whphi2_EHT_Neighb1,-1,2)*cos(pi/4);
    IndicCr_EHT_Neighb3 = circshift(IndicCr_EHT_Neighb1,-1,2);
    PhaseSwitch = IndicCr_EHT_Neighb3-IndicCr_EHT;
    IndPhaseSwitch = find(IndicCr_EHT_Neighb3-IndicCr_EHT==1);
    whphi2_EHT_Neighb3(IndPhaseSwitch) = k_pen_A2C*whphi2_EHT_Neighb3(IndPhaseSwitch);
    % Take the max
    whphi2_EHT_AllNeighb = max(whphi2_EHT_Neighb1,whphi2_EHT_Neighb2);
    whphi2_EHT_AllNeighb = max(whphi2_EHT_AllNeighb,whphi2_EHT_Neighb3);
    % Remove last line
    whphi2_EHT_AllNeighb(sizeMorph(1),:) = 0;
    % Fill only in EHT
    MobEHT(IndEHT) = whphi2_EHT_AllNeighb(IndEHT);
    % Average per line
    HdepMobEHT = mean(MobEHT,2);
    Matdum = zeros(size(Morph));
    Matdum(IndEHT) = 1;
    nnzperline = sum(Matdum,2);
    HEffdepMobEHT = sum(MobEHT,2)/nnzperline;
    
    % Calculate mobility in ETP ---------------------------------------
    
    % Calculate mobility for direct neighbour, holes, transport in direction of decreasing row subscripts
    % then circshift along dim 1, positive shift
    whphi2_EET_Neighb1 = circshift(whphi2_EET,1,1);
    IndicCr_EET_Neighb1 = circshift(IndicCr_EET,-1,1);
    PhaseSwitch = IndicCr_EET_Neighb1-IndicCr_EET;
    IndPhaseSwitch = find(IndicCr_EET_Neighb1-IndicCr_EET==1);
    whphi2_EET_Neighb1(IndPhaseSwitch) = k_pen_A2C*whphi2_EET_Neighb1(IndPhaseSwitch);
    % Now mobility for neighbour left
    whphi2_EET_Neighb2 = circshift(whphi2_EET_Neighb1,1,2)*cos(-pi/4);
    IndicCr_EET_Neighb2 = circshift(IndicCr_EET_Neighb1,-1,1);
    PhaseSwitch = IndicCr_EET_Neighb2-IndicCr_EET;
    IndPhaseSwitch = find(IndicCr_EET_Neighb2-IndicCr_EET==1);
    whphi2_EET_Neighb2(IndPhaseSwitch) = k_pen_A2C*whphi2_EET_Neighb2(IndPhaseSwitch);
    % Now mobility for neighbour right
    whphi2_EET_Neighb3 = circshift(whphi2_EET_Neighb1,-1,2)*cos(pi/4);
    IndicCr_EET_Neighb3 = circshift(IndicCr_EET_Neighb1,-1,1);
    PhaseSwitch = IndicCr_EET_Neighb3-IndicCr_EET;
    IndPhaseSwitch = find(IndicCr_EET_Neighb3-IndicCr_EET==1);
    whphi2_EET_Neighb3(IndPhaseSwitch) = k_pen_A2C*whphi2_EET_Neighb3(IndPhaseSwitch);
    % Take the max
    whphi2_EET_AllNeighb = max(whphi2_EET_Neighb1,whphi2_EET_Neighb2);
    whphi2_EET_AllNeighb = max(whphi2_EET_AllNeighb,whphi2_EET_Neighb3);
    % Remove first line
    whphi2_EET_AllNeighb(1,:) = 0;
    % Fill only in EET
    MobEET(IndEET) = whphi2_EET_AllNeighb(IndEET);
    % Average per line
    HdepMobEET = mean(MobEET,2);
    Matdum = zeros(size(Morph));
    Matdum(IndEET) = 1;
    nnzperline = sum(Matdum,2);
    HEffdepMobEET = sum(MobEET,2)/nnzperline;

    
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
%                 locMuH = ComputeLocMuH_ORYA(ix,iy,twoLayersUp,  phiDMorph(iy:iy+1,:),Morph(iy:iy+1,:),NEI,Ndim,Connectivity,DeltaX,MorphoTypesD,Weights,SourceTargetPlanesUp);
%                 if(MorphEHT(iy,ix)==1)
%                     sumEffEH=sumEffEH+locMuH;
%                     itEffH=itEffH+1;
%                     MobEHT(iy,ix)=locMuH;
%                 end
%             end
%             
%             if ( (currPhase == 1 ) || (currPhase == 3 ) || (currPhase == 7 ))
%                 % locMuE=ComputeLocMuE(ix,iy,twoLayersDown,phiAMorph(iy-1:iy,:),Morph(iy-1:iy,:));
%                 locMuE=ComputeLocMuH_ORYA(ix,iy,twoLayersDown,phiAMorph(iy-1:iy,:),Morph(iy-1:iy,:),NEI,Ndim,Connectivity,DeltaX,MorphoTypesA,Weights,SourceTargetPlanesDown);
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
    
    figure;
    imagesc(MobEHT);
    caxis([0 1]);
%    colormap(customMapDesc);
    colorbar;
    imageFilename=sprintf('%s-MobilityEHT.png', filenameWOext);
    print(imageFilename,'-dpng');


    figure;
    imagesc(MobEET);
    caxis([0 1]);
    colorbar;
    imageFilename=sprintf('%s-MobilityEET.png', filenameWOext);
    print(imageFilename,'-dpng');

    AvgMobEHT=mean(MobEHT,2);
    AvgMobEET=mean(MobEET,2);

    indexOfH=linspace(1,size(AvgMobEHT,1),size(AvgMobEHT,1));

    figure; hold on;
    xlabel('Avg Hole Mobility');
    ylabel('Height');
    xlim([0 1]);
    plot(AvgMobEHT,indexOfH,'DisplayName','Av-gl');
    plot(HdepMobEHT,indexOfH,'DisplayName','Av-H');
    plot(HEffdepMobEHT,indexOfH,'DisplayName','Eff');
    legend;
    imageFilename=sprintf('%s-AvgMobilityEHT.png', filenameWOext);
    print(imageFilename,'-dpng');

    figure; hold on;
    xlabel('Avg Electron Mobility');
    ylabel('Height');
    xlim([0 1]);
    plot(AvgMobEET,indexOfH,'DisplayName','Av-gl');
    plot(HdepMobEET,indexOfH,'DisplayName','Av-H');
    plot(HEffdepMobEET,indexOfH,'DisplayName','Eff');
    legend;
    imageFilename=sprintf('%s-AvgMobilityEET.png', filenameWOext);
    print(imageFilename,'-dpng');

    if all(HEffdepMobEHT(:) == 0)
        MobHDesc = 0.0;
    else
        MobHDesc=mean(HEffdepMobEHT(HEffdepMobEHT ~= 0));
    end

    if all(HEffdepMobEET(:)== 0)
        MobEDesc = 0;
    else
        MobEDesc=mean(HEffdepMobEET(HEffdepMobEET ~= 0));
    end
    
    filenameDesc=sprintf('descMob-%s',filename);
    fileID = fopen(filenameDesc, 'w');
    fprintf(fileID, 'effMHole: %f\n', MobHDesc);
    fprintf(fileID, 'effMEle: %f\n', MobEDesc);
    fclose(fileID);

% save the profiles
    filenameDesc=sprintf('HdepMob-%s',filename);
    fileID = fopen(filenameDesc, 'w');
    fprintf(fileID,'iH HEffdepMobEHT HdepMobEHT HEffdepMobEET HdepMobEET\n');
    for iH=1:size(indexOfH,2)
        fprintf(fileID,'%d %f %f %f %f\n',indexOfH(iH),HEffdepMobEHT(iH),HdepMobEHT(iH),HEffdepMobEET(iH),HdepMobEET(iH));
    end
    fclose(fileID);

end
%     save(['/data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/examples/5phaseMorphologies/HIERN-pipeline/calculateMobility/MobEHT_' filenameWOext(1:end-4) '.mat'],'MobEHT')
%     save(['/data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/examples/5phaseMorphologies/HIERN-pipeline/calculateMobility/MobEET_' filenameWOext(1:end-4) '.mat'],'MobEET')
