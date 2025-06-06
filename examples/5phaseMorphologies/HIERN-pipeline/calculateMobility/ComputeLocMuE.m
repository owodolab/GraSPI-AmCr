function locMu = ComputeLocMuE(ixInterest,iyInterest,twoLayersDown,phiAMorph,Morph)

    sizeLay=size(twoLayersDown);
    
    locMuField=zeros(sizeLay(1), sizeLay(2));
    colorbar;

    for ix=1:sizeLay(2)
        if( ix ~= ixInterest )
            twoLayersDown(2,ix) = 0; 
        end
    end

    CC = bwlabeln(twoLayersDown,8);

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