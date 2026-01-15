function  mu=HarmonicAverage(Matrix,IndMobETP,MorphETP,penalty,Mode) 
% Mode 1- Harmonic average on vertical direction per column and then average 
% Mode 2- Harmonic average on vertical direction, on the averaged height dependent mobility %
%Mode 3- Harmonic average on both directions (First vertical then horizontal)
%%Mode 4  Harmonic average on both directions (First horizontal then vertical)

Ind1=find(Matrix(IndMobETP)==0);
Ind2=find(Matrix(IndMobETP)~=0);

Inversemu=zeros(length(Matrix(:,1)),length(Matrix(1,:)));
Inversemu(IndMobETP(Ind2))=1./Matrix(IndMobETP(Ind2)); % inverse on the non zeros values

UntransportingETP=zeros(length(Matrix(:,1)),length(Matrix(1,:)));
Ind3=find(MorphETP==1 & Matrix==0);
UntransportingETP(Ind3)=1;
lengthETP_v=sum(MorphETP);
lengthETP_h=sum(MorphETP,2);

if Mode==1
InversemuBlockage=Inversemu;
InversemuBlockage(Ind3)=1/penalty;
Vectorsum=sum(InversemuBlockage);
mu_v=lengthETP_v(lengthETP_v~=0)./Vectorsum(lengthETP_v~=0);
mu=mean(mu_v);

end

if Mode==2
    
Vectorsum=sum(Matrix,2);
mu_h=Vectorsum(lengthETP_h~=0)./lengthETP_h(lengthETP_h~=0);
mu_h(mu_h==0)=penalty; % peu pobable voire impossible d avoir cette condition

Inversemu_h=1./mu_h;
Vectorsum=sum(Inversemu_h);
mu=length(Inversemu_h)/Vectorsum;

end
if Mode==3
InversemuBlockage=Inversemu;    
InversemuBlockage(Ind3)=1/penalty;
Vectorsum=sum(InversemuBlockage);

mu_v=lengthETP_v(lengthETP_v~=0)./Vectorsum(lengthETP_v~=0);
mu_v(mu_v==0)=penalty;% peu pobable voire impossible d avoir cette condition

Inversemu_v=1./mu_v;
Vectorsum=sum(Inversemu_v);
mu=length(Inversemu_v)/Vectorsum;

end

if Mode==4

InversemuBlockage=Inversemu;
InversemuBlockage(Ind3)=1/penalty;
Vectorsum=sum(InversemuBlockage,2);

mu_h=lengthETP_h(lengthETP_h~=0)./Vectorsum(lengthETP_h~=0);

mu_h(mu_h==0)=penalty; % peu pobable voire impossible d avoir cette condition

Inversemu_h=1./mu_h;
Vectorsum=sum(Inversemu_h);
mu=length(Inversemu_h)/Vectorsum;




end
end

