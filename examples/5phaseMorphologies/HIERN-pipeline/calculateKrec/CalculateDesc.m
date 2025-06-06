clear;

%set(groot, 'DefaultFigureRenderer', 'painters');


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

    MorphDesc3=zeros(sizeMorph);
    CalcKrec=zeros(sizeMorph);

    filenameDesc3a=convertCharsToStrings(filenameWOext)+'-IdsETmixed.txt';
    filenameDesc3b=convertCharsToStrings(filenameWOext)+'-IdsEETacceptor.txt';
    filenameDesc3c=convertCharsToStrings(filenameWOext)+'-IdsEHTdonor.txt';
    
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

   countN2=0;
   sizeMorphEET=size(MorphEET);
   for ix=1:sizeMorphEET(1)
       for iy=1:sizeMorphEET(2)
           if ( (MorphEET(ix,iy) ==1) || MorphEHT(ix,iy) == 1)
               countN2=countN2+1;
           end
       end
   end

    
    D3a=importdata(filenameDesc3a);
    sizeD3a=size(D3a);
    for i=1:sizeD3a(1)
        x=D3a(i,1);
        y=D3a(i,2);
        color=D3a(i,4);
        MorphDesc3(y+1,x+1)=2;
    end

    D3b=importdata(filenameDesc3b);
    sizeD3b=size(D3b);
    for i=1:sizeD3b(1)
        x=D3b(i,1);
        y=D3b(i,2);
        color=D3b(i,4);
        MorphDesc3(y+1,x+1)=1;
    end

    D3c=importdata(filenameDesc3c);
    sizeD3c=size(D3c);
    for i=1:sizeD3c(1)
        x=D3c(i,1);
        y=D3c(i,2);
        color=D3c(i,4);
        MorphDesc3(y+1,x+1)=3;
    end


    krecDesc=0;
    for ix=1:sizeMorph(1);
        for iy=1:sizeMorph(2);
            if (MorphDesc3(ix,iy) ~=0)
                CalcKrec(ix,iy)=phiAMorph(ix,iy)*phiDMorph(ix,iy);
                krecDesc=krecDesc+CalcKrec(ix,iy);
            end
        end
    end

    
    figure;
    imagesc(CalcKrec);
%    clim([0 1]);
%    colormap(customMapDesc);
    colorbar;
    imageFilename=sprintf('%s-krec.png', filenameWOext);
    print(imageFilename,'-dpng');

    filenameDesc=sprintf('descKrec-%s',filename);
    fileID = fopen(filenameDesc, 'w');
    fprintf(fileID, '%f\n', 4*krecDesc/countN2);
    fclose(fileID);

    close all;
end
