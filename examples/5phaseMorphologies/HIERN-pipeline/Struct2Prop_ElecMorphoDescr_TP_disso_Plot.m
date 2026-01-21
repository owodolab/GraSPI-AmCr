function [ status ] = Struct2Prop_ElecMorphoDescr_TP_disso_Plot( inputFile, NameWorkflowSave, NameFolderGraspi, Morph, MorphDesc3, MorphEET, MorphEHT, DistHole, DistElec, DissoEfficiency )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Names of the file
% ---------------------------------------------

filename = inputFile;
filenameWOext = extractBefore(filename, ".");

% ---------------------------------------------
% Colormaps
% ---------------------------------------------

% For the different phases
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
    255/255 197/255 203/255];    % 1- Red (top)

customEET = [1 1 1;    % 0- White
    0 141/255 171/255];    % 1- Blue (bottom)

% ---------------------------------------------
% Image of the phase type
% ---------------------------------------------

imagesc(Morph);
colormap(customMap);
caxis([0 7]);
imageFilename=sprintf('%s-M.png', filenameWOext);
print([NameFolderGraspi 'visualMorph2/' imageFilename],'-dpng');

% ---------------------------------------------
% Image of region common to both effective transport phases (CETP)
% ---------------------------------------------
% Sure about that???

figure;
%     hIm=imagesc(0.5:1:x+0.5,0.5:1:y-0.5,MorphDesc3);
Zpad = [MorphDesc3; MorphDesc3(end,:)];         % Repeat last row
Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
[a,b]=size(MorphDesc3);
x = 0:a;   % 21 x-coordinates
y = 0:b;   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
%     caxis([0 3]);
caxis([0 1]);
xlabel('z [nm]')
ylabel('x [nm]')
myColors = [
    1 1 1;         % 0 white
    153/255 153/255 255/255      % non-zero purple
    ];
colormap(myColors)
%     colormap(customMapDesc);
%     colorbar
imageFilename=sprintf('_4_%s_CETP.png', filenameWOext);
print([NameWorkflowSave imageFilename],'-dpng');
savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])

pause(1);

% ---------------------------------------------
% Image of effective electron transport phases (EETP)
% ---------------------------------------------

figure;
%     hIm=imagesc(MorphEET(end:-1:1,:));
Zpad = [MorphEET; MorphEET(end,:)];         % Repeat last row
Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
[a,b]=size(MorphEET);
x = 0:a;   % 21 x-coordinates
y = 0:b;   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 1]);
xlabel('z [nm]')
ylabel('x [nm]')
colormap(customEET);
imageFilename=sprintf('_5_%s_EETP.png', filenameWOext);
print([NameWorkflowSave imageFilename],'-dpng');
savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])

pause(1);

% ---------------------------------------------
% Image of effective hole transport phases (EETP)
% ---------------------------------------------

figure;
%     hIm=imagesc(MorphEHT(end:-1:1,:));
Zpad = [MorphEHT; MorphEHT(end,:)];         % Repeat last row
Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
[a,b]=size(MorphEHT);
x = 0:a;   % 21 x-coordinates
y = 0:b;   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 1]);
xlabel('z [nm]')
ylabel('x [nm]')
colormap(customEHT);
imageFilename=sprintf('_6_%s_EHTP.png', filenameWOext);
print([NameWorkflowSave imageFilename],'-dpng');
savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])

pause(1);

% ---------------------------------------------
% Image of distance between exciton and EHTP
% ---------------------------------------------

figure;
%     hIm=imagesc(DistHole(end:-1:1,:));
Zpad = [DistHole; DistHole(end,:)];         % Repeat last row
Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
[a,b]=size(DistHole);
x = 0:a;   % 21 x-coordinates
y = 0:b;   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 20]);
%     colormap(customMapDesc);
xlabel('z [nm]')
ylabel('x [nm]')
colorbar
colormap(jet(21));
imageFilename=sprintf('_7_%s_DistHol.png', filenameWOext);
print([NameWorkflowSave imageFilename],'-dpng');
savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])

pause(1);

% ---------------------------------------------
% Image of distance between exciton and EETP
% ---------------------------------------------

figure;
%    hIm=imagesc(DistElec);
Zpad = [DistElec; DistElec(end,:)];         % Repeat last row
Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
[a,b]=size(DistElec);
x = 0:a;   % 21 x-coordinates
y = 0:b;   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 20]);
colorbar
%    colormap(customMapDesc);
colormap(jet(100));
xlabel('z [nm]')
ylabel('x [nm]')
imageFilename=sprintf('_8_%s_DistElec.png', filenameWOext);
print([NameWorkflowSave imageFilename],'-dpng');
savefig([NameWorkflowSave imageFilename(1:end-4) '.fig'])

pause(1);

% ---------------------------------------------
% Image of exciton diffusion efficiency
% ---------------------------------------------

figure;
%    hIm=imagesc(DistElec);
Zpad = [DissoEfficiency; DissoEfficiency(end,:)];         % Repeat last row
Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
[a,b]=size(DissoEfficiency);
x = 0:a;   % 21 x-coordinates
y = 0:b;   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
surf(X,Y,Zpad','EdgeColor','none');
view(90,270)
axis equal tight
caxis([-0.01 1]);
colorbar
%    colormap(customMapDesc);
xlabel('z [nm]')
ylabel('x [nm]')
colormap([ [1 1 1]; jet(121)]);
imageFilename=sprintf('_9_%s_DissoEfficiency.png', filenameWOext);
print([NameWorkflowSave imageFilename],'-dpng');
savefig([NameWorkflowSave  imageFilename(1:end-4) '.fig'])

pause(1);

close all;

status = 1;

end

