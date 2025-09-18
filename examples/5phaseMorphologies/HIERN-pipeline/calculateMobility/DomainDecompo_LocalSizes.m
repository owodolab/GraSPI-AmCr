function [ Nnodes, NnodesOwned, Nddl, NddlCryst, NddlPHI,SizeMatCH, SizeMatAC, SizeMatACCH, SizeMatHYDRO, SizeMatAdvec, SizeMatAdvecPhiPart] = DomainDecompo_LocalSizes( LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, NnodesGlo, NddlGlo, NddlCrystGlo, NddlPHIGlo, SizeMatCHGlo, SizeMatACGlo, SizeMatACCHGlo, SizeMatHYDROGlo, SizeMatAdvecGlo, SizeMatAdvecPhiPartGlo )
% This function determines the local sizes of the matrix on the worker, depending on the global sizes ('...Glo')
%
% INPUT:
%   - LocalOwnedNodes_GlobalCarto: NnodesOwned*4 array (NnodesOwned being the number of nodes belonging to the worker) with global indices (in increasing order) in the first column and x, y, z global subscritps in the three last columns
%   - AllNodes_GlobalCarto_ord: NnodesWorker*4 array (NnodesWorker being the number of nodes handled by the worker, owned nodes + halo) with global indices (first the owned nodes in increasing order, then the halo nodes in increasing order) in the first column and x, y, z global subscritps in the three last columns
%   - The rest is straighforward: global sizes
% OUTPUTS
%   - NnodesOwned: the number of nodes owned by the considered worker
%   - Nnodes: the number of nodes handled by the considered worker (owned+halo nodes)
%   - The rest is straighforward: local sizes

Nnodes = size(AllNodes_GlobalCarto_ord,1);
NnodesOwned = size(LocalOwnedNodes_GlobalCarto,1);

Nddl = NddlGlo/NnodesGlo*Nnodes;
NddlCryst = NddlCrystGlo/NnodesGlo*Nnodes;
NddlPHI = NddlPHIGlo/NnodesGlo*Nnodes;

SizeMatCH = SizeMatCHGlo/NnodesGlo*Nnodes;
SizeMatAC = SizeMatACGlo/NnodesGlo*Nnodes;
SizeMatACCH = SizeMatACCHGlo/NnodesGlo*Nnodes;

SizeMatHYDRO = SizeMatHYDROGlo/NnodesGlo*Nnodes;
SizeMatAdvec = SizeMatAdvecGlo/NnodesGlo*Nnodes;
SizeMatAdvecPhiPart = SizeMatAdvecPhiPartGlo/NnodesGlo*Nnodes;

end

