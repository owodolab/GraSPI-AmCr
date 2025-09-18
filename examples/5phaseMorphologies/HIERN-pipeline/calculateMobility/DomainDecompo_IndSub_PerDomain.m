function [ IndAndSub ] = DomainDecompo_IndSub_PerDomain( Subs, nxyz )
% This function determines the global indices of bloc sub-domains of the regular mesh.
% INPUT:
%   - nxyz: 3*1 array of global mesh size in x, y, z direction, respectively
%   - Subs: 3*1 cell array of subscripts in x, y, z direction, respectively, which define the cubic blocs in space 
% OUTPUT:
%   - IndAndSub: Nelem*4 array (Nelem being the total number of sub-domain elements); 1st column are the global indices, the three next columns the subscripts in x, y, z direction, respectively 
% UNIT TEST:
%   Nblocs = [3 4 2];
%   [ Core_Carto ] = DomainDecompo_IndSub_PerDomain({[2];[(1:Nblocs(2))];[(1:Nblocs(3))]},Nblocs)

% Number of local nodes
Nelem = numel(Subs{1})*numel(Subs{2})*numel(Subs{3});                              

% Generate the meshgrid subscript arrays
[X,Y,Z] = meshgrid(Subs{2},Subs{1},Subs{3});                                        % /!\ Careful, inversion x and y dir due to matlab starnge storage order

% Reshape in 3 cols for subscripts in X, Y, and Z direction respectively
IndAndSub = zeros(Nelem,4);
IndAndSub(:,2:4) = [reshape(Y,Nelem,1) reshape(X,Nelem,1) reshape(Z,Nelem,1)];    % 3 col array with global (ii,jj,kk) subscripts of each node of bloc /!\ Careful, inversion x and y dir due to matlab strange storage order, once again

% Calculate linear indices
IndAndSub(:,1) = sub2ind(nxyz,IndAndSub(:,2),IndAndSub(:,3),IndAndSub(:,4));

% Sort in ascending order of indices (I think this is already sorted before, but go on the safe side: it's important for communication!
IndAndSub = sortrows(IndAndSub,1);

end
