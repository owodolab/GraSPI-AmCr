function [ status ] = Struct2Prop_ElecMorphoDescr_TP_disso_Plot( inputFile, NameWorkflowSave, NameFolderGraspi, Morph, MorphDesc3, MorphEET, MorphEHT, IndEET, IndEHT, DistHole, DistElec, DissoEfficiency )
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

customIslands = [1 1 1;    % 0- White
    0 0 0];    % 1- Black (bottom)

% ---------------------------------------------
% Image of the phase type
% ---------------------------------------------

% imagesc(Morph);
% colormap(customMap);
% caxis([0 7]);
% imageFilename=sprintf('%s-M.png', filenameWOext);
% print([NameFolderGraspi 'visualMorph2/' imageFilename],'-dpng');

nxyz = zeros(3,1);
[nxyz(1),nxyz(3)]=size(MorphDesc3);
x = 0:nxyz(1);   % 21 x-coordinates
y = 0:nxyz(3);   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
Zpad = zeros(nxyz(1)+1,nxyz(3)+1);

% ---------------------------------------------
% Image of region common to both effective transport phases (CETP)
% ---------------------------------------------
% Sure about that???

myColors = [
    1 1 1;         % 0 white
    153/255 153/255 255/255      % non-zero purple
    ];

Variable=reshape(MorphDesc3,nxyz(1),nxyz(3));
Zpad(1:end-1,1:end-1) = Variable;
Zpad(end,1:end-1) = Variable(end,:);         % Repeat last row
Zpad(:,end) = Zpad(:,end-1);        % Repeat last column

figure;
set(gcf,'Color','w')
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 1]);
xlabel('z [nm]')
ylabel('x [nm]')
colormap(myColors)

imageFilename = sprintf('_4_%s_CETP', filenameWOext);
hgsave([NameWorkflowSave imageFilename])
print([NameWorkflowSave imageFilename],'-dpng');

pause(0.2);

% ---------------------------------------------
% Image of effective electron transport phases (EETP)
% ---------------------------------------------

Variable=reshape(MorphEET,nxyz(1),nxyz(3));
Zpad(1:end-1,1:end-1) = Variable;
Zpad(end,1:end-1) = Variable(end,:);         % Repeat last row
Zpad(:,end) = Zpad(:,end-1);        % Repeat last column

figure;
set(gcf,'Color','w')
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 1]);
xlabel('z [nm]')
ylabel('x [nm]')
colormap(customEET);

imageFilename=sprintf('_5_%s_EETP', filenameWOext);
hgsave([NameWorkflowSave imageFilename])
print([NameWorkflowSave imageFilename],'-dpng');

pause(0.2);

% ---------------------------------------------
% Image of effective hole transport phases (EETP)
% ---------------------------------------------

Variable=reshape(MorphEHT,nxyz(1),nxyz(3));
Zpad(1:end-1,1:end-1) = Variable;
Zpad(end,1:end-1) = Variable(end,:);         % Repeat last row
Zpad(:,end) = Zpad(:,end-1);        % Repeat last column

figure;
set(gcf,'Color','w')
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 1]);
xlabel('z [nm]')
ylabel('x [nm]')
colormap(customEHT);
imageFilename=sprintf('_6_%s_EHTP', filenameWOext);
hgsave([NameWorkflowSave imageFilename])
print([NameWorkflowSave imageFilename],'-dpng');

pause(0.2);

% ---------------------------------------------
% Image of lost islands (neither EETP nor EHTP)
% ---------------------------------------------

Islands = ones(size(MorphEHT));
Islands(IndEHT) = 0;
Islands(IndEET) = 0;
IndIslands = find(Islands==1);
Variable=reshape(Islands,nxyz(1),nxyz(3));
Zpad(1:end-1,1:end-1) = Variable;
Zpad(end,1:end-1) = Variable(end,:);         % Repeat last row
Zpad(:,end) = Zpad(:,end-1);        % Repeat last column

figure;
set(gcf,'Color','w')
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 1]);
xlabel('z [nm]')
ylabel('x [nm]')
colormap(customIslands);
imageFilename=sprintf('_6_%s_LostIslands', filenameWOext);
hgsave([NameWorkflowSave imageFilename])
print([NameWorkflowSave imageFilename],'-dpng');

pause(0.2);

% ---------------------------------------------
% Image of distance between exciton and EHTP
% ---------------------------------------------

DistHole(IndIslands) = nan;
Variable=reshape(DistHole,nxyz(1),nxyz(3));
Zpad(1:end-1,1:end-1) = Variable;
Zpad(end,1:end-1) = Variable(end,:);         % Repeat last row
Zpad(:,end) = Zpad(:,end-1);        % Repeat last column

figure;
set(gcf,'Color','w')
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 35]);
xlabel('z [nm]')
ylabel('x [nm]')
colorbar
% colormap(jet);
imageFilename=sprintf('_7_%s_DistHol', filenameWOext);
hgsave([NameWorkflowSave imageFilename])
print([NameWorkflowSave imageFilename],'-dpng');

pause(0.2);

% ---------------------------------------------
% Image of distance between exciton and EETP
% ---------------------------------------------

DistElec(IndIslands) = nan;
Variable=reshape(DistElec,nxyz(1),nxyz(3));
Zpad(1:end-1,1:end-1) = Variable;
Zpad(end,1:end-1) = Variable(end,:);         % Repeat last row
Zpad(:,end) = Zpad(:,end-1);        % Repeat last column

figure;
set(gcf,'Color','w')
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([0 20]);
colorbar
colormap(feval('jet'));
xlabel('z [nm]')
ylabel('x [nm]')

imageFilename=sprintf('_8_%s_DistElec', filenameWOext);
hgsave([NameWorkflowSave imageFilename])
print([NameWorkflowSave imageFilename],'-dpng');

pause(0.2);

% ---------------------------------------------
% Image of exciton diffusion efficiency
% ---------------------------------------------

Variable=reshape(DissoEfficiency,nxyz(1),nxyz(3));
Zpad(1:end-1,1:end-1) = Variable;
Zpad(end,1:end-1) = Variable(end,:);         % Repeat last row
Zpad(:,end) = Zpad(:,end-1);        % Repeat last column

figure;
set(gcf,'Color','w')

surf(X,Y,Zpad','EdgeColor','none');
view(90,270)
axis equal tight
caxis([-0.01 1]);
colorbar
xlabel('z [nm]')
ylabel('x [nm]')
% colormap([ [1 1 1]; jet(121)]);

imageFilename=sprintf('_9_%s_DissoEfficiency', filenameWOext);
hgsave([NameWorkflowSave imageFilename])
print([NameWorkflowSave imageFilename],'-dpng');

pause(0.2);

close all;

status = 1;

end

