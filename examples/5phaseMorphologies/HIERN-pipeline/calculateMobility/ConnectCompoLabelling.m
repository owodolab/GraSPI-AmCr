function [ Labels, NDomains ] = ConnectCompoLabelling(IndRelSites, NEI, Ndim, Connectivity)
% This function performs a connected component analysis on a given list of nodes
% I.e. knowing all nodes of a given type (typically a 'phase'), this determines which nodes belong to which distinct domains of this phase
% !!! This is basically a local (on worker) connected component analysis; for parallel handling, additional work must be done, see for instance 'PhaseField_Nuclei_AttributeOrientation'
% 
% INPUTS:
%   - IndRelSites: 1D-array of size NRelSites; list of nodes handled by the local worker, for which we want to perform the connected component analysis
%   - NEI: structure with the neibours (Number of neighbours and list of neighbours of each node of the mesh handled by the local worker)
%   - Ndim: number of active dimensions in the simulation (1, 2 or 3D)
%   - Connectivity: string, mentioning the option for connected component analysis ('close': connected with nearest neighbours only, 'extended': connected with all neighbours (8 in 2D, 26 in 3D))
% OUTPUTS:
%   - Labels: 1D-array of length NRelSites; marks each node of the list IndRelSites with a label corresponding to the domain it belongs to. 
%             The labels are the natural numbers 1...NDomains
%   - NDomains: number of distinct domains detected among the list of nodes IndRelSites

% ---------------------------------------------------------------------
% Choice of Neighbour depending on connectivity option
% ---------------------------------------------------------------------

switch Connectivity
    case 'close'
        ChoosenNeighb = (1:Ndim*2);
    case 'extended'
        ChoosenNeighb = (1:NEI.NNeighb);
end
    
% ---------------------------------------------------------------------
% First pass: loop over new nuclei sites to generate labels
% ---------------------------------------------------------------------

NRelSites = numel(IndRelSites);
labellist = zeros(1,NRelSites);
equivalentlabel = (1:NRelSites);
equivalentlabel = num2cell(equivalentlabel);
Nlabelcurrent = 1;

for ik = 1:NRelSites

    % Find the non-zero labels of the neighbours (among neighbours belonging to the relevant sites, because the other ones won't receive a non-zero label anyway)
    Nocurrentneighbour = intersect(NEI.NoNeighb(IndRelSites(ik),ChoosenNeighb),IndRelSites);
    % Other (faster) solution to be checked: ismembc(A,B) returns 1 for element of A that are in B and 0 for the others
    % tf = ismembc(NEI.NoNeighb(IndRelSites(ik),ChoosenNeighb), IndRelSites);
    % Nocurrentneighbour = NEI.NoNeighb(IndRelSites(ik),tf==1);
    [zozo Indcurrentneighbour] = ismember(Nocurrentneighbour, IndRelSites);
    NoNeighbWithNonZeroLabel = Nocurrentneighbour(labellist(Indcurrentneighbour)>0);
    [zozo IndNeighbWithNonZeroLabel] = ismember(NoNeighbWithNonZeroLabel, IndRelSites);
    label_neighbour = labellist( IndNeighbWithNonZeroLabel );

    % Actualize the labellist and the number of current labels
    labellist(ik) = Nlabelcurrent;
    if ( numel(label_neighbour) == 1 )
        labellist(ik) = label_neighbour;
    end
    if ( numel(label_neighbour) >= 2 )
        labellist(ik) = min(label_neighbour);
        smallerlabel = min(label_neighbour);
        equivalentlabel{smallerlabel} = [equivalentlabel{smallerlabel} label_neighbour(~ismember(label_neighbour,equivalentlabel{smallerlabel}))];
    end
    if ( labellist(ik) == Nlabelcurrent )
        Nlabelcurrent = labellist(ik) + 1;
    end

end

% ---------------------------------------------------------------------
% Draw new orientations
% ---------------------------------------------------------------------

Labels = (1:Nlabelcurrent-1);

% ---------------------------------------------------------------------
% Second pass: take care of equivalent labels
% ---------------------------------------------------------------------

for ll = 1:Nlabelcurrent-1
    Labels(equivalentlabel{ll}) = Labels(ll);
end

% ---------------------------------------------------------------------
% Fill Label variable and find NDomains
% ---------------------------------------------------------------------

Labels = Labels(labellist); % here, the labels are natural number, but not 1...n
UniqueLabels = unique(Labels);
NDomains = numel(UniqueLabels);

% ---------------------------------------------------------------------
% Finally, edit labels so that they are 1...NDomains
% ---------------------------------------------------------------------

for ll = 1:NDomains
    Ind = find(Labels==UniqueLabels(ll));
    Labels(Ind) = ll;
end

end












