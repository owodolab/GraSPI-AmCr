function locMu = ComputeLocMuH(ixInterest,iyInterest,twoLayersUp,phiDMorph,Morph)

%    tiledlayout(3,1);
%    nexttile;
%    imagesc(twoLayersUp);


    sizeLay=size(twoLayersUp);
    
    locMuField=zeros(sizeLay(1), sizeLay(2));
    colorbar;

    for ix=1:sizeLay(2)
        if( ix ~= ixInterest )
            twoLayersUp(1,ix) = 0; 
        end
    end

    CC = bwlabel_ol(twoLayersUp,8);

%     save('/data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/examples/5phaseMorphologies/HIERN-pipeline/Tempfiles/tempCC.mat', 'twoLayersUp');
%     cmd=['cd /data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/examples/5phaseMorphologies/HIERN-pipeline/;ml pythonclever; python CC.py tempCC'];
%     system(cmd)    
%     load('/data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/examples/5phaseMorphologies/HIERN-pipeline/Tempfiles/tempCC.mat', 'labeledImage');
%    CC=labeledImage;

    for ix=1:sizeLay(2)
        if( ( CC(2,ix) == CC(1,ixInterest) ) &&( twoLayersUp(2,ix) == 1 ))
             CosAlpha=1/(sqrt(1+(ixInterest-ix)*(ixInterest-ix)));

             prefactor = 0.0;
             if (Morph(2,ix) == 0) prefactor = 0.1 * phiDMorph(2,ix)*phiDMorph(2,ix); end
             if (Morph(2,ix) == 3) prefactor = 0.1 * phiDMorph(2,ix)*phiDMorph(2,ix); end
             if (Morph(2,ix) == 5) prefactor =   1 * phiDMorph(2,ix)*phiDMorph(2,ix); end
             locMuField(2,ix)=prefactor * CosAlpha;
        end
    end

%    nexttile
%    imagesc(twoLayersUp);
%    colorbar;
%    nexttile
%    imagesc(locMuField);
%    colorbar;

    
    locMu =max( locMuField(2,:) );
end