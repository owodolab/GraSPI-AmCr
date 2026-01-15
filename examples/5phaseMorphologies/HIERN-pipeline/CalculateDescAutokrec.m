function CalculateDescAuto(inputFile,NameFolderGraspi,NameWorkflowSave,NameFileSave,TimeStepChoice,hhh,numworkflow,PostParam)

%set(groot, 'DefaultFigureRenderer', 'painters');


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
    filenameWOext = extractBefore(filename, ".");


    Morph =  readmatrix([NameFolderGraspi 'calculateKrec/' filename],'NumHeaderLines',1);
    sizeMorph = size(Morph);
    imagesc(Morph(end:-1:1,:));
    colormap(customMap);
    caxis([0 7]);
    imageFilename=sprintf('%s-M.png' , filenameWOext);
    print([NameFolderGraspi 'calculateKrec/' imageFilename],'-dpng');
    pause(1)
    MorphDesc3=zeros(sizeMorph);
    CalcKrec=zeros(sizeMorph);

    filenameDesc3a=[filenameWOext '-IdsETmixed.txt'];
    filenameDesc3b=[filenameWOext '-IdsEETacceptor.txt'];
    filenameDesc3c=[filenameWOext +'-IdsEHTdonor.txt'];
    
    filenamePhiA=[filenameWOext '-phiA.txt'];
    filenamePhiD=[filenameWOext '-phiD.txt'];
    
    phiAMorph=importdata([NameFolderGraspi 'calculateKrec/' filenamePhiA ]);
    phiDMorph=importdata([NameFolderGraspi 'calculateKrec/' filenamePhiD ]);

    filenameEET=[filenameWOext '-IdsEET.txt'];
    filenameEHT=[filenameWOext '-IdsEHT.txt'];
   
    EET=importdata([NameFolderGraspi 'calculateKrec/' filenameEET]);
    EHT=importdata([NameFolderGraspi 'calculateKrec/' filenameEHT]);
    sizeEET=size(EET);
    sizeEHT=size(EHT);
%%% I added this for size consistency
MorphEET=zeros(sizeMorph);
MorphEHT=zeros(sizeMorph);

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

%         x_EET=EET(:,1);
%         y_EET=EET(:,2);
%         MorphEET(sub2ind([sizeEET(1) 2],y_EET+1,x_EET+1))=1;
%         
%         x_EHT=EHT(:,1);
%         y_EHT=EHT(:,2);
%         MorphEHT(sub2ind(sizeEHT,y_EHT+1,x_EHT+1))=1;


   countN2=0;
   sizeMorphEET=size(MorphEET);
   for ix=1:sizeMorphEET(1)
       for iy=1:sizeMorphEET(2)
           if ( (MorphEET(ix,iy) ==1) || MorphEHT(ix,iy) == 1)
               countN2=countN2+1;
           end
       end
   end

    
    D3a=importdata([NameFolderGraspi 'calculateKrec/' filenameDesc3a]);
    sizeD3a=size(D3a);
    for i=1:sizeD3a(1)
        x=D3a(i,1);
        y=D3a(i,2);
        color=D3a(i,4);
        MorphDesc3(y+1,x+1)=2;
    end

    D3b=importdata([NameFolderGraspi 'calculateKrec/' filenameDesc3b]);
    sizeD3b=size(D3b);
    for i=1:sizeD3b(1)
        x=D3b(i,1);
        y=D3b(i,2);
        color=D3b(i,4);
        MorphDesc3(y+1,x+1)=1;
    end

    D3c=importdata([NameFolderGraspi 'calculateKrec/' filenameDesc3c]);
    sizeD3c=size(D3c);
    for i=1:sizeD3c(1)
        x=D3c(i,1);
        y=D3c(i,2);
        color=D3c(i,4);
        MorphDesc3(y+1,x+1)=3;
    end


    krecDesc=0;
    for ix=1:sizeMorph(1)
        for iy=1:sizeMorph(2)
            if (MorphDesc3(ix,iy) ~=0)
                CalcKrec(ix,iy)=phiAMorph(ix,iy)*phiDMorph(ix,iy);
                krecDesc=krecDesc+CalcKrec(ix,iy);
            end
        end
    end
    

    
    filenameDesc=sprintf('descKrec-%s',filename);
    fileID = fopen([NameFolderGraspi 'calculateKrec/' filenameDesc], 'w');
    fprintf(fileID, '%f\n', 4*krecDesc/countN2);
    fclose(fileID);
    

    
    figure;
%     imagesc(CalcKrec(end:-1:1,:));
%    caxis([0 1]);
%    colormap(customMapDesc);
     colormap([[1 1 1];jet(100)]);
    CalcKrecFinal=4*CalcKrec;
    IndCRETP=find(MorphDesc3==0);
    IndEHT = find(MorphEHT==1);
    IndEET = find(MorphEET==1);
    krecDescPlot=-1*ones(size(CalcKrecFinal));
    krecDescPlot(IndEHT)=CalcKrecFinal(IndEHT);
    krecDescPlot(IndEET)=CalcKrecFinal(IndEET);
%     krecDescPlot=CalcKrecFinal;
%     krecDescPlot(IndCRETP)=-1;
    Zpad = [krecDescPlot; krecDescPlot(end,:)];         % Repeat last row
    Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
    [a,b]=size(krecDescPlot);
    x = 0:a;   % 21 x-coordinates
    y = 0:b;   % 11 y-coordinates
    [X, Y] = meshgrid(x, y);
    surf(X,Y,Zpad','EdgeColor','none')
    view(90,270)
    axis equal tight
    caxis([-0.01 1]);
    xlabel('z [nm]')
    ylabel('x [nm]')
    colorbar;
    imageFilename=sprintf('_7%s_krec', filenameWOext);
    
    print([NameWorkflowSave imageFilename],'-dpng');
    savefig([NameWorkflowSave imageFilename '.fig'])
    
    
    
    close all;
    save([NameWorkflowSave 'Recomb.mat'],'CalcKrecFinal')
end
