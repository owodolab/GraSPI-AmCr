function [ krecDescFinal, CalcKrecFinal, krecDescPlot ] = CalculateDescAutokrec( inputFile, NameFolderGraspi, PostParam)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data and define filenames
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Names of the files (Graspi output) with the data we need
% ---------------------------------------------

filename = inputFile;
filenameWOext = extractBefore(filename, ".");

filenameDesc3a=[filenameWOext '-IdsETmixed.txt'];
filenameDesc3b=[filenameWOext '-IdsEETacceptor.txt'];
filenameDesc3c=[filenameWOext +'-IdsEHTdonor.txt'];

filenamePhiA=[filenameWOext '-phiA.txt'];
filenamePhiD=[filenameWOext '-phiD.txt'];

filenameEHT=[filenameWOext '-IdsEHT.txt'];
filenameEET=[filenameWOext '-IdsEET.txt'];

% ---------------------------------------------
% Load data
% ---------------------------------------------

% Morph =  readmatrix([NameFolderGraspi 'calculateKrec/' filename],'NumHeaderLines',1);
% sizeMorph = size(Morph);

phiAMorph=importdata([NameFolderGraspi 'calculateKrec/' filenamePhiA ]);
phiDMorph=importdata([NameFolderGraspi 'calculateKrec/' filenamePhiD ]);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matrices characterizing the different fields
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Matrix initialization
% ---------------------------------------------

MorphDesc3=zeros(sizeMorph);
CalcKrec=zeros(sizeMorph);
MorphEET=zeros(sizeMorph);
MorphEHT=zeros(sizeMorph);

% ---------------------------------------------
% Calculation: preparation
% ---------------------------------------------
% NB: part of this has already been done!!!

% EET=importdata([NameFolderGraspi 'calculateKrec/' filenameEET]);
% sizeEET=size(EET);
% for i=1:sizeEET(1)
%     x=EET(i,1);
%     y=EET(i,2);
%     color=EET(i,3);
%     MorphEET(y+1,x+1)=1;
% end
% 
% EHT=importdata([NameFolderGraspi 'calculateKrec/' filenameEHT]);
% sizeEHT=size(EHT);
% for i=1:sizeEHT(1)
%     x=EHT(i,1);
%     y=EHT(i,2);
%     color=EHT(i,3);
%     MorphEHT(y+1,x+1)=1;
% end

countN2=0;
sizeMorphEET=size(MorphEET);
for ix=1:sizeMorphEET(1)
    for iy=1:sizeMorphEET(2)
        if ( (MorphEET(ix,iy) ==1) || MorphEHT(ix,iy) == 1)
            countN2=countN2+1;
        end
    end
end

% % This is the same as DETmixed in VisualizeAllMorphAuto
% D3a=importdata([NameFolderGraspi 'calculateKrec/' filenameDesc3a]);
% sizeD3a=size(D3a);
% for i=1:sizeD3a(1)
%     x=D3a(i,1);
%     y=D3a(i,2);
%     color=D3a(i,4);
%     MorphDesc3(y+1,x+1)=2;
% end
% 
% % This is the same as DEETacceptor in VisualizeAllMorphAuto
% D3b=importdata([NameFolderGraspi 'calculateKrec/' filenameDesc3b]);
% sizeD3b=size(D3b);
% for i=1:sizeD3b(1)
%     x=D3b(i,1);
%     y=D3b(i,2);
%     color=D3b(i,4);
%     MorphDesc3(y+1,x+1)=1;
% end
% 
% % This is the same as DEHTdonor in VisualizeAllMorphAuto
% D3c=importdata([NameFolderGraspi 'calculateKrec/' filenameDesc3c]);
% sizeD3c=size(D3c);
% for i=1:sizeD3c(1)
%     x=D3c(i,1);
%     y=D3c(i,2);
%     color=D3c(i,4);
%     MorphDesc3(y+1,x+1)=3;
% end

% ---------------------------------------------
% Calculation: bimolecular recombination prefactor
% ---------------------------------------------

krecDesc=0;
for ix=1:sizeMorph(1)
    for iy=1:sizeMorph(2)
        if (MorphDesc3(ix,iy) ~=0)
            CalcKrec(ix,iy)=phiAMorph(ix,iy)*phiDMorph(ix,iy);
            krecDesc=krecDesc+CalcKrec(ix,iy);
        end
    end
end
CalcKrecFinal=4*CalcKrec;
krecDescFinal = 4*krecDesc/countN2;

% Associated fields for plots
krecDescPlot=-1*ones(size(CalcKrecFinal));
IndEHT = find(MorphEHT==1);
IndEET = find(MorphEET==1);
krecDescPlot(IndEHT)=CalcKrecFinal(IndEHT);
krecDescPlot(IndEET)=CalcKrecFinal(IndEET);

% ---------------------------------------------
% Write results in a file
% ---------------------------------------------

filenameDesc=sprintf('descKrec-%s',filename);
fileID = fopen([NameFolderGraspi 'calculateKrec/' filenameDesc], 'w');
fprintf(fileID, '%f\n', krecDescFinal);
fclose(fileID);

end
