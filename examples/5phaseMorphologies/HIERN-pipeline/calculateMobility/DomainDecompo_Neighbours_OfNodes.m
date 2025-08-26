function [ NoAllNeighbours_PerShiftDir ] = DomainDecompo_Neighbours_OfNodes( Nodes_Carto, AllShiftDirs, nxyz, FlagBC)
% This function identifies the neighbours of a core/worker in all directions
%
% INPUT:
%   - Nodes_Carto: Nelem*4 array (Nelem being the total number of nodes); the first column contains the global indices of all nodes, the three next columns are the global subscripts in x, y, z direction, respectively 
%   - AllShiftDirs: Ndirs*3 array with the list of all shift directions. One shift direction is a 1*3 array with -1/0/+1 in x, y, z duirections, respectively
%   - nxyz: 1*3 array of number of nodes in x, y, z direction, respectively
%   - FlagBC: 1*3 array of flags for boundary conditions in x, y, z direction, respectively
% OUTPUT:
%   - NoAllNeighbours_PerShiftDir: 1*NShiftDirs array with the indices of the worker itself + all its neighbors in the order given by AllShiftDirs
% UNIT TEST:
%   nxyz = [10 24 1];
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz );
%   Nblocs=[2 4 1]; Ncpu=prod(Nblocs);
%   [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
%   FlagBC = [0 1 0]; Halosize = 2; ProcNum = 3;
%   [ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum);
%   [ LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, HaloNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers, IndLoc_Halo1, IndLoc_Halo2 ] = DomainDecompo_MappingsPerWorker( ProcNum, nxyz, FlagBC, Ncpu, Nblocs, Halosize, StartStopInd_percpu );
%   [ NoAllNeighbours_PerShiftDir ] = DomainDecompo_Neighbours_OfNodes( AllNodes_GlobalCarto_ord, AllShiftDirs, nxyz, FlagBC );

Nelem = size(Nodes_Carto,1);
NShiftDirs = size(AllShiftDirs,1);
NoAllNeighbours_PerShiftDir = zeros(Nelem,1+NShiftDirs);
NoAllNeighbours_PerShiftDir(:,1) = Nodes_Carto(:,1);
for idir = 1:NShiftDirs
    [ NoNeighboursCore ] = Mesh_NoNeighbours_OneDir( Nodes_Carto, nxyz, FlagBC, AllShiftDirs(idir,:) );
    NoAllNeighbours_PerShiftDir(:,idir+1) = NoNeighboursCore(:,2);
%     IndZero = find(NoAllNeighbours_PerShiftDir(:,idir+1)==0);
%     NoAllNeighbours_PerShiftDir(IndZero,idir+1) = NoAllNeighbours_PerShiftDir(IndZero,1);
end

end