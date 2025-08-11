% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A faire une seule fois
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Il faut avoir la taille des images nxyz
nxyz = [10 2 1];
dxyz = [1 1 1];

% Define bondary conditions
FlagBC = [0 1 0]; 

% Choose connectivity
Connectivity = 'extended';

% Needed for CCL (do not touch)
Nnodes = prod(nxyz); Ndim = numel(find(nxyz>1));
[ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz );
Nblocs=[1 1 1]; Ncpu=prod(Nblocs);
[ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
 Halosize = 2; ProcNum = 1;
[ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum);
[ LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, HaloNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers, IndLoc_Halo1, IndLoc_Halo2 ] = DomainDecompo_MappingsPerWorker( ProcNum, nxyz, FlagBC, Ncpu, Nblocs, Halosize, StartStopInd_percpu );
[ NEI.NoNeighb ] = Mesh_NoNeighbours( AllNodes_GlobalCarto_ord, AllShiftDirs, nxyz, FlagBC );
NEI.NNeighb = size(NEI.NoNeighb,2);

[ MeshCoord ] = MeshCoordinate ( nxyz, dxyz );
MeshCoord = MeshCoord + 0.5;
DeltaX = zeros(nxyz(1),nxyz(1)); % distances x taking into account BC along x direction
for ix = 1:nxyz(1)
    PointCoord = [ix 1 1];
    [ PointMeshCoordXYZ ] = MeshClosestCoordToPoint(nxyz, dxyz, MeshCoord, PointCoord, FlagBC);
    IndUseful = find(PointMeshCoordXYZ(:,2)==1);
    DeltaX(ix,:) = PointMeshCoordXYZ(IndUseful,1);
end

MorphoTypes = [0 3 5]; % [0 3 5] for up, [1 3 7] for down, 
Weights = [0.1 0.1 1]; % [0.1 0.1 1] for up and down 

SourceTargetPlanes = [1 2]; % Number of source and target planes; [1 2] for up, [2,1] for down

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A faire pour chaque image
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Charger l'image and morpho and vol. frac.
BW = rand(nxyz);

BW(BW<=0.5) = 0;
BW(BW>0.5) = 1

Morph = rand(nxyz);
Morphsv = Morph;
Morph(Morphsv>0.9) = 0;
Morph(Morphsv<=0.9) = 1;
Morph(Morphsv<=0.7) = 2;
Morph(Morphsv<=0.5) = 3;
Morph(Morphsv<=0.3) = 4;
Morph(Morphsv<=0.1) = 5

phiDMorph = rand(nxyz);

% Identify phase nodes
IndPhase = find(BW==1);

[ Labels, NDomains ] = ConnectCompoLabelling(IndPhase, NEI, Ndim, Connectivity);

CC = zeros(size(BW));
CC(IndPhase) = Labels

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Holes (up)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1:10
    ixInterest = ii;

    ix_Target = find( CC(:,2) == CC(ixInterest,1) && ( twoLayersUp(:,2)==1 ) ); %  ???
    NIndTarget = numel(ix_Target);

    CosAlpha = zeros(1,NIndTarget);
    prefactor = zeros(1,NIndTarget);

    CosAlpha=1./(sqrt(1+DeltaX(ixInterest,ix_Target).^2));

    NMorphoType = numel(MorphoType);
    for nn = 1:NMorphoType
        IndMorpho = find( Morph(ix_Target,2)==MorphoType(nn) );
        prefactor(IndMorpho) = Weight(nn) * phiDMorph(ix_Target(IndMorpho),2) .* phiDMorph(ix_Target(IndMorpho),2);
    end

    locMuField = zeros(nxyz);
    locMuField(ix_Target,2) = prefactor.*CosAlpha

end

% IndMorpho0 = find( Morph(2,ix_Target)==0 );
% prefactor(IndMorpho0) = 0.1 * phiDMorph(2,ix_Target(IndMorpho0))*phiDMorph(2,ix_Target(IndMorpho0));
% IndMorpho3 = find( Morph(2,ix_Target)==3 );
% prefactor(IndMorpho3) = 0.1 * phiDMorph(2,ix_Target(IndMorpho3))*phiDMorph(2,ix_Target(IndMorpho3));
% IndMorpho5 = find( Morph(2,ix_Target)==5 );
% prefactor(IndMorpho5) = 1 * phiDMorph(2,ix_Target(IndMorpho5))*phiDMorph(2,ix_Target(IndMorpho5));

% for ix=1:sizeLay(2)
%     if( ( CC(2,ix) == CC(1,ixInterest) ) && ( twoLayersUp(2,ix) == 1 ))
%         CosAlpha=1/(sqrt(1+(ixInterest-ix)*(ixInterest-ix)));
%         
%         prefactor = 0.0;
%         if (Morph(2,ix) == 0) prefactor = 0.1 * phiDMorph(2,ix)*phiDMorph(2,ix); end
%         if (Morph(2,ix) == 3) prefactor = 0.1 * phiDMorph(2,ix)*phiDMorph(2,ix); end
%         if (Morph(2,ix) == 5) prefactor =   1 * phiDMorph(2,ix)*phiDMorph(2,ix); end
%         locMuField(2,ix)=prefactor * CosAlpha;
%     end
% end




