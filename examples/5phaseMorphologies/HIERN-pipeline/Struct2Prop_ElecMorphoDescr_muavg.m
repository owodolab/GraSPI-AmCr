function  [ AveragedMobility ] = Struct2Prop_ElecMorphoDescr_muavg( MobilityMatrix, IndMobETP, penalty, Mode )
% penalty: it is the default, very low mobility value we set at the nodes of the ETP where the mobility is zero when entering the routine
% Mode: defines the way we average
%   Mode 1- Harmonic average on vertical direction per column and then arithmetic average
%   Mode 2- Harmonic average on vertical direction, on the averaged height dependent mobility %
%   Mode 3- Harmonic average on both directions (First vertical then horizontal)
%   Mode 4- Harmonic average on both directions (First horizontal then vertical)
%
% NB Olivier: I only reviewed Mode 1

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preparation
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Indices with non-zero mobilities, in the ETP node list
Ind1 = find(MobilityMatrix(IndMobETP)~=0);
% Indices within ETP and with zero mobilities, in the whole morphology node list 
% Ind2 = find(MorphETP==1 & MobilityMatrix==0);

% Inverse of mobility where it is non-zero
Inversemu = zeros(size(MobilityMatrix));
Inversemu(IndMobETP(Ind1)) = 1./MobilityMatrix(IndMobETP(Ind1)); % inverse on the non zeros values

% % Keep track of the nodes which are in the ETP but where the mobility is zero
% UntransportingETP = zeros(size(MobilityMatrix));
% UntransportingETP(Ind2) = 1;

% Nodes involved in averaging
CountNodes = zeros(size(MobilityMatrix));
CountNodes(IndMobETP) = 1;
% Number of nodes along each vertical line
lengthETP_v=sum(CountNodes,1);
% Number of nodes along each horizontal line
lengthETP_h=sum(CountNodes,2);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Go for averaging
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------
% Mode 1- Harmonic average on vertical direction per column and then arithmetic average
% ---------------------------------------------

if ( Mode==1 )
    
    % Replace zero values within the ETP by a standard, very low value ('penalty') 
    InversemuBlockage = Inversemu;
    % InversemuBlockage(Ind2) = 1/penalty;
    % Harmonic average per column / streamline
    Vectorsum = sum(InversemuBlockage,1);
    mu_v = lengthETP_v(lengthETP_v~=0)./Vectorsum(lengthETP_v~=0);
    % Arithmetic average along all columns / streamlines
    AveragedMobility = mean(mu_v);
    
end

% ---------------------------------------------
% Mode 2- Harmonic average on vertical direction, on the averaged height dependent mobility
% ---------------------------------------------

if ( Mode==2 )
    
    Vectorsum=sum(MobilityMatrix,2);
    mu_h=Vectorsum(lengthETP_h~=0)./lengthETP_h(lengthETP_h~=0);
    mu_h(mu_h==0)=penalty; % peu pobable voire impossible d avoir cette condition
    
    Inversemu_h=1./mu_h;
    Vectorsum=sum(Inversemu_h);
    AveragedMobility=length(Inversemu_h)/Vectorsum;
    
end

% ---------------------------------------------
% Mode 3- Harmonic average on both directions (First vertical then horizontal)
% ---------------------------------------------

if ( Mode==3 )
    
    InversemuBlockage=Inversemu;
    InversemuBlockage(Ind2)=1/penalty;
    Vectorsum=sum(InversemuBlockage);
    
    mu_v=lengthETP_v(lengthETP_v~=0)./Vectorsum(lengthETP_v~=0);
    mu_v(mu_v==0)=penalty;% peu pobable voire impossible d avoir cette condition
    
    Inversemu_v=1./mu_v;
    Vectorsum=sum(Inversemu_v);
    AveragedMobility=length(Inversemu_v)/Vectorsum;
    
end

% ---------------------------------------------
% Mode 4- Harmonic average on both directions (First horizontal then vertical)
% ---------------------------------------------

if ( Mode==4 )
    
    InversemuBlockage=Inversemu;
    InversemuBlockage(Ind2)=1/penalty;
    Vectorsum=sum(InversemuBlockage,2);
    
    mu_h=lengthETP_h(lengthETP_h~=0)./Vectorsum(lengthETP_h~=0);
    
    mu_h(mu_h==0)=penalty; % peu pobable voire impossible d avoir cette condition
    
    Inversemu_h=1./mu_h;
    Vectorsum=sum(Inversemu_h);
    AveragedMobility=length(Inversemu_h)/Vectorsum;
    
end

end

