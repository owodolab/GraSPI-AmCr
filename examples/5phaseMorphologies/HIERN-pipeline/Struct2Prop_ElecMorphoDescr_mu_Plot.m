function [ status ] = Struct2Prop_ElecMorphoDescr_mu_Plot( inputFile, NameWorkflowSave, NameFolderGraspi, Morph, MobEHT, IndEHT, MobEET, IndEET )
%UNTITLED Summary of this function goes here
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

% ---------------------------------------------
% Image of the phase type
% ---------------------------------------------

% imagesc(Morph(end:-1:1,:));
% colormap(customMap);
% caxis([0 7]);
% imageFilename=sprintf('%s-M.png' , filenameWOext);
% print([NameFolderGraspi 'calculateKrec/' imageFilename],'-dpng');
% pause(1)

nxyz = zeros(3,1);
[nxyz(1),nxyz(3)]=size(MobEHT);
x = 0:nxyz(1);   % 21 x-coordinates
y = 0:nxyz(3);   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
Zpad = zeros(nxyz(1)+1,nxyz(3)+1);

% ---------------------------------------------
% Figures of local hole mobility
% ---------------------------------------------

Mobplot=-1*ones(size(MobEHT));
Mobplot(IndEHT)=MobEHT(IndEHT);
Variable=reshape(Mobplot,nxyz(1),nxyz(3));
Zpad(1:end-1,1:end-1) = Variable;
Zpad(end,1:end-1) = Variable(end,:);         % Repeat last row
Zpad(:,end) = Zpad(:,end-1);        % Repeat last column

figure;hold on;grid off;box on
surf(X,Y,Zpad','EdgeColor','none')
axis equal
axis([0 nxyz(1) 0 nxyz(3)])
% axis equal tight
view(90,270)
% caxis([-0.01 1]);
colormap([ [1 1 1] ;jet(100)]);
colorbar;
set(gca,'colorscale','log')
caxis([1e-4 1])
xlabel('z [nm]')
ylabel('x [nm]')

imageFilename=sprintf('_13_%s_MobHole', filenameWOext);
hgsave([NameWorkflowSave imageFilename])
print([NameWorkflowSave imageFilename],'-dpng');

pause(0.2);

% ---------------------------------------------
% Figures of local electron mobility
% ---------------------------------------------

Mobplot=-1*ones(size(MobEET));
Mobplot(IndEET)=MobEET(IndEET);
Variable=reshape(Mobplot,nxyz(1),nxyz(3));
Zpad(1:end-1,1:end-1) = Variable;
Zpad(end,1:end-1) = Variable(end,:);         % Repeat last row
Zpad(:,end) = Zpad(:,end-1);        % Repeat last column

figure;hold on;grid off;box on
surf(X,Y,Zpad','EdgeColor','none')
axis equal
axis([0 nxyz(1) 0 nxyz(3)])
% axis equal tight
view(90,270)
% caxis([-0.01 1]);
colormap([ [1 1 1] ;jet(100)]);
colorbar;
set(gca,'colorscale','log')
caxis([1e-4 1])
xlabel('z [nm]')
ylabel('x [nm]')

imageFilename=sprintf('_14_%s_MobElec', filenameWOext);
hgsave([NameWorkflowSave imageFilename])
print([NameWorkflowSave imageFilename],'-dpng');

pause(0.2);

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

close all;

status = 1;

end

