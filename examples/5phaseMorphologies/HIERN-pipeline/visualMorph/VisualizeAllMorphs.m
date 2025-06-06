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
    MorphDistHole=zeros(sizeMorph);
    MorphDistElec=zeros(sizeMorph);
    MorphEET=zeros(sizeMorph);
    MorphEHT=zeros(sizeMorph);
    DistHole=zeros(sizeMorph);
    DistElec=zeros(sizeMorph);

    filenameDescETmixed=convertCharsToStrings(filenameWOext)+'-IdsETmixed.txt';
    filenameDescEETacceptor=convertCharsToStrings(filenameWOext)+'-IdsEETacceptor.txt';
    filenameDescEHTdonor=convertCharsToStrings(filenameWOext)+'-IdsEHTdonor.txt';
    filenameDescEHT=convertCharsToStrings(filenameWOext)+'-IdsEHT.txt';
    filenameDescEET=convertCharsToStrings(filenameWOext)+'-IdsEET.txt';

    filenameDistHole=convertCharsToStrings(filenameWOext)+'-DistancesBlackOrangeGreyToGREEN.txt';
    filenameDistElec=convertCharsToStrings(filenameWOext)+'-DistancesWhiteYellowGreyToGREEN.txt';
    
    filenamePhiA=convertCharsToStrings(filenameWOext)+'-phiA.txt';
    filenamePhiD=convertCharsToStrings(filenameWOext)+'-phiD.txt';

     phiAMorph=importdata(filenamePhiA);
     phiDMorph=importdata(filenamePhiD);
   
    
    DETmixed=importdata(filenameDescETmixed);
    if ~isempty(DETmixed) 
        sizeDETmixed=size(DETmixed);
        for i=1:DETmixed(1)
            x=DETmixed(i,1);
            y=DETmixed(i,2);
            color=DETmixed(i,4);
            MorphDesc(y+1,x+1)=2;
        end
    end

    DEETacceptor=importdata(filenameDescEETacceptor);
    if ~isempty(DEETacceptor) 
        sizeDEETacceptor=size(DEETacceptor);
        for i=1:sizeDEETacceptor(1)
            x=DEETacceptor(i,1);
            y=DEETacceptor(i,2);
            color=DEETacceptor(i,4);
            MorphDesc(y+1,x+1)=1;
        end
    end

    DEHTdonor=importdata(filenameDescEHTdonor);
    if ~isempty(DEHTdonor) 
        sizeDEHTdonor=size(DEHTdonor);
        for i=1:sizeDEHTdonor(1)
            x=DEHTdonor(i,1);
            y=DEHTdonor(i,2);
            color=DEHTdonor(i,4);
            MorphDesc(y+1,x+1)=3;
        end
    end

    EHT=importdata(filenameDescEHT);
    if ~isempty(EHT)
        sizeEHT=size(EHT);
        for i=1:sizeEHT(1)
            x=EHT(i,1);
            y=EHT(i,2);
            color=EHT(i,3);
            MorphEHT(y+1,x+1)=1;
        end
    end 

    EET=importdata(filenameDescEET);
    if ~isempty(EET)
        sizeEET=size(EET);
        for i=1:sizeEET(1)
            x=EET(i,1);
            y=EET(i,2);
            color=EET(i,3);
            MorphEET(y+1,x+1)=1;
        end
    end 

    figure;
    imagesc(MorphDesc);
    clim([0 3]);
    colormap(customMapDesc);
    imageFilename=sprintf('%s-Desc.png', filenameWOext);
    print(imageFilename,'-dpng');


    figure;
    imagesc(MorphEET);
    clim([0 1]);
    colormap(customEET);
    imageFilename=sprintf('%s-EET.png', filenameWOext);
    print(imageFilename,'-dpng');

    figure;
    imagesc(MorphEHT);
    clim([0 1]);
    colormap(customEHT);
    imageFilename=sprintf('%s-EHT.png', filenameWOext);
    print(imageFilename,'-dpng');


    DistEHT=importdata(filenameDistHole);
    sizeDistEHT=size(DistEHT);
    for i=1:sizeDistEHT(1)
        x=DistEHT(i,1);
        y=DistEHT(i,2);
        DistHole(y+1,x+1)=DistEHT(i,3);
    end
    
    figure;
    imagesc(DistHole);
%    clim([0 3]);
%    colormap(customMapDesc);
    imageFilename=sprintf('%s-DistHol.png', filenameWOext);
    print(imageFilename,'-dpng');


    DistEET=importdata(filenameDistElec);
   if ~isempty(DistEET)
        sizeDistEET=size(DistEET);
        for i=1:sizeDistEET(1)
            x=DistEET(i,1);
            y=DistEET(i,2);
            DistElec(y+1,x+1)=DistEET(i,3);
        end
   end 
   
    figure;
    imagesc(DistElec);
%    clim([0 3]);
%    colormap(customMapDesc);
    imageFilename=sprintf('%s-DistElec.png', filenameWOext);
    print(imageFilename,'-dpng');


     figure;
    imagesc(DistElec);
%    clim([0 3]);
%    colormap(customMapDesc);
    imageFilename=sprintf('%s-DistElec.png', filenameWOext);
    print(imageFilename,'-dpng');

    figure;
    imagesc(phiAMorph);
%    clim([0 3]);
%    colormap(customMapDesc);
    imageFilename=sprintf('%s-phiA.png', filenameWOext);
    print(imageFilename,'-dpng');


    figure;
    imagesc(phiDMorph);
%    clim([0 3]);
%    colormap(customMapDesc);
    imageFilename=sprintf('%s-phiD.png', filenameWOext);
    print(imageFilename,'-dpng');

    close all;

end
