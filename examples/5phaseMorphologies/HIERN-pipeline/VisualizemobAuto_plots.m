function [ status ] = VisualizemobAuto_plots( inputFile, NameWorkflowSave, NameFolderGraspi, Morph, MobEHT, IndEHT, MobEET, IndEET )
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

imagesc(Morph(end:-1:1,:));
colormap(customMap);
caxis([0 7]);
imageFilename=sprintf('%s-M.png' , filenameWOext);
print([NameFolderGraspi 'calculateKrec/' imageFilename],'-dpng');
pause(1)

% ---------------------------------------------
% Figures of local hole mobility
% ---------------------------------------------

figure;
%     imagesc(MobEHT(end:-1:1,:));
Mobplot=-1*ones(size(MobEHT));
Mobplot(IndEHT)=MobEHT(IndEHT);
Zpad = [Mobplot; Mobplot(end,:)];         % Repeat last row
Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
[a,b]=size(MobEHT);
x = 0:a;   % 21 x-coordinates
y = 0:b;   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
%     axis ([0.5:10.5 0.5 20.5])
caxis([-0.01 1]);
%    colormap(customMapDesc);
colormap([ [1 1 1] ;jet(100)]);
colorbar;
xlabel('z [nm]')
ylabel('x [nm]')

imageFilename=sprintf('_8%s_MobilityEHT', filenameWOext);
print([NameWorkflowSave imageFilename],'-dpng');
savefig([NameWorkflowSave imageFilename '.fig'])

pause(1)

% ---------------------------------------------
% Figures of local electron mobility
% ---------------------------------------------

figure;
Mobplot=-1*ones(size(MobEET));
Mobplot(IndEET)=MobEET(IndEET);
%     imagesc(MobEET(end:-1:1,:));
Zpad = [Mobplot; Mobplot(end,:)];         % Repeat last row
Zpad = [Zpad, Zpad(:,end)];             % Repeat last column
[a,b]=size(Mobplot);
x = 0:a;   % 21 x-coordinates
y = 0:b;   % 11 y-coordinates
[X, Y] = meshgrid(x, y);
surf(X,Y,Zpad','EdgeColor','none')
view(90,270)
axis equal tight
caxis([-0.01 1]);
colorbar;
xlabel('z [nm]')
ylabel('x [nm]')
colormap([ [1 1 1] ;jet(100)]);

imageFilename=sprintf('_9%s_MobilityEET', filenameWOext);
print([NameWorkflowSave imageFilename],'-dpng');
savefig([NameWorkflowSave imageFilename '.fig'])

pause(1)

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

