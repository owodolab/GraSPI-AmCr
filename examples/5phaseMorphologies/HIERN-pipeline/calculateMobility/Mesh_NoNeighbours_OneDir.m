function [ NoNeighbours ] = Mesh_NoNeighbours_OneDir( Nodes_Carto, nxyz, FlagBC, ShiftDir )
% This function determines the indices of the neighbours of a list of nodes in a given directions
%
% INPUT:
%   - nxyz: 1*3 array of global mesh size in x, y, z direction, respectively
%   - FlagBC: 1*3 array of flags for boundary conditions in x, y, z direction, respectively
%   - Nodes_Carto: Nelem*4 array (Nelem being the total number of nodes); the first column contains the global indices of the nodes, the three next columns are the global subscripts in x, y, z direction, respectively 
%   - ShiftDir: 1*3 array of shifts (+/-1) in x, y, z direction, respectively
% OUTPUT:
%   - NoNeighbours: Nelem*2 array containing the global indices of the nodes and the global indices of their neighbours
% UNIT TEST:
%   nxyz = [4 8 4]; Nblocs=[4 4 2]; Ncpu=prod(Nblocs);
%   [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
%   [ NoNeighbours ] = Mesh_NoNeighbours_OneDir( Core_Carto, Nblocs, [0 0 1], [+1 0 0] )
%   [ NoNeighbours ] = Mesh_NoNeighbours_OneDir( Core_Carto, Nblocs, [0 0 1], [0 0 +1] )
%   [ NoNeighbours ] = Mesh_NoNeighbours_OneDir( Core_Carto, Nblocs, [0 0 1], [0 0 -1] )

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Shift the position vs. initial nodes
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nodes_Subs = Nodes_Carto(:,2:4);    % Get the subscripts
Nodes_Subs = Nodes_Subs + ShiftDir; % Shift in the desired direction

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle boundary conditions on subscripts
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for idim = 1:3

    Subscurr = Nodes_Subs(:,idim);
    if ( FlagBC(idim)==0 ) % Assume periodic boundary conditions in the idim-th direction
        Subscurr(Subscurr==0) = nxyz(idim);
        Subscurr(Subscurr==nxyz(idim)+1) = 1;
        Nodes_Subs(:,idim) = Subscurr;
    else
        Subscurr(Subscurr==0) = nan;
        Subscurr(Subscurr==nxyz(idim)+1) = nan;
        Nodes_Subs(:,idim) = Subscurr;
    end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identify incices
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Zeros where there is no Neighbour (historical code convention)

% Handling of nans (stupid octave cannot do this on its own)
Indok = find(isnan(prod(Nodes_Subs,2))==0);

% Indices of workers
Nelem = size(Nodes_Carto,1);
NoNeighbours = zeros(Nelem,2);
NoNeighbours(:,1) = Nodes_Carto(:,1);
NoNeighbours(Indok,2) = sub2ind(nxyz,Nodes_Subs(Indok,1),Nodes_Subs(Indok,2),Nodes_Subs(Indok,3));

end
