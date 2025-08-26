function [ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum)
% This function identifies the neighbours of a core/worker in all directions
%
% INPUT:
%   - Core_Carto: Nelem*4 array (Nelem being the total number of nodes); the first column contains the global indices of all workers, the three next columns are the global subscripts in x, y, z direction, respectively 
%   - AllShiftDirs: Ndirs*3 array with the list of all shift directions. One shift direction is a 1*3 array with -1/0/+1 in x, y, z duirections, respectively
%   - Nblocs: 1*3 array of number of workers in x, y, z direction, respectively
%   - FlagBC: 1*3 array of flags for boundary conditions in x, y, z direction, respectively
%   - ProcNum: the global indice of the considered worker
% OUTPUT:
%   - NoAllNeighboursCore_PerShiftDir: 1*NShiftDirs array with the indices of the worker itself + all its neighbors in the order given by AllShiftDirs
% UNIT TEST:
%   nxyz = [4 8 1];
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz );
%   Nblocs=[4 4 1]; Ncpu=prod(Nblocs); 
%   [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
%   FlagBC = [0 1 0]; Halosize = 1; ProcNum = 1;
%   [ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum);

NShiftDirs = size(AllShiftDirs,1);
NoAllNeighboursCore_PerShiftDir = zeros(1,1+NShiftDirs);
NoAllNeighboursCore_PerShiftDir(1) = Core_Carto(ProcNum,1);
for idir = 1:NShiftDirs
    [ NoNeighboursCore ] = Mesh_NoNeighbours_OneDir( Core_Carto(ProcNum,:), Nblocs, FlagBC, AllShiftDirs(idir,:) );
    NoAllNeighboursCore_PerShiftDir(idir+1) = NoNeighboursCore(2);
end

end

