function [ AllSubsWithHalo ] = DomainDecompo_MappingsPerWorker_HaloNodesSubscripts( nxyz, FlagBC, Halosize, Nblocs, StartStopInd_percpu, ProcNum )
% This function determines the global subscripts of all the nodes (including halo) of a given worker
%
% INPUT:
%   - nxyz: 1*3 array of global mesh size in x, y, z direction, respectively
%   - FlagBC: 1*3 array of flags for boundary conditions in x, y, z direction, respectively
%   - Halosize: size of the halo, in number of nodes (zero or less for sequential computing)
%   - Nblocs: 1*3 array of number of workers in x, y, z direction, respectively
%   - StartStopInd_percpu: Ncpu*6 array with, on each row (corresponding to one worker), the smallest subscript in x, y, z direction, then the highest subscript in x, y, z direction
%   - ProcNum: the number of the considered worker
% OUTPUT:
%   - AllSubsWithHalo is a 1*3 cell containing the x, y and z subscripts, respectively
% UNIT TEST:
%   nxyz = [10 24 1];
%   [ AllShiftDirs ] = Mesh_AllShiftDirs( nxyz ); !!! Not ordered like in the old MeshNoNeighbours; Check carefully whether it's problematic
%   Nblocs=[2 4 1]; Ncpu=prod(Nblocs);
%   [ Core_Carto, StartStopInd_percpu ] = DomainDecompo_MappingsGlobal( nxyz, Ncpu, Nblocs );
%   FlagBC = [0 1 0]; Halosize = 2; ProcNum = 1;
% [ AllSubsWithHalo ] = DomainDecompo_MappingsPerWorker_HaloNodesSubscripts( nxyz, FlagBC, Halosize, Nblocs, StartStopInd_percpu, ProcNum )

AllSubsWithHalo = cell(1,3);

for kk = 1:3
    
    if ( Halosize<=0 )

        if ( nxyz(kk)==1 )
            % If this dimension is not simulated
            AllSubsWithHalo{kk} = 1;
        else
            % No halo
            AllSubsWithHalo{kk} = (StartStopInd_percpu(ProcNum,kk):StartStopInd_percpu(ProcNum,kk+3))';
        end
        
    elseif ( Halosize==1 )
        
        if ( nxyz(kk)==1 )
            % If this dimension is not simulated
            AllSubsWithHalo{kk} = 1;
        elseif ( Nblocs(kk)==1 )
            % If only one bloc along this dimension (no dimension decomposition)
            AllSubsWithHalo{kk} = (StartStopInd_percpu(ProcNum,kk):StartStopInd_percpu(ProcNum,kk+3))';
        else
            % With dimension decomposition and assume periodic boundary
            if ( StartStopInd_percpu(ProcNum,kk)==1 )
                if ( FlagBC(kk)==0 )
                    % Left/Bottom/Front boundary --> include the Right/Top/Back point + next point
                    AllSubsWithHalo{kk} = unique([(StartStopInd_percpu(ProcNum,kk):StartStopInd_percpu(ProcNum,kk+3)+1) nxyz(kk)]);
                else
                    % Left/Bottom/Front boundary + no periodic BC
                    AllSubsWithHalo{kk} = (StartStopInd_percpu(ProcNum,kk):StartStopInd_percpu(ProcNum,kk+3)+1)';
                end
            elseif ( StartStopInd_percpu(ProcNum,kk+3)==nxyz(kk) )
                if ( FlagBC(kk)==0 )
                    % Right/Top/Back boundary --> include the Left/Bottom/Front point + previous point
                    AllSubsWithHalo{kk} = unique([1 (StartStopInd_percpu(ProcNum,kk)-1:StartStopInd_percpu(ProcNum,kk+3))]);
                else
                    % Right/Top/Back boundary + no periodic BC
                    AllSubsWithHalo{kk} = (StartStopInd_percpu(ProcNum,kk)-1:StartStopInd_percpu(ProcNum,kk+3))';
                end
            else
                % Otherwise: add previous and next point
                AllSubsWithHalo{kk} = (StartStopInd_percpu(ProcNum,kk)-1:StartStopInd_percpu(ProcNum,kk+3)+1)';
            end
        end
        
    elseif ( Halosize==2 )
        
        if ( nxyz(kk)==1 )
            % If this dimension is not simulated
            AllSubsWithHalo{kk} = 1;
        elseif ( Nblocs(kk)==1 )
            % If only one bloc along this dimension (no dimension decomposition)
            AllSubsWithHalo{kk} = (StartStopInd_percpu(ProcNum,kk):StartStopInd_percpu(ProcNum,kk+3))';
        else
            % With dimension decomposition and assume periodic boundary
            if ( StartStopInd_percpu(ProcNum,kk)==1 )
                if ( FlagBC(kk)==0 )
                    % Left/Bottom/Front boundary --> include the Right/Top/Back point + next point
                    AllSubsWithHalo{kk} = unique([(StartStopInd_percpu(ProcNum,kk):StartStopInd_percpu(ProcNum,kk+3)+2) nxyz(kk)-1 nxyz(kk)]);
                else
                    % Left/Bottom/Front boundary + no periodic BC
                    AllSubsWithHalo{kk} = (StartStopInd_percpu(ProcNum,kk):StartStopInd_percpu(ProcNum,kk+3)+2)';
                end
            elseif ( StartStopInd_percpu(ProcNum,kk+3)==nxyz(kk) )
                if ( FlagBC(kk)==0 )
                    % Right/Top/Back boundary --> include the Left/Bottom/Front point + previous point
                    AllSubsWithHalo{kk} = unique([1 2 (StartStopInd_percpu(ProcNum,kk)-2:StartStopInd_percpu(ProcNum,kk+3))]);
                else
                    % Right/Top/Back boundary + no periodic BC
                    AllSubsWithHalo{kk} = (StartStopInd_percpu(ProcNum,kk)-2:StartStopInd_percpu(ProcNum,kk+3))';
                end
            else
                % Otherwise: add two previous and next point
                AllSubsWithHalo{kk} = (StartStopInd_percpu(ProcNum,kk)-2:StartStopInd_percpu(ProcNum,kk+3)+2)';
            end
        end
        
    end
       
end

end

