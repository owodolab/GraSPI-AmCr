function [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs )
% This function determines the global mappings related to the workers, for a given domain decomposition
%
% INPUT:
%   - nxyz: 1*3 array of global mesh size in x, y, z direction, respectively
%   - Ncpu: total number of workers
%   - Nblocs: 1*3 array of number of workers in x, y, z direction, respectively
% OUTPUT:
%   - Core_Carto: Ncpu*4 array containing the mappings of the workers in the decomposition of the cartesion grid: Core_Carto(:,1) is the worker indices, Core_Carto(:,2:4) are the worker subscript/position along x, y and z, respectively
%   - StartStopInd_percpu: Ncpu*6 array with, on each row (corresponding to one worker), the smallest node subscript in x, y, z direction, then the highest node subscript in x, y, z direction
% UNIT TEST:
%   nxyz = [4 8 1]; Ncpu=8; Nblocs=[2 4 1];
%   [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs )

disp('Domain decomposition, global...')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ( prod(Nblocs) ~= Ncpu )
    error('Bad bloc number')
end
if ( isempty(find((mod(nxyz,Nblocs)==0)==0))==0 )
    error('Bad blocs size')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General variables and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BlocSize = nxyz./Nblocs;        % Size of blocs along each direction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cartography of workers: indices and subscripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determines the positions of the workers in the decomposition of the cartesion grid

[ Core_Carto ] = DomainDecompo_IndSub_PerDomain({[(1:Nblocs(1))];[(1:Nblocs(2))];[(1:Nblocs(3))]},Nblocs); % Core_Carto(:,1) is the worker number, Core_Carto(:,2:4) is the worker position along x, y and z

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Maximum number of neighbouring workers for the given decomposition
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % Check the splitting/decomposition along each dimension
% IsDim = find(nxyz~=1);                          % Dimensionality
% IsNotDim = find(nxyz==1);                       % Dimensionality
% IsSplitDim = find(nxyz>1 & Nblocs>1);           % Is the dimension split into several blocs?
% NSplitDim = numel(IsSplitDim);                  % Number of split dimensions
% Nbloc2 = length(find(Nblocs(IsSplitDim)==2));   % Number of dimensions that are split into two blocs only
% 
% % Matrix of possible numbers of neighbours
% % - in 1D (first col), 2D (second col), 3D (third col)
% % - depending how many dimensions are split in only 2 blocs: none (first row), one dim (second row), two dim (third row), three dim (fourth row)
% Mat_Nsplitdim_Nbloc = zeros(4,3);
% Mat_Nsplitdim_Nbloc(1,:) = 3.^(1:3)-1;                              % Normal neighbour number
% Mat_Nsplitdim_Nbloc(2,:) = Mat_Nsplitdim_Nbloc(1,:)-3.^((1:3)-1);   % With one direction splitted only in two
% Mat_Nsplitdim_Nbloc(3,:) = [0 3 11];                                % With two directions splitted only in two
% Mat_Nsplitdim_Nbloc(4,:) = [0 0 7];                                 % With three directions splitted only in two
% Mat_Nsplitdim_Nbloc;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start and end nodes indices along each dim for each proc
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find start and stop indices for each dimension
StopIndxyz = cell(1,3);
StartIndxyz = cell(1,3);
for ii = 1:3
    StopIndxyz{ii} = BlocSize(ii)*(1:Nblocs(ii))';
    StartIndxyz{ii} = StopIndxyz{ii}-BlocSize(ii)+1;
end

% List of start and stop indices per cpu with COFRA...
% Result: StartStopInd_percpu with Ncpu lines and 6 columns ( start indices in 3 dir, stop indices in 3 dir)
StartInd=cell(0,0);
StopInd=cell(0,0);
for ii=1:3
    StartInd.X{ii}=StartIndxyz{ii};
    StartInd.sizeX(ii)=numel(StartInd.X{ii});
    StopInd.X{ii}= StopIndxyz{ii};
    StopInd.sizeX(ii)=numel(StopInd.X{ii});
end
[ StartInd ] = CompileProduct( StartInd );
[ StopInd ] = CompileProduct( StopInd );

StartStopInd_percpu = [ StartInd.Xcat  StopInd.Xcat ];

clear StartInd StopInd StartIndxyz StopIndxyzGlobal % clear useless variables

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We're done...
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Domain decomposition, global... done')

end

