function [ status ] = Struct2Prop_ElecMorphoDescr_Morpho2Graspi( NameFolderGraspi, NameWorkflowSave, numworkflow, NameMorpho, PostParam, Inputs )

% -------------------------------------------------------------------------
% Load File
% -------------------------------------------------------------------------

load([NameWorkflowSave NameMorpho '_MorphoPreProc']);

NameFileWoExt = [NameMorpho '_wf_' num2str(numworkflow)];

MorphFileName = sprintf('%s.txt',NameFileWoExt);
PhiDFileName = sprintf('%s-phiD.txt',NameFileWoExt);
PhiAFileName = sprintf('%s-phiA.txt',NameFileWoExt);

% -------------------------------------------------------------------------
% Relabelling
% -------------------------------------------------------------------------

nxyz = MorphoPreProc.nxyz;
FlagBC = Inputs.Mesh.FlagBC;
LabelsImg=reshape(MorphoPreProc.PhaseType,nxyz(1),nxyz(3));
[row,col] = find(LabelsImg==0);

height=min(col);
if isempty(col)
    height=max(nxyz(3));
end
width=nxyz(1);

%need to remap the labels
% 1 -> 5
% 3 -> 0
% 5 -> 3
% 4 -> 1
% 2 -> 7

Img2relabel=LabelsImg(:,1:height);
Img2save=LabelsImg(:,1:height);
for i=1:size(Img2save,1)
    for j=1:size(Img2save,2)
        if (Img2relabel(i,j)==1) Img2save(i,j)=5; end;
        if (Img2relabel(i,j)==1) Img2save(i,j)=5; end;
        if (Img2relabel(i,j)==3) Img2save(i,j)=0; end;
        if (Img2relabel(i,j)==5) Img2save(i,j)=3; end;
        if (Img2relabel(i,j)==4) Img2save(i,j)=1; end;
        if (Img2relabel(i,j)==2) Img2save(i,j)=7; end;
    end
end

% -------------------------------------------------------------------------
% Write files
% -------------------------------------------------------------------------

fileID = fopen([NameFolderGraspi 'descriptors/' MorphFileName],'w');
fprintf(fileID,'%d %d \n',width,height);
fprintf(fileID, [repmat('%d ', 1, size(Img2save,1)) '\n'], Img2save) ;
fclose(fileID);


phiDMorph=reshape(MorphoPreProc.PreProFields(:,1),nxyz(1),nxyz(3));
phiDMorphcrop=phiDMorph(:,1:height);
fileIDphiD = fopen([NameFolderGraspi 'descriptors/' PhiDFileName],'w');
fprintf(fileIDphiD, [repmat('%d ', 1, size(phiDMorphcrop,1)) '\n'], phiDMorphcrop) ;
fclose(fileIDphiD);

phiAMorph=reshape(MorphoPreProc.PreProFields(:,2),nxyz(1),nxyz(3));
phiAMorphcrop=phiAMorph(:,1:height);
fileIDphiA = fopen([NameFolderGraspi 'descriptors/' PhiAFileName],'w');
fprintf(fileIDphiA, [repmat('%d ', 1, size(phiAMorphcrop,1)) '\n'], phiAMorphcrop) ;
fclose(fileIDphiA);

status = 1;

end

