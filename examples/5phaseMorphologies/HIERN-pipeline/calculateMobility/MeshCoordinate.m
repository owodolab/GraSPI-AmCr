function [ MeshCoord ] = MeshCoordinate ( nxyz, dxyz )
% This function calculate the physical coordinates of all grid points in the mesh
%
% INPUT:
%   - nxyz: 3*1 array, the number of points in the mesh in each direction
%   - dxyz: 3*1 array, the grid spacing in each direction
% OUTPUT:
%   - MeshCoord: the Nnodes*3 array of coordinates of the mesh points (three cols for X, Y, and Z)

% ----------------------------------------
% Generate 3D matrix G:
% ----------------------------------------

G=(1:nxyz(1)*nxyz(2)*nxyz(3))';
G = reshape(G,nxyz(1),nxyz(2),nxyz(3));

% ----------------------------------------
% Write Coordinates
% ----------------------------------------

i1 = 1:nxyz(1) ; 
j1 = 1:nxyz(2) ;
k1 = 1:nxyz(3) ;

[Y,X,Z] = meshgrid(j1-0.5,i1-0.5,k1-0.5); % /!\ order Y,Z,X

X = dxyz(1)*X;
Y = dxyz(2)*Y;
Z = dxyz(3)*Z;

% ----------------------------------------
% Reshape
% ----------------------------------------

X = reshape(X,nxyz(1)*nxyz(2)*nxyz(3),1);
Y = reshape(Y,nxyz(1)*nxyz(2)*nxyz(3),1);
Z = reshape(Z,nxyz(1)*nxyz(2)*nxyz(3),1);

MeshCoord = [X Y Z];



