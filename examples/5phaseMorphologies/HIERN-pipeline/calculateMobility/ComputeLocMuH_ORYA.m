function locMu = ComputeLocMuH_ORYA(ixInterest,iyInterest,twoLayers,phiMorph,Morph,NEI,Ndim,Connectivity,DeltaX,MorphoTypes,Weights,SourceTargetPlanes,RefCode,NameFolderGraspi)

%    tiledlayout(3,1);
%    nexttile;
%    imagesc(twoLayers);

% twoLayers = twoLayersUp;

% --------------------------------------------------------------
% Transpose to be consistent with PF routine ordering of x and y
% --------------------------------------------------------------

twoLayers = twoLayers';
phiMorph = phiMorph';
Morph = Morph';

sizeLay=size(twoLayers);

% --------------------------------------------------------------
% Keep a 1 on twoLayers only for the considered source node of the charge carrier
% --------------------------------------------------------------

IndCancel = setdiff((1:sizeLay(1)),ixInterest);
twoLayers(IndCancel,SourceTargetPlanes(1)) = 0; 

% --------------------------------------------------------------
% Identify domains by CCL
% --------------------------------------------------------------

CC = zeros(size(twoLayers));
IndPhase = find(twoLayers==1);
[ Labels, NDomains ] = ConnectCompoLabelling(IndPhase, NEI, Ndim, Connectivity);
CC(IndPhase) = Labels;

% --------------------------------------------------------------
% Identify the nodes of the target line that are in the same domain than the source node
% --------------------------------------------------------------

ix_Target = find( CC(:,SourceTargetPlanes(2)) == CC(ixInterest,SourceTargetPlanes(1)) & ( twoLayers(:,SourceTargetPlanes(2))==1 ) ); %  ???
NIndTarget = numel(ix_Target);

% --------------------------------------------------------------
% Calculate the loc mu
% --------------------------------------------------------------

% Initialize arrays
CosAlpha = zeros(1,NIndTarget);
prefactor = zeros(1,NIndTarget);
locMuField = zeros(1,NIndTarget);

% Calculate CosAlpha
CosAlpha=1./(sqrt(1+DeltaX(ixInterest,ix_Target).^2));

% Calculate prefactor
NMorphoType = numel(MorphoTypes);
for nn = 1:NMorphoType
    IndMorpho = find( Morph(ix_Target,SourceTargetPlanes(2))==MorphoTypes(nn) );
    prefactor(IndMorpho) = Weights(nn) * phiMorph(ix_Target(IndMorpho),SourceTargetPlanes(2)) .* phiMorph(ix_Target(IndMorpho),SourceTargetPlanes(2));
end

% Calculate locmu 
locMuField = prefactor.*CosAlpha;
locMu =max(locMuField);
if isempty(locMu)
    locMu = 0;
end

% colorbar;
%    nexttile
%    imagesc(twoLayers);
%    colorbar;
%    nexttile
%    imagesc(locMuField);
%    colorbar;

    
end