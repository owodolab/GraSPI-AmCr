function [ PointMeshCoordXYZ ] = MeshClosestCoordToPoint(nxyz, dxyz, MeshCoord, PointCoord, FlagBC)
% This function calculate the distance of all grid points to a given point, taking into account possible periodic boundary conditions
%
% INPUT:
%   - nxyz: 3*1 array, the number of points in the mesh in each direction
%   - dxyz: 3*1 array, the grid spacing in each direction
%   - MeshCoord: the Nnodes*3 array of coordinates of the mesh points (three cols for X, Y, and Z)
%   - PointCoord: the 1*3 array of (x, y, z) coordinates of the considered point
%   - FlagBC: 1*3 array of flags for boundary conditions in x, y, z direction, respectively
% OUTPUT:
%   - PointMeshCoordXYZ: the Nnodes*3 array of distances of all grid points to the considered point, taking into account possible periodic boundary conditions
%
% RESTRICTED TO CONSIDERED POINTS THAT ARE INSIDE THE MESH OR DIRECTLY CLOSE TO (< one period)
% NB: for points 1:nx, the coordinates are dx*((1:nx)-0.5)
% Determine the smallest vector between a given point and all the meshpoints, taking into account BC

% ----------------------------------------
% Calculate distance to point in cartesian system
% ----------------------------------------

PointMeshCoordXYZ = zeros(prod(nxyz),3);
PossiblePointMeshCoord_curr = zeros(prod(nxyz),3);
for ii = 1:3
    if (FlagBC(ii)~=0 ) 
        PointMeshCoordXYZ(:,ii) = MeshCoord(:,ii)-PointCoord(ii);
    else
        % vector coordinate possibilities including BC
        PossiblePointMeshCoord_curr(:,1) = MeshCoord(:,ii)-PointCoord(ii);
        PossiblePointMeshCoord_curr(:,2) = MeshCoord(:,ii)-PointCoord(ii)+nxyz(ii)*dxyz(ii);
        PossiblePointMeshCoord_curr(:,3) = MeshCoord(:,ii)-PointCoord(ii)-nxyz(ii)*dxyz(ii);
        [Distbcmin, Indbcmin] = min(abs(PossiblePointMeshCoord_curr),[],2);
        % Find the indices in the concatenated matrix that should be used
        Ind1 = find(Indbcmin==1);
        Ind2 = find(Indbcmin==2);
        Ind3 = find(Indbcmin==3);
        % Get the shorter vector component on the desired dimension
        PointMeshCoordXYZ(Ind1,ii) = PossiblePointMeshCoord_curr(Ind1,1);
        PointMeshCoordXYZ(Ind2,ii) = PossiblePointMeshCoord_curr(Ind2,2);
        PointMeshCoordXYZ(Ind3,ii) = PossiblePointMeshCoord_curr(Ind3,3);
    end
end









