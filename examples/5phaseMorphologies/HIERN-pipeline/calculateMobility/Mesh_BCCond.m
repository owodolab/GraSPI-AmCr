function [ CNPhim, CNOrParm, CNAlphaGradm, CNAlphaVapGradm, FlowsPhi, FlowsOrPar, FlowsMu, FlowsHeight ] = Mesh_BCCond ( NSpecies, Nnodes, NNonLiqPhase, NCryst, NOriFields, NVap, Ndim, dxyz, BCNodes, Nozdim, FlowPhiz0, FlowPhizmax, FlowOrParz0, FlowOrParzmax, FlowMuz0, FlowMuzmax, Flag )
% This function prepares easy-to-handle variables containing the data on boundary conditions, from the user-defined variables found in the input files
%
% INPUT:
%   - NSpecies: the number of species/materials
%   - Nnodes: the number of nodes handled by the considered worker (owned+halo nodes)
%   - NNonLiqPhase: the number of species/materials potentially having a crystalline or vapor phase
%   - NCryst: the number of crystallizing species/materials
%   - NOriFields: the number of orientation fields for crystalline materials
%   - NVap: the number of vapor materials
%   - Ndim: number of active dimensions in the simulation (1, 2 or 3D)
%   - dxyz: 3*1 array, the grid spacing in each direction
%   - BCNodes: 3*2 cell array with the list of nodes of the worker which are located at the domain boundaries
%   - Nozdim: the number of the vertical (z) dimension among the active dimensions
%   - FlowPhiz0: 1*NSpecies 1D-array, the volume fraction flux conditions at the lower boundary, z=z0
%   - FlowPhizmax: 1*NSpecies 1D-array, the volume fraction flux conditions at the upper boundary, z=zmax
%   - FlowOrParz0: 1*NSpecies 1D-array, the order parameter flux conditions at the lower boundary, z=z0
%   - FlowOrParzmax: 1*NSpecies 1D-array, the order parameter flux conditions at the upper boundary, z=zmax
%   - FlowMuz0: 1*NSpecies 1D-array, the evaporation/condensation flux condition at the lower boundary, z=z0
%   - FlowMuzmax: 1*NSpecies 1D-array, the evaporation/condensation flux condition at the upper boundary, z=zmax
%   - Flag: structure containing the flag values for activation of all the sode options
%
% OUTPUT:
%   - CNPhim: Nnodes*NSpecies array with the flux boundary conditions for volume fractions at the boundary nodes, zero elsewhere
%   - CNOrParm: Nnodes*NSpecies array with the flux boundary conditions for order parameters at the boundary nodes, zero elsewhere
%   - CNAlphaGradm: Nnodes*NOriFields array with the flux boundary conditions for orientation parameters at the boundary nodes, zero elsewhere
%   - CNAlphaVapGradm: Nnodes*1 array with the flux boundary conditions for the vapor orientation parameter at the boundary nodes, zero elsewhere
%   - FlowsPhi: (Ndim*2)*NSpecies array with the (homogeneous) flux boundary conditions for volume fractions at the boundaries (first the lower boundaries in x, y, z direction, then the upper boundaries in x, y, z direction)
%   - FlowsOrPar: (Ndim*2)*NSpecies array with the (homogeneous) flux boundary conditions for order parameters at the boundaries (first the lower boundaries in x, y, z direction, then the upper boundaries in x, y, z direction)
%   - FlowsMu: (Ndim*2)*NSpecies array with the (homogeneous) evaporation/condensation flux conditions at the boundaries (first the lower boundaries in x, y, z direction, then the upper boundaries in x, y, z direction)
%   - FlowsHeight: (Ndim*2*1) array of zeros

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Boundary condition arrays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arrays defined on all (local) nodes that are non zero only at the boundaries

if ( NSpecies>1 )
    % Conversion of BC for Laplacian
    CNPhim = zeros(Nnodes,NSpecies);
    for ii = 1:NSpecies
        CNPhim(BCNodes{3,1},ii) = -FlowPhiz0(ii)/dxyz(3);
        CNPhim(BCNodes{3,2},ii) = FlowPhizmax(ii)/dxyz(3);
    end
else
    CNPhim = [];
end

if ( NNonLiqPhase>0 )
    % Conversion of BC for Laplacian
    CNOrParm = zeros(Nnodes,NSpecies);
    for ii = 1:NSpecies
        CNOrParm(BCNodes{3,1},ii) = -FlowOrParz0(ii)/dxyz(3);
        CNOrParm(BCNodes{3,2},ii) = FlowOrParzmax(ii)/dxyz(3);
    end
else
    CNOrParm = [];
end

if ( NCryst>0 && Flag.Cristal.Oriented>=1 )
    % Conversion of BC for Gradient
    CNAlphaGradm = zeros(Nnodes,NOriFields);
    for ii = 1:NOriFields
        CNAlphaGradm(BCNodes{3,1},ii) = 0;%FlowAlphaz0(ii);
        CNAlphaGradm(BCNodes{3,2},ii) = 0;%FlowAlphazmax(ii);
    end
else
    CNAlphaGradm = [];
end

if ( NCryst>0 && NVap>0 && Flag.ImpingeVap==1 )
    % Conversion of BC for Gradient
    CNAlphaVapGradm = zeros(Nnodes,1);
else
    CNAlphaVapGradm = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'Modern version' of the boundary conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Have to merge that with the previous section...

FlowsPhi = zeros(Ndim*2,NSpecies);
FlowsOrPar = zeros(Ndim*2,NSpecies);
FlowsMu = zeros(Ndim*2,NSpecies);
FlowsHeight = zeros(Ndim*2,1);

if ( Flag.SimpleEvap==0 )
    % Needed for the evaluation of CH mobilities
    FlowsPhi(Nozdim,:) = FlowPhiz0;
    FlowsPhi(2*Nozdim,:) = FlowPhizmax;
    % Needed also for the evaluation of CH mobilities
    FlowsOrPar(Nozdim,:) = FlowOrParz0;
    FlowsOrPar(2*Nozdim,:) = FlowOrParzmax;
    % Needed also for the evaluation of CH mobilities
    FlowsMu(Nozdim,:) = FlowMuz0;
    FlowsMu(2*Nozdim,:) = FlowMuzmax;
end

end

