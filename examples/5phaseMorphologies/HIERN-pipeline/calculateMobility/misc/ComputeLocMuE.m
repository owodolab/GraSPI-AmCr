function locMu = ComputeLocMuE(ixInterest,iyInterest,twoLayersDown,phiAMorph,Morph)

%    tiledlayout(3,1);
%    nexttile;
%    imagesc(twoLayersUp);


    sizeLay=size(twoLayersDown);
    
    locMuField=zeros(sizeLay(1), sizeLay(2));
    colorbar;

    for ix=1:sizeLay(2)
        if( ix ~= ixInterest )
            twoLayersDown(2,ix) = 0; 
        end
    end

    CC = bwlabel_ol(twoLayersDown,8);

%     save('/data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/examples/5phaseMorphologies/HIERN-pipeline/Tempfiles/tempCC2.mat', 'twoLayersDown');
%     cmd=['cd /data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/examples/5phaseMorphologies/HIERN-pipeline/;ml pythonclever; python CC2.py tempCC2'];
%     system(cmd)    
%     load('/data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/examples/5phaseMorphologies/HIERN-pipeline/Tempfiles/tempCC2.mat', 'labeledImage');
%     CC=labeledImage;
    
    for ix=1:sizeLay(2)
        if( ( CC(1,ix) == CC(2,ixInterest) ) &&( twoLayersDown(1,ix) == 1 ))
             CosAlpha=1/(sqrt(1+(ixInterest-ix)*(ixInterest-ix)));

             prefactor = 0.0;
             if (Morph(1,ix) == 1) prefactor = 0.1 * phiAMorph(1,ix)*phiAMorph(1,ix); end
             if (Morph(1,ix) == 3) prefactor = 0.1 * phiAMorph(1,ix)*phiAMorph(1,ix); end
             if (Morph(1,ix) == 7) prefactor =   1 * phiAMorph(1,ix)*phiAMorph(1,ix); end
             locMuField(1,ix)=prefactor * CosAlpha;
        end
    end

%    nexttile
%    imagesc(twoLayersDown);
%    colorbar;
%    nexttile
%    imagesc(locMuField);
%    colorbar;

    
    locMu =max( locMuField(1,:) );

end