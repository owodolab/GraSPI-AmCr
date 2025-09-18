function [ NoNeighb ] = Mesh_NoNeighbours( AllNodes_GlobalCarto_ord, AllShiftDirs, nxyz, FlagBC )
% This function determines the global indices of the neighbours of a list of Nnodes nodes
%
% INPUT:
%   - AllNodes_GlobalCarto_ord: NnodesWorker*4 array (NnodesWorker being the number of nodes handled by the worker, owned nodes + halo) with global indices (first the owned nodes in increasing order, then the halo nodes in increasing order) in the first column and x, y, z global subscritps in the three last columns
%   - AllShiftDirs: Ndirs*3 array with the list of all shift directions. One shift direction is a 1*3 array with -1/0/+1 in x, y, z duirections, respectively
%   - nxyz: 1*3 array of global mesh size in x, y, z direction, respectively
%   - FlagBC: 1*3 array of flags for boundary conditions in x, y, z direction, respectively
% OUTPUT:
%   - NoNeighb: Nnodes*Nneighb array with, for each node (one row) the global indices of the Nneighb neighbours in the Nneighb=NShiftDirs directions; NB: if there is no neighbour (i.e. boundary conditions), a zero value is set as default
% UNIT TEST:
%   nxyz = [10 24 1];
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz ); !!! Not ordered like in the old MeshNoNeighbours; Check carefully whether it's problematic
%   Nblocs=[2 4 1]; Ncpu=prod(Nblocs);
%   [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
%   FlagBC = [0 1 0]; Halosize = 2; ProcNum = 1;
%   [ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum);
%   [ LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, HaloNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers, IndLoc_Halo1, IndLoc_Halo2 ] = DomainDecompo_MappingsPerWorker( ProcNum, nxyz, FlagBC, Ncpu, Nblocs, Halosize, StartStopInd_percpu );
%   [ NoNeighb ] = Mesh_NoNeighbours( AllNodes_GlobalCarto_ord, AllShiftDirs, nxyz, FlagBC );

[ NoAllNeighbours_PerShiftDir ] = DomainDecompo_Neighbours_OfNodes( AllNodes_GlobalCarto_ord, AllShiftDirs, nxyz, FlagBC );
[ NoNeighb ] = NoAllNeighbours_PerShiftDir(:,2:end); % To comply with former code version
[toto NoNeighb] = ismember(NoNeighb,AllNodes_GlobalCarto_ord(:,1)); % Conversion in local scope


end

