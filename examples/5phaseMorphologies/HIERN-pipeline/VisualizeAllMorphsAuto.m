function [ Morph, MorphDesc, MorphEET, MorphEHT, DistHole, DistElec, DissoEfficiency ] = VisualizeAllMorphsAuto( inputFile, NameFolderGraspi, PostParam )

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data and define filenames
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Names of the files (Graspi output) with the data we need
% ---------------------------------------------

filename = inputFile;
filenameWOext = extractBefore(filename, ".");

filenameDescETmixed=[filenameWOext  '-IdsETmixed.txt'];
filenameDescEETacceptor=[filenameWOext  '-IdsEETacceptor.txt'];
filenameDescEHTdonor=[filenameWOext '-IdsEHTdonor.txt'];
filenameDescEHT=[filenameWOext '-IdsEHT.txt'];
filenameDescEET=[filenameWOext '-IdsEET.txt'];

filenameDistHole=[filenameWOext '-DistancesBlackOrangeGreyToGREEN.txt'];
filenameDistElec=[filenameWOext '-DistancesWhiteYellowGreyToGREEN.txt'];

filenamePhiA=[filenameWOext '-phiA.txt'];
filenamePhiD=[filenameWOext '-phiD.txt'];

% ---------------------------------------------
% Load data
% ---------------------------------------------

Morph =  readmatrix([NameFolderGraspi 'visualMorph2/' filename],'NumHeaderLines',1);
sizeMorph = size(Morph);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matrices characterizing the different fields
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Matrix initialization
% ---------------------------------------------

MorphDesc=zeros(sizeMorph);
MorphDistHole=zeros(sizeMorph);
MorphDistElec=zeros(sizeMorph);
MorphEET=zeros(sizeMorph);
MorphEHT=zeros(sizeMorph);
DistHole=zeros(sizeMorph);
DistElec=zeros(sizeMorph);

% ---------------------------------------------
% Phase type matrix
% ---------------------------------------------

% This is the ?mixed part of the CETP
DETmixed=importdata([NameFolderGraspi 'visualMorph2/' filenameDescETmixed]);
if ~isempty(DETmixed)
    sizeDETmixed=size(DETmixed);
    %         for i=1:DETmixed(1)
    for i=1:sizeDETmixed(1) % Yasin: I corrected the above line by this one
        x=DETmixed(i,1);
        y=DETmixed(i,2);
        color=DETmixed(i,4);
        MorphDesc(y+1,x+1)=2;
    end
end

% This is the part of the effective electron transport phase in the acceptor phases?
DEETacceptor=importdata([NameFolderGraspi 'visualMorph2/' filenameDescEETacceptor]);
if ~isempty(DEETacceptor)
    sizeDEETacceptor=size(DEETacceptor);
    for i=1:sizeDEETacceptor(1)
        x=DEETacceptor(i,1);
        y=DEETacceptor(i,2);
        color=DEETacceptor(i,4);
        MorphDesc(y+1,x+1)=1;
    end
end

% This is the part of the effective hole transport phase in the donor phases?
DEHTdonor=importdata([NameFolderGraspi 'visualMorph2/' filenameDescEHTdonor]);
if ~isempty(DEHTdonor)
    sizeDEHTdonor=size(DEHTdonor);
    for i=1:sizeDEHTdonor(1)
        x=DEHTdonor(i,1);
        y=DEHTdonor(i,2);
        color=DEHTdonor(i,4);
        MorphDesc(y+1,x+1)=3;
    end
end

% ---------------------------------------------
% EETP and EHTP
% ---------------------------------------------

% This is the effective electron transport phase
EET=importdata([NameFolderGraspi 'visualMorph2/' filenameDescEET]);
if ~isempty(EET)
    sizeEET=size(EET);
    for i=1:sizeEET(1)
        x=EET(i,1);
        y=EET(i,2);
        color=EET(i,3);
        MorphEET(y+1,x+1)=1;
    end
end

% This is the effective hole transport phase
EHT=importdata([NameFolderGraspi 'visualMorph2/' filenameDescEHT]);
if ~isempty(EHT)
    sizeEHT=size(EHT);
    for i=1:sizeEHT(1)
        x=EHT(i,1);
        y=EHT(i,2);
        color=EHT(i,3);
        MorphEHT(y+1,x+1)=1;
    end
end

% ---------------------------------------------
% Distances to EETP and EHTP for electrons and holes
% ---------------------------------------------

DistEHT=importdata([NameFolderGraspi 'visualMorph2/' filenameDistHole]);
if ~isempty(DistEHT)
    sizeDistEHT=size(DistEHT);
    for i=1:sizeDistEHT(1)
        x=DistEHT(i,1);
        y=DistEHT(i,2);
        DistHole(y+1,x+1)=DistEHT(i,3);
    end
end

DistEET=importdata([NameFolderGraspi 'visualMorph2/' filenameDistElec]);
if ~isempty(DistEET)
    sizeDistEET=size(DistEET);
    for i=1:sizeDistEET(1)
        x=DistEET(i,1);
        y=DistEET(i,2);
        DistElec(y+1,x+1)=DistEET(i,3);
    end
end

% ---------------------------------------------
% Exciton diffusion efficiency
% ---------------------------------------------

IndEETP=find(MorphEET==1);
IndEHTP=find(MorphEHT==1);
Induseful=find(MorphDesc~=0);

% DissoEfficiency =-1*ones(length(MorphEHT(:,1)),length(MorphEHT(1,:)));
DissoEfficiency =-1*ones(sizeMorph);

IndCRETP=find(MorphDesc==2); % finds the nodes in the Common region to effective transport phases (CRETP)
% IndAcceptor=find((Morph == 1 ) | (Morph == 7 )); % finds the acceptor phase
% IndDonor=find((Morph == 1 ) | (Morph == 7 )); % finds the donor phase
IndAcceptornoETP=find(((Morph == 1 ) | (Morph == 7 )) & (MorphEET==0)); %finds acceptor phase outside EETP (Electron effective transport phase)
IndDonornoETP=find(((Morph == 0 ) | (Morph == 5 ) ) & (MorphEHT==0));  %finds donor phase outside EHTP (Hole  effective transport phase)
IndmixednoETP=find(((Morph == 3 ) | (MorphEET == 0 ) ) & (MorphEHT==0)); % finds mixed phase outside both effective transport phases (EHTP and EETP)

DissoEfficiency(IndEHTP)=exp(-DistHole(IndEHTP)/PostParam.Ld(1));
DissoEfficiency(IndEETP)=exp(-DistElec(IndEETP)/PostParam.Ld(2));
DissoEfficiency(IndCRETP)=1;

DissoEfficiency(IndAcceptornoETP)=0;
DissoEfficiency(IndDonornoETP)=0;
DissoEfficiency(IndmixednoETP)=0;

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
% %     hIm=imagesc(0.5:1:x+0.5,0.5:1:y-0.5,MorphDesc);
% Zpad = [MorphDesc; MorphDesc(end,:)];         % Repeat last row
% Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
% [a,b]=size(MorphDesc);
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