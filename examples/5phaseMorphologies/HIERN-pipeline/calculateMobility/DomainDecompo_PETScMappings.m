function [ TOPETSC_PF, TOPETSC_HYDRO, TOPETSC_ADV ] = DomainDecompo_PETScMappings( ProcNum, nxyz, NnodesGlo, NnodesOwned, Nnodes, Nneighbours, NFieldsCH, NFieldsAC, NFieldsACCH, NVfields, NFieldsAdvec,     MyNeighbourRecvProcList, MyHaloNodes_NoWorkers, StartStopInd_percpu,  BUTCHPF, BUTCHADV, Flag, NSpecies, NNonLiqPhase, SizeMatCHGlo, SizeMatACGlo, SizeMatACCHGlo, SizeMatHYDROGlo, SizeMatAdvecGlo )
% This function calculates the necessary mappings for writing the PETSc matrix: the nodes handled by a given worker are gathered together (one bloc of adjacent data is made of all the fields for all the owned nodes of a given worker)
%
% In other words, the data are ordered in the following way for PETSc: 
% First worker first: data of owned nodes for the first field, then tfor the 2nd field, and so on. Then second worker, and so on.
% Example: 10*4 mesh with 3 materials, so 2 fields for Cahn-Hilliard, 2*2 bloc decomposition: 5*2=10 nodes per worker
% Nodes (1:10) first worker, first phi-field, (11:20) first worker, second phi-field, (21:30) second worker, first phi-field,(31:40) second worker, second phi-field,(41:50) third worker, first phi-field,(51:60) third worker, second phi-field, ...
%
% INPUT:
%   - ProcNum: the global indice of the considered worker
%   - nxyz: 1*3 array of global mesh size in x, y, z direction, respectively
%   - NnodesGlo: the total (global) number of nodes of the mesh
%   - NnodesOwned: the number of nodes owned by the considered worker
%   - Nnodes: the number of nodes handled by the considered worker (owned+halo nodes)
%   - Nneighbours: the number of neighbouring workers of the considered worker
%   - NFieldsCH: the number of fields for the Cahn-Hilliard equation
%   - NFieldsAC: the number of fields for the Allen-Cahn equation
%   - NFieldsACCH: the number of fields for the coupled Cahn-Hilliard+Allen-Cahn equations
%   - NVfields: the number of velocity fields for hydrodynamics
%   - NFieldsAdvec: the number of velocity fields for advection alone
%   - MyNeighbourRecvProcList: the list of Nneighbours neighbouring workers of the current core, from which the core will receive node information (i.e. the list of workers where the halo nodes are)
%   - MyHaloNodes_NoWorkers: NnodesHalo*2 array (NnodesHalo being the number of halo nodes handled of the worker) with global indices (in increasing order) in the first column and the number of the neighbouring workers the halo nodes belong to in the second column
%   - StartStopInd_percpu: Ncpu*6 array with, on each row (corresponding to one worker), the smallest node subscript in x, y, z direction, then the highest node subscript in x, y, z direction
%   - BUTCHPF: the structure defining the Butcher matrix for the phase-field equation sytem
%   - BUTCHADV: the structure defining the Butcher matrix for the advection part of the equation sytem
%   - Flag: the structure containing all the flags for the simulation
%   - NSpecies: the number of materials
%   - NNonLiqPhase: the number of species/materials potentially having a crystalline or vapor phase
%   - SizeMatCHGlo: the size of the Cahn-Hilliard matrix (NnodesGlo*NFieldsCH)
%   - SizeMatACGlo: the size of the Allen-Cahn matrix (NnodesGlo*NFieldsAC)
%   - SizeMatACCHGlo: the size of the coupled Cahn-Hilliard+Allen-Cahn matrix (NnodesGlo*NFieldsACCH)
%   - SizeMatHYDROGlo: the size of the hydrodynamics matrix (NnodesGlo*NVfields)
%   - SizeMatAdvecGlo: the size of the Cahn-Hilliard matrix (NnodesGlo*NFieldsAdvec)
% 
% OUTPUT: 
%   - TOPETSC_PF: structure defining, for the phase-field matrix, the mappings for ordering the node information in the matrix solved using the PETSc library; members:
%       - TOPETSC_PF.Sizes: 1*3 array with the total (global) size of the PF matrix (number of lines / ddls), the size of the PF matrix bloc owned by the worker (number of ddls owned by the worker) and the number of fields in the PF matrix
%       - TOPETSC_PF.IndGlo_LocMatLines: array with the global indices (!! in the PETSc bloc representation) of the matrix lines handled by the considered worker (owned+halo)
%       - TOPETSC_PF.IndGlo_LocMatOwnedLines: array with the global indices (!! in the PETSc bloc representation) of the matrix lines owned by the considered worker
%       - TOPETSC_PF.IndLoc_LocMatOwnedLines: array with the local indices of the matrix lines owned by the considered worker
%   - TOPETSC_HYDRO: structure defining, for the fluid mechanics matrix, the mappings for ordering the node information in the matrix solved using the PETSc library; members:
%       - TOPETSC_HYDRO.Sizes: 1*3 array with the total (global) size of the HYDRO matrix (number of lines / ddls), the size of the HYDRO matrix bloc owned by the worker (number of ddls owned by the worker) and the number of fields in the HYDRO matrix
%       - TOPETSC_HYDRO.IndGlo_LocMatLines: array with the global indices (!! in the PETSc bloc representation) of the matrix lines handled by the considered worker (owned+halo)
%       - TOPETSC_HYDRO.IndGlo_LocMatOwnedLines: array with the global indices (!! in the PETSc bloc representation) of the matrix lines owned by the considered worker
%       - TOPETSC_HYDRO.IndLoc_LocMatOwnedLines: array with the local indices of the matrix lines owned by the considered worker
%   - TOPETSC_ADV: structure defining, for the advection matrix (if handled alone), the mappings for ordering the node information in the matrix solved using the PETSc library; members:
%       - TOPETSC_ADV.Sizes: 1*3 array with the total (global) size of the advection matrix (number of lines / ddls), the size of the advection matrix bloc owned by the worker (number of ddls owned by the worker) and the number of fields in the advection matrix
%       - TOPETSC_ADV.IndGlo_LocMatLines: array with the global indices (!! in the PETSc bloc representation) of the matrix lines handled by the considered worker (owned+halo)
%       - TOPETSC_ADV.IndGlo_LocMatOwnedLines: array with the global indices (!! in the PETSc bloc representation) of the matrix lines owned by the considered worker
%       - TOPETSC_ADV.IndLoc_LocMatOwnedLines: array with the local indices of the matrix lines owned by the considered worker
%
% UNIT TEST:
%   nxyz = [10 24 1];
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz ); !!! Not ordered like in the old MeshNoNeighbours; Check carefully whether it's problematic
%   Nblocs=[2 4 1]; Ncpu=prod(Nblocs);
%   [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
%   FlagBC = [0 1 0]; Halosize = 2; ProcNum = 3;
%   [ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum);
%   [ LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, HaloNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers, IndLoc_Halo1, IndLoc_Halo2 ] = DomainDecompo_MappingsPerWorker( ProcNum, nxyz, FlagBC, Ncpu, Nblocs, Halosize, StartStopInd_percpu );
%   [ SizeHalo, MyNeighbourRecvProcList, CommNodeRecvList, MyNeighbourSendProcList, CommNodeSendList, TransmitNodes_StartInd, TransmitNodes_StopInd, TagSend, TagRecv, MyPositionAtSendingProcOwnedNodes_vec, MyPositionAtReceivingProcHaloNodes_vec ] = DomainDecompo_CommTree( ProcNum, nxyz, Halosize, StartStopInd_percpu, NoAllNeighboursCore_PerShiftDir, AllShiftDirs, AllNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers );
%   Flag.Hydrodynamics = 1; Flag.AdvecMethod = 0;
%   NnodesGlo = prod (nxyz); NnodesOwned = size(LocalOwnedNodes_GlobalCarto,1); Nnodes = size(AllNodes_GlobalCarto_ord,1);
%   Nneighbours = numel(MyNeighbourRecvProcList);
%   NSpecies = 3; NNonLiqPhase = 1;
%   NFieldsCH = NSpecies-1; NFieldsAC=1; NFieldsACCH=3; NVfields=2; NFieldsAdvec=NFieldsCH+NFieldsAC;
%   SizeMatCHGlo = NnodesGlo*NFieldsCH; SizeMatACGlo = NnodesGlo*NFieldsAC; SizeMatACCHGlo = NnodesGlo*NFieldsACCH; SizeMatHYDROGlo = NnodesGlo*NVfields; SizeMatAdvecGlo = NnodesGlo*NFieldsAdvec;
%   [ BUTCHPF ] = ButcherMatrix( 'PareschiRusso' ); [ BUTCHADV ] = ButcherMatrix( 'PareschiRusso' );
%   TIM = [];
%   [ TOPETSC_PF, TOPETSC_HYDRO, TOPETSC_ADV ] = DomainDecompo_PETScMappings( ProcNum, nxyz, NnodesGlo, NnodesOwned, Nnodes, Nneighbours, NFieldsCH, NFieldsAC, NFieldsACCH, NVfields, NFieldsAdvec,     MyNeighbourRecvProcList, MyHaloNodes_NoWorkers, StartStopInd_percpu,    BUTCHPF, BUTCHADV, Flag, NSpecies, NNonLiqPhase, SizeMatCHGlo, SizeMatACGlo, SizeMatACCHGlo, SizeMatHYDROGlo, SizeMatAdvecGlo );

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For PETSc: definition of the global indices of the matrix (needed for parallel implicit resolution)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global indices of the local nodes in the PETSc ordering (1st proc --> 1st node indices, etc)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------------------------------------
% Global indices of the locally owned nodes, in the PETSc ordering
% ---------------------------------------------------------------------------

Ind_proc_PETSc = (1+(ProcNum-1)*NnodesOwned:ProcNum*NnodesOwned)';

% ---------------------------------------------------------------------------
% Global indices of the locally defined nodes (owned+halo), in the PETSc ordering
% ---------------------------------------------------------------------------

Ind_halo_proc_PETSc = zeros(Nnodes,1);

% First, take the locally owned nodes -------------------------------------

Ind_halo_proc_PETSc(1:NnodesOwned) = Ind_proc_PETSc;

% Then, take the halo nodes, neighbour by neighbour -----------------------

count = NnodesOwned;
for nn = 1:Nneighbours

    % Neighbour information
    NoNeighbProc = MyNeighbourRecvProcList(nn)+1; % +1 because we are back to Matlab indices
    Indcurr = find(MyHaloNodes_NoWorkers(:,2)==NoNeighbProc);
    NodeListcurr = MyHaloNodes_NoWorkers(Indcurr,1);
    NbNodesNeighb = size(NodeListcurr,1);

    % Get the global indices of the nodes owned by neighbour
    SubOwnedNodes = cell(1,3);
    StartStopInd_percpu_OfWorker = StartStopInd_percpu(NoNeighbProc,:);
    for kk = 1:3
        SubOwnedNodes{kk} = (StartStopInd_percpu_OfWorker(kk):StartStopInd_percpu_OfWorker(kk+3))';
    end
    [ LocalOwnedNodes_GlobalCarto_Neighb ] = DomainDecompo_IndSub_PerDomain( SubOwnedNodes, nxyz );

    % Check where the halo nodes are on the neighbour local mapping
    [tf, loc] = ismember(NodeListcurr, LocalOwnedNodes_GlobalCarto_Neighb(:,1));

    % Write the global indices in the PETSc ordering
    Ind_halo_proc_PETSc(NnodesOwned+Indcurr) = (NoNeighbProc-1)*NnodesOwned + loc;

    % For next neighbour, change position of storage
    count = count+NbNodesNeighb;

end
    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global indices of the local matrix
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------------------

NddlPhiOwned = NnodesOwned*(NSpecies-1);

TOPETSC_PF = struct();
if ( BUTCHPF.ImplicitNeeded>0 )
    if ( NSpecies>1 && NNonLiqPhase==0 )
        TOPETSC_PF.Sizes = [SizeMatCHGlo NddlPhiOwned NFieldsCH];
        [TOPETSC_PF.IndGlo_LocMatLines,TOPETSC_PF.IndGlo_LocMatOwnedLines,TOPETSC_PF.IndLoc_LocMatOwnedLines] = MatGlobalLocalMapping(SizeMatCHGlo,NnodesGlo,Nnodes,NnodesOwned,Ind_halo_proc_PETSc,Ind_proc_PETSc);
    elseif ( NNonLiqPhase>0 && NSpecies==1 )
        TOPETSC_PF.Sizes = [SizeMatACGlo 0 NFieldsAC];
        [TOPETSC_PF.IndGlo_LocMatLines,TOPETSC_PF.IndGlo_LocMatOwnedLines,TOPETSC_PF.IndLoc_LocMatOwnedLines] = MatGlobalLocalMapping(SizeMatACGlo,NnodesGlo,Nnodes,NnodesOwned,Ind_halo_proc_PETSc,Ind_proc_PETSc);
    elseif ( NSpecies>1 && NNonLiqPhase>0 )
        TOPETSC_PF.Sizes = [SizeMatACCHGlo NddlPhiOwned NFieldsACCH];
        [TOPETSC_PF.IndGlo_LocMatLines,TOPETSC_PF.IndGlo_LocMatOwnedLines,TOPETSC_PF.IndLoc_LocMatOwnedLines] = MatGlobalLocalMapping(SizeMatACCHGlo,NnodesGlo,Nnodes,NnodesOwned,Ind_halo_proc_PETSc,Ind_proc_PETSc);
    end
end

TOPETSC_HYDRO = struct();
if ( Flag.Hydrodynamics==1 )
    TOPETSC_HYDRO.Sizes = [SizeMatHYDROGlo 0 NVfields+1];
    [TOPETSC_HYDRO.IndGlo_LocMatLines,TOPETSC_HYDRO.IndGlo_LocMatOwnedLines,TOPETSC_HYDRO.IndLoc_LocMatOwnedLines] = MatGlobalLocalMapping(SizeMatHYDROGlo,NnodesGlo,Nnodes,NnodesOwned,Ind_halo_proc_PETSc,Ind_proc_PETSc);
end

TOPETSC_ADV = struct();
if ( Flag.Hydrodynamics==1 )
    if ( Flag.AdvecMethod==-1 )
        if ( BUTCHADV.ImplicitNeeded>0 )
            TOPETSC_ADV.Sizes = [SizeMatAdvecGlo NddlPhiOwned NFieldsAdvec];
            [TOPETSC_ADV.IndGlo_LocMatLines,TOPETSC_ADV.IndGlo_LocMatOwnedLines,TOPETSC_ADV.IndLoc_LocMatOwnedLines] = MatGlobalLocalMapping(SizeMatAdvecGlo,NnodesGlo,Nnodes,NnodesOwned,Ind_halo_proc_PETSc,Ind_proc_PETSc);
        end
    end
end

end

