function [ Workers ] = DomainDecompo_WhichWorker_OwnsNodes( IndSubsArray, nxyz, Nblocs )
% This function determines the worker a list of nodes belong to
%
% INPUT:
%   - nxyz: 1*3 array of global mesh size in x, y, z direction, respectively
%   - Nblocs: 1*3 array of number of workers in x, y, z direction, respectively
%   - IndSubsArray: Nelem*4 array (Nelem being the total number of nodes); the first column contains the global indices of the nodes, the three next columns are the global subscripts in x, y, z direction, respectively 
% OUTPUT:
%   - Workers: Nelem*2 array containing the global indices of the nodes (in the mesh) and the indices of the workers (in the domain decomposition) the nodes belong to
% UNIT TEST:
%   nxyz = [4 8 1]; Ncpu=8; Nblocs=[2 4 1];
%   IndSubsArray = [
%      3     3     1     1
%      4     4     1     1
%      7     3     2     1
%      8     4     2     1
%      9     1     3     1
%     10     2     3     1
%     11     3     3     1
%     12     4     3     1
%     29     1     8     1
%     30     2     8     1
%     31     3     8     1
%     32     4     8     1];
%   [ Workers ] = DomainDecompo_WhichWorker_OwnsNodes( IndSubsArray, nxyz, Nblocs )

% Sizes
BlocSize = nxyz./Nblocs;        % Size of blocs along each direction
Nelem = size(IndSubsArray,1);

% Identification of the worker subscripts
SubsWorker = zeros(Nelem,3);
for idim = 1:3
    SubsWorker(:,idim) = floor((IndSubsArray(:,idim+1)-1)/BlocSize(idim))+1;
end

% Indices of workers
Workers = zeros(Nelem,2);
Workers(:,1) = IndSubsArray(:,1);
Workers(:,2) = sub2ind(Nblocs,SubsWorker(:,1),SubsWorker(:,2),SubsWorker(:,3));

end