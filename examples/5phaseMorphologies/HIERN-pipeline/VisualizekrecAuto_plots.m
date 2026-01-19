function [ status ] = VisualizekrecAuto_plots( inputFile, NameWorkflowSave, NameFolderGraspi, Morph, krecDescPlot )
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
% Bimolecular recombination prefactor
% ---------------------------------------------

figure;
colormap([[1 1 1];jet(100)]);
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

status = 1;

end

