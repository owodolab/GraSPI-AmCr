function [ SizeHalo, MyNeighbourRecvProcList, CommNodeRecvList, MyNeighbourSendProcList, CommNodeSendList, TransmitNodes_StartInd, TransmitNodes_StopInd, TagSend, TagRecv, MyPositionAtSendingProcOwnedNodes_vec, MyPositionAtReceivingProcHaloNodes_vec ] = DomainDecompo_CommTree( ProcNum, nxyz, Halosize, StartStopInd_percpu, NoAllNeighboursCore_PerShiftDir, AllShiftDirs, AllNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers )
% This function calculates the necessary mappings for communication of node information between workers
%
% INPUT:
%   - ProcNum: the global indice of the considered worker
%   - nxyz: 1*3 array of global mesh size in x, y, z direction, respectively
%   - Halosize: the thickness of the halo (number of nodes)
%   - StartStopInd_percpu: Ncpu*6 array with, on each row (corresponding to one worker), the smallest node subscript in x, y, z direction, then the highest node subscript in x, y, z direction
%   - NoAllNeighboursCore_PerShiftDir: 1*NShiftDirs array with the indices of the worker itself + all its neighbors in the order given by AllShiftDirs
%   - AllShiftDirs: Ndirs*3 array with the list of all shift directions. One shift direction is a 1*3 array with -1/0/+1 in x, y, z duirections, respectively
%   - AllNodes_GlobalCarto_ord: NnodesWorker*4 array (NnodesWorker being the number of nodes handled by the worker, owned nodes + halo) with global indices (first the owned nodes in increasing order, then the halo nodes in increasing order) in the first column and x, y, z global subscritps in the three last columns
%   - MyHaloNodes_NoWorkers: NnodesHalo*2 array (NnodesHalo being the number of halo nodes handled of the worker) with global indices (in increasing order) in the first column and the number of the neighbouring workers the halo nodes belong to in the second column
%
% OUTPUT: 
%   - SizeHalo: the number of nodes in the halo of the worker
%   - MyNeighbourRecvProcList: the list of Nneighbours neighbouring workers of the current core, from which the core will receive node information (i.e. the list of workers where the halo nodes are)
%   - CommNodeRecvList: a Nneighbours*1 cell array containing, for each neighbouring workers information is received from, (1st column) the global indices, in ascending order, of the halo nodes to be received and (2nd column) the local indices of the halo nodes to be received
%   - MyNeighbourSendProcList: the list of Nneighbours neighbouring workers of the current core, to which the core will send node information (if everything's fine, MyNeighbourSendProcList=MyNeighbourRecvProcList )
%   - CommNodeSendList:  a Nneighbours*1 cell array containing, for each neighbouring workers information is sent to, (1st column) the global indices of the halo nodes to be received and (2nd column) the local indices of the halo nodes to be received 
%   - TransmitNodes_StartInd: Nneighbours*1 array giving, for a neighbour pair (considered worker + one of its neighbour), the location in "MyPositionAtSendingProcOwnedNodes_vec"/"MyPositionAtReceivingProcHaloNodes_vec" of the first node to be transmitted 
%   - TransmitNodes_StopInd: Nneighbours*1 array giving, for a neighbour pair (considered worker + one of its neighbour), the location in "MyPositionAtSendingProcOwnedNodes_vec"/"MyPositionAtReceivingProcHaloNodes_vec" of the last node to be transmitted  
%   - TagSend: for a neighbour pair (considered worker + one of its neighbour the information is sent to), a univoque identificator of the communication: a number being "Number of the current core sending information"-"0"-"Number of the neighbouring core information is sent to"
%   - TagRecv: for a neighbour pair (considered worker + one of its neighbour the information is received from), a univoque identificator of the communication: a number being "Number of the neighbouring core information is received from"-"0"-"Number of the current core receiving information"
%   - MyPositionAtSendingProcOwnedNodes_vec: vector containing the local indices (on the considered worker) of all nodes whose data have to be sent from the worker to its neighbours
%   - MyPositionAtReceivingProcHaloNodes_vec: vector containing the local indices (on the considered worker) of all nodes whose data have to be received by the worker from its neighbours
%   NB: MyNeighbourRecvProcList, CommNodeRecvList, MyNeighbourSendProcList, CommNodeSendList are not really useful outputs, but I let them here because it's useful to understand what's happening
%
% UNIT TEST:
%   nxyz = [10 24 1];
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz ); !!! Not ordered like in the old MeshNoNeighbours; Check carefully whether it's problematic
%   Nblocs=[2 4 1]; Ncpu=prod(Nblocs);
%   [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
%   FlagBC = [0 1 0]; Halosize = 2; ProcNum = 1;
%   [ NoAllNeighboursCore_PerShiftDir ] = DomainDecompo_Neighbours_OfWorker( Core_Carto, AllShiftDirs, Nblocs, FlagBC, ProcNum);
%   [ LocalOwnedNodes_GlobalCarto, AllNodes_GlobalCarto_ord, HaloNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers, IndLoc_Halo1, IndLoc_Halo2 ] = DomainDecompo_MappingsPerWorker( ProcNum, nxyz, FlagBC, Ncpu, Nblocs, Halosize, StartStopInd_percpu );
%   [ SizeHalo, MyNeighbourRecvProcList, CommNodeRecvList, MyNeighbourSendProcList, CommNodeSendList, TransmitNodes_StartInd, TransmitNodes_StopInd, TagSend, TagRecv, MyPositionAtSendingProcOwnedNodes_vec, MyPositionAtReceivingProcHaloNodes_vec ] = DomainDecompo_CommTree( ProcNum, nxyz, Halosize, StartStopInd_percpu, NoAllNeighboursCore_PerShiftDir, AllShiftDirs, AllNodes_GlobalCarto_ord, MyHaloNodes_NoWorkers );

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % COMMUNICATION OF NODES BETWEEN CORES
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From whom we receive the halo nodes
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------------------------------
% Generate output variables
% ---------------------------------------------------------------------

% List of neibouring workers indices, in ascending order --------------

MyNeighbourRecvProcList = sort(unique(MyHaloNodes_NoWorkers(:,2)));
Nneighbours = numel(MyNeighbourRecvProcList);

% Global indices of nodes to be received, per neibouring workers ------

CommNodeRecvList = cell(Nneighbours,1);
for nn = 1:Nneighbours
    % Where to find the halo nodes received from a given worker in MyHaloNodes_NoWorkers
    IndNodescurr = find(MyHaloNodes_NoWorkers(:,2)==MyNeighbourRecvProcList(nn));
    CommNodeRecvList{nn} = zeros(numel(IndNodescurr),2);
    % Global indices of nodes to be received, sorted in ascending order
    CommNodeRecvList{nn}(:,1) = sort(MyHaloNodes_NoWorkers(IndNodescurr,1));
     % Local indices of nodes to be received
    [toto, LocalInd_HaloNodes] = ismember(CommNodeRecvList{nn}(:,1),AllNodes_GlobalCarto_ord(:,1));
    CommNodeRecvList{nn}(:,2) = LocalInd_HaloNodes;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To whom we send owned nodes
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NoAllNeighboursCore_PerShiftDir ist the list of neighbouring workers (the ones we need to send to) of the current worker; Careful, there might be nans there because of BCs.

% ---------------------------------------------------------------------
% Find subscripts of owned nodes
% ---------------------------------------------------------------------

StartStopInd_percpu_OfWorker = StartStopInd_percpu(ProcNum,:);
SubOwnedNodes = cell(1,3);
for kk = 1:3
    SubOwnedNodes{kk} = (StartStopInd_percpu_OfWorker(kk):StartStopInd_percpu_OfWorker(kk+3))';
end

% ---------------------------------------------------------------------
% Find subscripts of Nodes close to the boundaries, in each direction (dimension and -1/+1)
% ---------------------------------------------------------------------

dims = find(nxyz>1); % dimensions that are meshed
Ndim = numel(dims);  % Dimensionality
SignDoUp = [-1 1];
ShiftRowDoUp = [0 3];
SubCloseBoundary = cell(Ndim,2);
for idim = 1:Ndim
    for iud = 1:2
        SubCloseBoundary{idim,iud} = ( StartStopInd_percpu_OfWorker(dims(idim)+ShiftRowDoUp(iud)) : -SignDoUp(iud) : StartStopInd_percpu_OfWorker(dims(idim)+ShiftRowDoUp(iud)) + SignDoUp(iud)*(1-Halosize) )';
    end
end

% ---------------------------------------------------------------------
% Reduce the data to what we really need
% ---------------------------------------------------------------------

NoAllNeighboursCore_PerShiftDir(find(NoAllNeighboursCore_PerShiftDir==NoAllNeighboursCore_PerShiftDir(1))) = 0; % Ignore shift directions where the core is its own neighbour
NoAllNeighboursCore_PerShiftDir = NoAllNeighboursCore_PerShiftDir(2:end); % Suppress the indice of the core itself
IndNeighb = find(NoAllNeighboursCore_PerShiftDir~=0);
AllShiftDirs_red = AllShiftDirs(IndNeighb,:);
NoAllNeighboursCore_PerShiftDir_red = NoAllNeighboursCore_PerShiftDir(IndNeighb);
NShiftDir = numel(IndNeighb);

% ---------------------------------------------------------------------
% MyNeighbourSendProcList, in ascending order
% ---------------------------------------------------------------------

[ MyNeighbourSendProcList is is2] = unique(sort(NoAllNeighboursCore_PerShiftDir_red'));

% ---------------------------------------------------------------------
% Loop on Neighbours along shift directions: get list of nodes to be sent in each direction
% ---------------------------------------------------------------------

NodeSendList_PerShiftDir = cell(NShiftDir,1);
for nsd = 1:NShiftDir
    
    % Initialize ------------------------------------------------------
    Subscurr = cell(1,3);
    for kk = 1:3
        Subscurr{kk} = 1; % Initialize everything as not active dimension ==> the only subscript is 1
    end
    AllShiftDirs_curr = AllShiftDirs_red(nsd,:);
    
    % Find subscripts -------------------------------------------------
    for idim = 1:Ndim
        if (AllShiftDirs_curr(dims(idim))==0)
            Subscurr{dims(idim)} = SubOwnedNodes{dims(idim)}; % all the nodes along this dim
        elseif (AllShiftDirs_curr(dims(idim))==-1)
            Subscurr{dims(idim)} = SubCloseBoundary{idim,1}; % the nodes close to the downwards boundary
        elseif (AllShiftDirs_curr(dims(idim))==1)
            Subscurr{dims(idim)} = SubCloseBoundary{idim,2}; % the nodes close to the upwards boundary
        end
    end
    
    % Find global indices ---------------------------------------------
    [ LocalNodesToBeSent_GlobalCarto_curr ] = DomainDecompo_IndSub_PerDomain( Subscurr, nxyz );
    
    % Store -----------------------------------------------------------
    NodeSendList_PerShiftDir{nsd} = LocalNodesToBeSent_GlobalCarto_curr(:,1); % Global indices of nodes to be sent
    
end

% ---------------------------------------------------------------------
% CommNodeSendList, assign nodes to be sent to each neighbour: first gather data from all shift directions, then order and clean
% ---------------------------------------------------------------------

CommNodeSendList = cell(Nneighbours,1);
for nsd = 1:NShiftDir
    % Get the number of the worker we send to
    nn = find(MyNeighbourSendProcList==NoAllNeighboursCore_PerShiftDir_red(nsd));
    % Get the global indices of the sent nodes
    NodesToSend_GlobalInd_curr = NodeSendList_PerShiftDir{nsd};
    % Get the local indices of the sent nodes
    [toto, NodesToSend_LocalInd_curr] = ismember(NodesToSend_GlobalInd_curr,AllNodes_GlobalCarto_ord(:,1));
    % Gather everything in the output cell array
    CommNodeSendList{nn} = [ CommNodeSendList{nn};[NodesToSend_GlobalInd_curr NodesToSend_LocalInd_curr] ];
end

for nn = 1:Nneighbours
    % Sort by increasing neighbour number
    CommNodeSendList{nn} = sort(CommNodeSendList{nn});
    % Reduce redundancies
    CommNodeSendList{nn} = unique(CommNodeSendList{nn},'rows'); 
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMUNICATION TREE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nneighbours = numel(MyNeighbourRecvProcList);

% ---------------------------------------------------------------------
% Identification of communication data for current proc
% ---------------------------------------------------------------------

TagSend = zeros(Nneighbours,1);
TagRecv = zeros(Nneighbours,1);
MyPositionAtSendingProcOwnedNodes = cell(Nneighbours,1);
MyPositionAtReceivingProcHaloNodes = cell(Nneighbours,1);
MySentData = cell(Nneighbours,1);
MyRecvData = cell(Nneighbours,1);

for jjsend = 1:Nneighbours
    MyPositionAtSendingProcOwnedNodes{jjsend} = CommNodeSendList{jjsend}(:,2);
    TagSend(jjsend) = str2num([num2str(ProcNum) '0' num2str(MyNeighbourSendProcList(jjsend))]); % enough zeros to ensure that we are not using that much core ( Tag 112 coulb be 1--> 12 or 11-->2, so not univoque; but 1000000012 is univoque)  
end

for jjrecv = 1:Nneighbours
    MyPositionAtReceivingProcHaloNodes{jjrecv} = CommNodeRecvList{jjrecv}(:,2);
    TagRecv(jjrecv) = str2num([num2str(MyNeighbourRecvProcList(jjrecv)) '0' num2str(ProcNum)]);
end

% ---------------------------------------------------------------------
% Upgrade: creation of a single matrix for transmitted data 
% ---------------------------------------------------------------------
% Arrangement 'a la COFRA' of data to be transmitted in a single vector of indices (rows) that will be cut into pieces, dispached and regathered in the C routine
% This avoids the cell array variable, always so slow
% One column per transmitted field (determination of colums, see

MyPositionAtSendingProcOwnedNodes_vec = [];     % Vector of all nodes whose data have to be transmitted
MyPositionAtReceivingProcHaloNodes_vec = [];    % Vector of all nodes whose data have to be received (mirror of previous on mirror proc)
TransmitNodes_StartInd = zeros(Nneighbours,1);  % Location of first indice of node to be transmitted for a neighbour pair
TransmitNodes_StopInd = zeros(Nneighbours,1);   % Location of last indice of node to be transmitted for a neighbour pair

for jjsend = 1:Nneighbours
    TransmitNodes_StartInd(jjsend) = size(MyPositionAtSendingProcOwnedNodes_vec,1)+1;
    MyPositionAtSendingProcOwnedNodes_vec = vertcat(MyPositionAtSendingProcOwnedNodes_vec, MyPositionAtSendingProcOwnedNodes{jjsend});
    MyPositionAtReceivingProcHaloNodes_vec = vertcat(MyPositionAtReceivingProcHaloNodes_vec, MyPositionAtReceivingProcHaloNodes{jjsend});
    TransmitNodes_StopInd(jjsend) = size(MyPositionAtSendingProcOwnedNodes_vec,1);
end
if ( isempty(TransmitNodes_StopInd)==0 )
    SizeHalo = TransmitNodes_StopInd(end);                                                                % Total numer of transmitted nodes
else
    SizeHalo = 0;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FINISH: MACHINE MAPPING
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MyNeighbourRecvProcList = MyNeighbourRecvProcList-1; % -1 because rank is starting at zero
MyNeighbourSendProcList = MyNeighbourSendProcList-1; % -1 because rank is starting at zero

end
