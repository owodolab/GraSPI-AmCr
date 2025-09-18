function [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz )
% This function determines the vectors of all possible shift directions to a next neighbour in a mesh, depending on dimensionality
%
% INPUTS:
%   - nxyz: 3*1 array, the number of points in the mesh in each direction
% OUTPUTS:
%   - AllShiftDirs: Ndirs*3 array with the list of all shift directions. One shift direction is a 1*3 array with -1/0/+1 in x, y, z duirections, respectively
% UNIT TEST:
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( [5 1 1] )
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( [1 5 1] )
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( [1 1 5] )
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( [5 5 1] )
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( [5 1 5] )
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( [1 5 5] )
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( [5 4 3] )

dims = find(nxyz>1); % dimensions that are meshed
Ndim = numel(dims);  % Dimensionality
SignDoUp = [-1 1];

AllShiftDirs = zeros(3.^Ndim-1,3);
count = 0;
for idim = 1:Ndim
    for iud = 1:2
        count = count+1;
        AllShiftDirs(count,dims(idim)) = SignDoUp(iud);
    end
end
if ( Ndim==2 )
    % Add the 4 in-plane corners
    for iud = 1:2
        for iud2 = 1:2
            count = count+1;
            AllShiftDirs(count,dims([1 2])) = [SignDoUp(iud2) SignDoUp(iud)];
        end
    end
end
if ( Ndim==3 )
    % For each plane, the 4 in-plane corners
    % (For dim x the corners in the xy plane, for dim y the corners in the yz plane,, for dim z the corners in the zx plane 
    idimperm = [[1 2];[1 3];[2 3]];
    for idim = 1:3
        for iud = 1:2
            for iud2 = 1:2
                count = count+1;
                AllShiftDirs(count,dims(idimperm(idim,:))) = [SignDoUp(iud2) SignDoUp(iud)];
            end
        end
    end
    % The 8 out-of-plane corners
    % Starting from the 4 corners in the xy plane: their neighbours in the z direction
    for iud = 1:2
        for iud2 = 1:2
            for iud3 = 1:2
                count = count+1;
                AllShiftDirs(count,:) = [SignDoUp(iud3) SignDoUp(iud2) SignDoUp(iud)];
            end
        end
    end
end

end

