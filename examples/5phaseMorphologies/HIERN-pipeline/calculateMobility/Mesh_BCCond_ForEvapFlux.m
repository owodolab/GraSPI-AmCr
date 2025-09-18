function [ DeltaPhiBC, PhiBCold, FlowLHSFactBC, SignBC_ini, ActivateFlowCorrHighPhi ] = Mesh_BCCond_ForEvapFlux( NSpecies, NEvaporatingSolvent )
% This function provides specific boundary conditions for the evaporation flux at the top boundary
% At the moment, only initialized to all-zero values
% For the meaning of these variables, see [ Eq.24 in ACS Appl. Mater. Interfaces 2021, 13, 55988−56003 // Eq.17 Adv. Theory Simul. 2022, 2200286 ]
%
% INPUT:
%   - NSpecies: the number of species/materials
%   - NEvaporatingSolvent: the number of materials whose volume is not conserved in the box because they evaporate/condensate; the 'air' is excluded from this list 
% OUTPUT:
%   - DeltaPhiBC: 3*2 cell (for 3 dimensions lower/upper boundary), each cell member a 1*NSpecies 1D-array, volume fraction variation in the vapor phase during a single time step
%   - PhiBCold: 3*2 cell (for 3 dimensions lower/upper boundary), each cell member a 1*NSpecies 1D-array, average volume fraction in the vapor phase at previous time step
%   - FlowLHSFactBC: [ currently unused ] 3*2 cell (for 3 dimensions lower/upper boundary), each cell member a 1*NSpecies 1D-array
%   - SignBC_ini: 3*2 cell (for 3 dimensions lower/upper boundary), each cell member a 1*NSpecies 1D-array, sign of the initial evaporation/condensation flux (>0 ==> evaporation, <0 ==> condensation)
%   - ActivateFlowCorrHighPhi: 3*2 cell (for 3 dimensions lower/upper boundary), each cell member a 1*NEvaporatingSolvent 1D-array, flag for activation of the correction to the flux (flux limitation) when the solute volume fraction becomes very high or the sign of the flux begins to oscillate

DeltaPhiBC = cell(3,2);     % initialize
PhiBCold = cell(3,2);     % initialize
FlowLHSFactBC = cell(3,2);     % initialize
SignBC_ini = cell(3,2);     % initialize
ActivateFlowCorrHighPhi = cell(3,2); % Prefactor for activation high-Phi corrections for evaporating solvents
for nn = 1:3
    for mm = 1:2
        DeltaPhiBC{nn,mm} = zeros(1,NSpecies);
        PhiBCold{nn,mm} = zeros(1,NSpecies);%Phim(BCNodes{nn,mm},:);
        FlowLHSFactBC{nn,mm} = zeros(1,NSpecies);%zeros(numel(BCNodes{nn,mm}),NSpecies);
        SignBC_ini{nn,mm} = zeros(1,NSpecies);%zeros(numel(BCNodes{nn,mm}),NSpecies);
        ActivateFlowCorrHighPhi{nn,mm} = zeros(1,NEvaporatingSolvent);%zeros(numel(BCNodes{nn,mm}),NEvaporatingSolvent);
    end
end

end

