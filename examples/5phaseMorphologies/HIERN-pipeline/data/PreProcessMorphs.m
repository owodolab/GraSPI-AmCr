% -------------------------------------------------------------------------
% Load File
% -------------------------------------------------------------------------

myFiles = dir('*.mat'); %gets all mat files in struct
for fileId = 1:length(myFiles)
    NameFile = myFiles(fileId).name;
    NameFileWoExt = extractBefore(NameFile, ".");

    MorphFileName = sprintf("Morph%s.txt",NameFileWoExt);
    PhiDFileName = sprintf("Morph%s-phiD.txt",NameFileWoExt);
    PhiAFileName = sprintf("Morph%s-phiA.txt",NameFileWoExt);

    nxyz = [256 1 512];
    FlagBC = [0 0 1];

    % -------------------------------------------------------------------------
    % User parameters
    % -------------------------------------------------------------------------

    PostParam.LimPhiSolv_FilmMean = 0.02;
    PostParam.LimPhiAir_Film = 0.05;

    PostParam.PercoThresHoles = 0.1;
    PostParam.PercoThresElec = 0.1;

    % -------------------------------------------------------------------------
    % Let's go
    % -------------------------------------------------------------------------
    load(NameFile);

    LabelsImg=reshape(Res.PhaseType,nxyz(1),nxyz(3));
    [row,col] = find(LabelsImg==0);

    height=min(col);
    %height=140;
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

    fileID = fopen(MorphFileName,'w');
    fprintf(fileID,'%d %d \n',width,height);
    fprintf(fileID, [repmat('%d ', 1, size(Img2save,1)) '\n'], Img2save) ;
    fclose(fileID);


    phiDMorph=reshape(Res.PreProFields(:,1),nxyz(1),nxyz(3));
    phiDMorphcrop=phiDMorph(:,1:height);
    fileIDphiD = fopen(PhiDFileName,'w');
    fprintf(fileIDphiD, [repmat('%d ', 1, size(phiDMorphcrop,1)) '\n'], phiDMorphcrop) ;
    fclose(fileIDphiD);

    phiAMorph=reshape(Res.PreProFields(:,2),nxyz(1),nxyz(3));
    phiAMorphcrop=phiAMorph(:,1:height);
    fileIDphiA = fopen(PhiAFileName,'w');
    fprintf(fileIDphiA, [repmat('%d ', 1, size(phiAMorphcrop,1)) '\n'], phiAMorphcrop) ;
    fclose(fileIDphiA);

end
