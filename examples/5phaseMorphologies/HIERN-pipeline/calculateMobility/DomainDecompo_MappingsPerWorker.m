function [ LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, HaloNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers, IndLoc_Halo1, IndLoc_Halo2 ] = DomainDecompo_MappingsPerWorker( ProcNum, nxyz, FlagBC, Ncpu, Nblocs, Halosize, StartStopInd_percpu )
% This function determines the global indices and subscripts of the nodes a given worker has to take care of, plus the number of the neighbouring workers the halo nodes belong to
%
% INPUT:
%   - ProcNum: the global indice of the considered worker
%   - nxyz: 1*3 array of global mesh size in x, y, z direction, respectively
%   - FlagBC: 1*3 array of flags for boundary conditions in x, y, z direction, respectively
%   - Ncpu: total number of workers
%   - Nblocs: 1*3 array of number of workers in x, y, z direction, respectively
%   - Halosize: the thickness of the halo (number of nodes)
%   - StartStopInd_percpu: Ncpu*6 array with, on each row (corresponding to one worker), the smallest node subscript in x, y, z direction, then the highest node subscript in x, y, z direction
% OUTPUT:
%   - LocalOwnedNodes_GlobalCarto: NnodesOwned*4 array (NnodesOwned being the number of nodes belonging to the worker) with global indices (in increasing order) in the first column and x, y, z global subscritps in the three last columns
%   - AllNodes_GlobalCarto_ord: NnodesWorker*4 array (NnodesWorker being the number of nodes handled by the worker, owned nodes + halo) with global indices (first the owned nodes in increasing order, then the halo nodes in increasing order) in the first column and x, y, z global subscritps in the three last columns
%   - HaloNodes_GlobalCarto_ord: NnodesHalo*4 array (NnodesHalo being the number of halo nodes handled of the worker) with global indices (in increasing order) in the first column and x, y, z global subscritps in the three last columns
%   - MyHaloNodes_NoWorkers: NnodesHalo*2 array (NnodesHalo being the number of halo nodes handled of the worker) with global indices (in increasing order) in the first column and the number of the neighbouring workers the halo nodes belong to in the second column
%   - IndLoc_Halo1: local indices of the larger halo
%   - IndLoc_Halo2: local indices of the smaller halo
% UNIT TEST:
%   nxyz = [10 24 1];
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz ); !!! Not ordered like in the old MeshNoNeighbours; Check carefully whether it's problematic
%   Nblocs=[2 4 1]; Ncpu=prod(Nblocs);
%   [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
%   FlagBC = [0 1 0]; Halosize = 2; ProcNum = 1;
%   [ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum);
%   [ LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, HaloNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers, IndLoc_Halo1, IndLoc_Halo2 ] = DomainDecompo_MappingsPerWorker( ProcNum, nxyz, FlagBC, Ncpu, Nblocs, Halosize, StartStopInd_percpu );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL INDICES FOR ONE DOMAIN/WORKER: THE NODES THAT BELONGS TO THE DOMAIN/WORKER ITSEFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Domain decomposition, owned nodes mappings')

% Global indices handled by processor 

% Nodes_LocalCarto
% Nodes_LocalCarto(:,1) are the nodes global indices, Nodes_LocalCarto(:,2:4) are the nodes global subscripts along x, y and z
SubOwnedNodes = cell(1,3);
StartStopInd_percpu_OfWorker = StartStopInd_percpu(ProcNum,:);
for kk = 1:3
    SubOwnedNodes{kk} = (StartStopInd_percpu_OfWorker(kk):StartStopInd_percpu_OfWorker(kk+3))';
end
[ LocalOwnedNodes_GlobalCarto ] = DomainDecompo_IndSub_PerDomain( SubOwnedNodes, nxyz );

disp('Domain decomposition, owned nodes mappings... done')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL INDICES FOR ONE DOMAIN/WORKER: THE NODES THAT BELONGS TO THE HALO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%)%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Domain decomposition, halo nodes mappings')

% ---------------------------------------------------------------------
% Determination of owned nodes + halo subscripts in X, Y, Z directions and indices
% ---------------------------------------------------------------------

[ SubsAllNodes ] = DomainDecompo_MappingsPerWorker_HaloNodesSubscripts( nxyz, FlagBC, Halosize, Nblocs, StartStopInd_percpu, ProcNum );
[ AllNodes_GlobalCarto ] = DomainDecompo_IndSub_PerDomain( SubsAllNodes, nxyz );

% ---------------------------------------------------------------------
% Determination of halo nodes subscripts in X, Y, Z directions and indices
% ---------------------------------------------------------------------

[ Ind_proc_onlyhalo, ia ] = setdiff(AllNodes_GlobalCarto(:,1), LocalOwnedNodes_GlobalCarto(:,1));                    % returns the values in Ind_proc_halo_curr that are not in Ind_proc_curr
HaloNodes_GlobalCarto_ord = AllNodes_GlobalCarto(ia,:);
HaloNodes_GlobalCarto_ord = sortrows(HaloNodes_GlobalCarto_ord,1);

% Ind_proc_ord_onlyhalo = HaloNodes_GlobalCarto_ord(:,1);

% ---------------------------------------------------------------------
% Reconstruct the (ordered) caro of nodes on the core
% ---------------------------------------------------------------------
% First the owned nodes in ascending indices order
% Then the halo nodes in ascending indices order

AllNodes_GlobalCarto_ord = [LocalOwnedNodes_GlobalCarto;HaloNodes_GlobalCarto_ord];

% ---------------------------------------------------------------------
% MyHaloNodes_NoWorkers contains the indices of the halo nodes (1st col) and the indices of the worker they belong to / we have to receive from (2nd col)
% ---------------------------------------------------------------------

[ MyHaloNodes_NoWorkers ] = DomainDecompo_WhichWorker_OwnsNodes( HaloNodes_GlobalCarto_ord, nxyz, Nblocs );

% ---------------------------------------------------------------------
% Do the same for a smaller halo and extract the different nodes between small and large halos
% ---------------------------------------------------------------------
% IndLoc_Halo1 and IndLoc_Halo2 are the local indices of the larger and smaller halo, respectively

[ SubsAllNodes_SmallHalo ] = DomainDecompo_MappingsPerWorker_HaloNodesSubscripts( nxyz, FlagBC, Halosize-1, Nblocs, StartStopInd_percpu, ProcNum );
[ AllNodes_GlobalCarto_SmallHalo ] = DomainDecompo_IndSub_PerDomain( SubsAllNodes_SmallHalo, nxyz );

[ Ind_proc_onlyhalo_SmallHalo, ias ] = setdiff(AllNodes_GlobalCarto_SmallHalo(:,1), LocalOwnedNodes_GlobalCarto(:,1));                    % returns the values in Ind_proc_halo_curr that are not in Ind_proc_curr
HaloNodes_GlobalCarto_SmallHalo_ord = AllNodes_GlobalCarto_SmallHalo(ias,:);
HaloNodes_GlobalCarto_SmallHalo_ord = sortrows(HaloNodes_GlobalCarto_SmallHalo_ord,1);
AllNodes_GlobalCarto_SmallHalo_ord = [LocalOwnedNodes_GlobalCarto;HaloNodes_GlobalCarto_SmallHalo_ord];

[IndGlo_Halo2 IndLoc_Halo2] = setdiff(AllNodes_GlobalCarto_ord(:,1),AllNodes_GlobalCarto_SmallHalo_ord(:,1));
[IndGlo_Halo1 IndLoc_Halo1 IndLoc_dum] = intersect(AllNodes_GlobalCarto_ord(:,1),AllNodes_GlobalCarto_SmallHalo_ord(:,1));

disp('Domain decomposition, halo nodes mappings... done')

end

