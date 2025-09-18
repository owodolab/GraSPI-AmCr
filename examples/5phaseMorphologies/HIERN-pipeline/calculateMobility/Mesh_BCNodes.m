function [ BCNodes, BCNodesDegenerateNeighb, IndColNeighbBCnodes, IndColNeighbBCnodesFiltMinMax, VecSelectFiltMinMax ] = Mesh_BCNodes( FlagBC, MeshCoordLoc ,MinMaxCoordGlo, NoNeighb, Ndim )
% This function identifies the global indices of bondary nodes on a worker
%
% INPUT:
%   - MeshCoordLoc: Nnodesloc*3 array with the (x,y,z) coordinates of the Nnodesloc nodes handled by the worker
%   - MinMaxCoordGlo: 3*2 array with the min and max coordinates of the (global) mesh in each direction
%   - NNeighb: max. number of neighbours per node / of shift directions (see also Mesh_AllShiftDirs) 
% OUTPUT:
%   - BCNodes: 3*2 cell with the list of nodes of the worker which are located at the domain boundaries
%   - BCNodesDegenerateNeighb: (for filtering) list of nodes at any boundary ( ==> which have less neighbours as compared to bulk nodes)
%   - IndColNeighbBCnodes: (for filtering) NnodeBC*1 cell array, for the NnodeBC nodes at a boundary, containing the list of columns (in NoNeighb) where there is really a neighbour
%   - IndColNeighbBCnodesFiltMinMax: (for filtering) NnodeBC*2 cell array, for the NnodeBC nodes at a boundary, containing the list of columns (in NoNeighb) where there are really nearest neighbours, and a nearest+second nearest neighbours, respectively
%   - VecSelectFiltMinMax: (for filtering) 2*1 cell array with the list of columns in NoNeighb corresponding to nearest neighbours and nearest+second nearest neighbours, respectively

NNeighb = size(NoNeighb,2);
BCNodes = cell(3,2);            %  3 dimensions x y z * Max/Min (1st col = Min, 2nd col = Max) 
BCNodesDegenerateNeighb = [];   % List of nodes at a boundary, with less neighbours as compared to bulk nodes
nxyzloc = zeros(1,3);
for nn = 1:3
    nxyzloc(nn) = numel(unique(MeshCoordLoc(:,nn)));
    if ( FlagBC(nn)~=0 )
        for mm = 1:2
            BCNodes{nn,mm} = find( MeshCoordLoc(:,nn)==MinMaxCoordGlo(nn,mm) );
            BCNodesDegenerateNeighb = [BCNodesDegenerateNeighb; BCNodes{nn,mm}];
        end
    end
end

VecSelectFiltMinMax{1} = 1:1+2*Ndim;
VecSelectFiltMinMax{2} = 1:NNeighb+1;
IndColNeighbBCnodes = cell(numel(BCNodesDegenerateNeighb),1);
IndColNeighbBCnodesFiltMinMax = cell(numel(BCNodesDegenerateNeighb),2);
for ii = 1:numel(BCNodesDegenerateNeighb)
    IndColNeighbBCnodes{ii} = find(NoNeighb(BCNodesDegenerateNeighb(ii),:)~=0);
    IndColNeighbBCnodes{ii} = reshape(IndColNeighbBCnodes{ii},1,numel(IndColNeighbBCnodes{ii})); % only because matlab returns IndColNeighbBCnodes as a column vector and octave as a row vector...
    IndColNeighbBCnodes{ii} = [1 IndColNeighbBCnodes{ii}+1]; % add the node itself
    IndColNeighbBCnodesFiltMinMax{ii,1} = intersect(IndColNeighbBCnodes{ii},VecSelectFiltMinMax{1});
    IndColNeighbBCnodesFiltMinMax{ii,2} = intersect(IndColNeighbBCnodes{ii},VecSelectFiltMinMax{2});
end

end

