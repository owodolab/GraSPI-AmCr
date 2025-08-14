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

    for iy=2:sizeMorph(1)-1
%            iy
            sumEffEH=0; itEffH=0;
            sumEffEE=0; itEffE=0;
        for ix=1:sizeMorph(2)
            twoLayersUp=MorphEHT(iy:iy+1,:);
            twoLayersDown=MorphEET(iy-1:iy,:);
            currPhase=Morph(iy,ix);
            if ( (currPhase == 0 ) || (currPhase == 3 ) || (currPhase == 5 ))
                locMuH=ComputeLocMuH(ix,iy,twoLayersUp,  phiDMorph(iy:iy+1,:),Morph(iy:iy+1,:));
                if(MorphEHT(iy,ix)==1)
                    sumEffEH=sumEffEH+locMuH;
                    itEffH=itEffH+1;
                    MobEHT(iy,ix)=locMuH;
                end
            end
            if ( (currPhase == 1 ) || (currPhase == 3 ) || (currPhase == 7 ))
                locMuE=ComputeLocMuE(ix,iy,twoLayersDown,phiAMorph(iy-1:iy,:),Morph(iy-1:iy,:));
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
    imagesc(MobEHT);
    clim([0 1]);
%    colormap(customMapDesc);
    colorbar;
    imageFilename=sprintf('%s-MobilityEHT.png', filenameWOext);
    print(imageFilename,'-dpng');


    figure;
    imagesc(MobEET);
    clim([0 1]);
    colorbar;
    imageFilename=sprintf('%s-MobilityEET.png', filenameWOext);
    print(imageFilename,'-dpng');

    AvgMobEHT=mean(MobEHT,2);
    AvgMobEET=mean(MobEET,2);

    indexOfH=linspace(1,size(AvgMobEHT,1),size(AvgMobEHT,1));

    figure; hold on;
    xlabel("Avg Hole Mobility");
    ylabel("Height");
    xlim([0 1]);
    plot(AvgMobEHT,indexOfH,'DisplayName','Av-gl');
    plot(HdepMobEHT,indexOfH,'DisplayName','Av-H');
    plot(HEffdepMobEHT,indexOfH,'DisplayName','Eff');
    legend;
    imageFilename=sprintf('%s-AvgMobilityEHT.png', filenameWOext);
    print(imageFilename,'-dpng');

    figure; hold on;
    xlabel("Avg Electron Mobility");
    ylabel("Height");
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
