
% myFiles = dir('MorphFields*MorphoDesc.txt'); %gets all mat files in struct
% nMorph = length(myFiles);

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


    filename = inputFile;
    filenameWOext = extractBefore(filename, '.');

    Morph =  readmatrix(filename,'NumHeaderLines',1);
    sizeMorph = size(Morph);
    imagesc(Morph);
    colormap(customMap);
    caxis([0 7]);
    imageFilename=sprintf('%s-M', filenameWOext);
    print([NameWorkflowSave imageFilename],'-dpng');

    MorphDesc=zeros(sizeMorph);
    CalcKrec=zeros(sizeMorph);
    MobEET=zeros(sizeMorph);
    MobEHT=zeros(sizeMorph);
    MorphEET=zeros(sizeMorph);
    MorphEHT=zeros(sizeMorph);
    
    % -----------------------------------------------------------------------
    % ORYA code: Preparation of neighbors for CCL and of point to point distances
    % -----------------------------------------------------------------------
    
    % Il faut avoir la taille des images nxyz
 nxyz = [sizeMorph(2) sizeMorph(1) 1]; % longueur  hauteur epaisseur


    dxyz = [1 1 1];
    
    % Define bondary conditions
    
%     FlagBC = Inputs.Mesh.FlagBC; 

    FlagBC=[0 1 1]; %  % FlagBC = 0 (periodic), 1 (Neuman), 2 (Dirichlet) 
    % Choose connectivity
    Connectivity = 'extended';
    
    cd([RefCode '1-Core/'])
    
    % Needed for CCL (do not touch)
    Nnodes = prod(nxyz); Ndim = numel(find(nxyz>1));
    [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz );
    Nblocs=[1 1 1]; Ncpu=prod(Nblocs);
    [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
     Halosize = 2; ProcNum = 1;
    [ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum);
    [ LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, HaloNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers, IndLoc_Halo1, IndLoc_Halo2 ] = DomainDecompo_MappingsPerWorker( ProcNum, nxyz, FlagBC, Ncpu, Nblocs, Halosize, StartStopInd_percpu );
    [ NEI.NoNeighb ] = Mesh_NoNeighbours( AllNodes_GlobalCarto_ord, AllShiftDirs, nxyz, FlagBC );
    NEI.NNeighb = size(NEI.NoNeighb,2);

    [ MeshCoord ] = MeshCoordinate ( nxyz, dxyz );
    MeshCoord = MeshCoord + 0.5;
    DeltaX = zeros(nxyz(1),nxyz(1)); % distances x taking into account BC along x direction
    for ix = 1:nxyz(1)
        PointCoord = [ix 1 1];
        [ PointMeshCoordXYZ ] = MeshClosestCoordToPoint(nxyz, dxyz, MeshCoord, PointCoord, FlagBC);
        IndUseful = find(PointMeshCoordXYZ(:,2)==1);
        DeltaX(ix,:) = PointMeshCoordXYZ(IndUseful,1);
    end

    Weights = [0.1 0.1 1]; % [0.1 0.1 1] for up and down 
    MorphoTypesD = [0 3 5]; % [0 3 5] for up (donor), [1 3 7] for down, 
    MorphoTypesA = [1 3 7]; % [0 3 5] for up (acceptor), [1 3 7] for down, 
    SourceTargetPlanesUp = [1 2]; % Number of source and target planes; [1 2] for up, [2,1] for down
    SourceTargetPlanesDown = [2 1]; % Number of source and target planes; [1 2] for up, [2,1] for down   
    
    cd([NameFolderGraspi 'calculateMobility/']) 
    
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
    pause(20)
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
    
    for iy=2:sizeMorph(1)-1
        iy
        
        sumEffEH=0; itEffH=0;
        sumEffEE=0; itEffE=0;
        
        for ix=1:sizeMorph(2)
            
            twoLayersUp=MorphEHT(iy:iy+1,:);
            twoLayersDown=MorphEET(iy-1:iy,:);
            currPhase=Morph(iy,ix);
            
            if ( (currPhase == 0 ) || (currPhase == 3 ) || (currPhase == 5 ))
                % locMuH=ComputeLocMuH(ix,iy,twoLayersUp,  phiDMorph(iy:iy+1,:),Morph(iy:iy+1,:));
                locMuH = ComputeLocMuH_ORYA(ix,iy,twoLayersUp,  phiDMorph(iy:iy+1,:),Morph(iy:iy+1,:),NEI,Ndim,Connectivity,DeltaX,MorphoTypesD,Weights,SourceTargetPlanesUp,RefCode,NameFolderGraspi);
                if(MorphEHT(iy,ix)==1)
                    sumEffEH=sumEffEH+locMuH;
                    itEffH=itEffH+1;
                    MobEHT(iy,ix)=locMuH;
                end
            end
            
            if ( (currPhase == 1 ) || (currPhase == 3 ) || (currPhase == 7 ))
                % locMuE=ComputeLocMuE(ix,iy,twoLayersDown,phiAMorph(iy-1:iy,:),Morph(iy-1:iy,:));
                locMuE=ComputeLocMuH_ORYA(ix,iy,twoLayersDown,phiAMorph(iy-1:iy,:),Morph(iy-1:iy,:),NEI,Ndim,Connectivity,DeltaX,MorphoTypesA,Weights,SourceTargetPlanesDown,RefCode,NameFolderGraspi);
                if (MorphEET(iy,ix) == 1)
                    sumEffEE=sumEffEE+locMuE;
                    itEffE=itEffE+1;
                    MobEET(iy,ix)=locMuE;
                end
            end
            
        end
        
        HdepMobEHT(iy)=mean(MobEHT(iy,:));
        HdepMobEET(iy)=mean(MobEET(iy,:));
        if(itEffH ~= 0)
            HEffdepMobEHT(iy)=sumEffEH/itEffH;
        end
        if(itEffE ~=0)
            HEffdepMobEET(iy)=sumEffEE/itEffE;
        end
        %        fprintf('Avg: %f sum: %f, it: %d, effAvg: %f\n', HdepMobEHT(iy), sumEffEH, itEffH, HEffdepMobEHT(iy) );
        %        fprintf('Avg: %f sum: %f, it: %d, effAvg: %f\n', HdepMobEET(iy), sumEffEE, itEffE, HEffdepMobEET(iy) );
        
    end
    
    figure;
    imagesc(MobEHT(end:-1:1,:));
    caxis([0 1]);
%    colormap(customMapDesc);
    colorbar;
    imageFilename=sprintf('%s-MobilityEHT', filenameWOext);
    print([NameWorkflowSave imageFilename],'-dpng');
    savefig([NameWorkflowSave imageFilename '.fig'])
    pause(1)

    figure;
    imagesc(MobEET(end:-1:1,:));
    caxis([0 1]);
    colorbar;
    imageFilename=sprintf('%s-MobilityEET', filenameWOext);
    print([NameWorkflowSave imageFilename],'-dpng');
    savefig([NameWorkflowSave imageFilename '.fig'])
    pause(1)


    AvgMobEHT=mean(MobEHT,2);
    AvgMobEET=mean(MobEET,2);

    indexOfH=linspace(1,size(AvgMobEHT,1),size(AvgMobEHT,1));

    figure; hold on;
    xlabel('Avg Hole Mobility');
    ylabel('Height');
    xlim([0 1]);
    plot(AvgMobEHT(end:-1:1),indexOfH,'DisplayName','Av-gl');
    plot(HdepMobEHT(end:-1:1),indexOfH,'DisplayName','Av-H');
    plot(HEffdepMobEHT(end:-1:1),indexOfH,'DisplayName','Eff');
    legend;
    imageFilename=sprintf('%s-AvgMobilityEHT', filenameWOext);
    print([NameWorkflowSave imageFilename],'-dpng');
    savefig([NameWorkflowSave imageFilename '.fig'])
    pause(1)
    
    figure; hold on;
    xlabel('Avg Electron Mobility');
    ylabel('Height');
    xlim([0 1]);
    plot(AvgMobEET(end:-1:1),indexOfH,'DisplayName','Av-gl');
    plot(HdepMobEET(end:-1:1),indexOfH,'DisplayName','Av-H');
    plot(HEffdepMobEET(end:-1:1),indexOfH,'DisplayName','Eff');
    legend;
    imageFilename=sprintf('%s-AvgMobilityEET', filenameWOext);
    print([NameWorkflowSave imageFilename],'-dpng');
    savefig([NameWorkflowSave imageFilename '.fig'])
    pause(1)

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
    copyfile([NameFolderGraspi 'calculateMobility/HdepMob-Morph' NameFileSave '_sv_' num2str(TimeStepChoice(hhh)) '.txt'],[NameWorkflowSave 'HdepMob-Morph' NameFileSave '_sv_' num2str(TimeStepChoice(hhh)) '.txt'])
    save([NameWorkflowSave 'MobEHT_' inputFile(1:end-4) '.mat'],'MobEHT')
    save([NameWorkflowSave 'MobEET_' inputFile(1:end-4) '.mat'],'MobEET')
    

