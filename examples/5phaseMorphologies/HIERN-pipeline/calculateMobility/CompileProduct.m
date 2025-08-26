function [ Product ] = CompileProduct( Product )
%UNTITLED2 Summary of this function goes here
% G?n?re toutes les grandeurs n?cessaires au traitement du produit et les ajoute ? la structure
% INPUT
% Une structure "Product" avec le nom et ses {X,dX,sizeX}
% OUTPUT
% La m?me structure avec en plus
% .Nbdim: Nb de dimensions de maillage
% .Xcat: les vecteurs X concat?n?s correctement
% .dXcat: les vecteurs dX concat?n?s correctement
% .dXcatProd: dX1*...*dXn
% .Values: Population, initialis?e ? 0 si elle n'existe pas
% .XIndReactionMesh: les indices des valeurs de Xcat dans le maillage de la dimension
% .Xposition2: inversement, pour chaque valeur de maillage de chaque dimension, o? la trouve-t-on dans le maillage Xcat

Product.Nbdim=length(Product.X); % Nb de dimensions de maillage
if Product.Nbdim==0
    Product.Xcat=cell(0,0);
else
    
    % D'abord d?termination des indices ? aller chercher
    CumLength=cumprod(Product.sizeX); 
    TotLength=CumLength(end);
    Bidule=zeros(CumLength(end),Product.Nbdim);
    Bidule2=zeros(CumLength(end),Product.Nbdim);
    for ii=1:Product.Nbdim
        if TotLength>0
            jjvec=1:TotLength;
            Bidule(:,ii)=floor( jjvec/((CumLength(ii))/(Product.sizeX(ii))) )+1;
            Bidule2(:,ii)=(mod(Bidule(:,ii)-1,Product.sizeX(ii))+1);
        end
    end
    Bidule2=vertcat(Bidule2(end,:),Bidule2(1:end-1,:)); % remise en premier de la derni?re ligne

    % Ensuite ?criture des tableaux
    Product.Xcat=zeros(CumLength(end),Product.Nbdim);
    for ii=1:Product.Nbdim
        Product.Xcat(:,ii)=Product.X{ii}(Bidule2(:,ii));
    end

    clear CumLength Bidule Bidule2 Bidule3

end

end

