% Chaining2VaryTheta.m   
%
%  Use the Benchmark case estimates of A's/phi's/tau's -- no reestimation --
%  and allow THETA to vary.
%
%  How does the chaining calculation look in that case?

clear; global CaseName;
diarychad('Chaining2VaryTheta');
CaseName='Benchmark' % Use the benchmark A's, phi's, tau's

global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData HAllData Decades ExperienceCohortFactor
global TauW_C phi_C mgtilde_C w_C WhatToChain % For keeping track of history in solution

load(['TalentData_' CaseName]); % From EstimateTauZ2 and earlier programs

ThetaValues=[1.9 2.12 3 4 5]'
ChainSingleCase=1
GrowthShare=zeros(length(ThetaValues),1);

for i=1:length(ThetaValues);
    theta=ThetaValues(i);
    ShowParameters;

    [GrowthShare_TWTH,Gr_geo_TWTH,YBaseline]=chaining('TauWTauH',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    GrowthShare(i)=GrowthShare_TWTH(1);

    %    if ~ChainSingleCase;
    %    [GrowthShare_TH,Gr_geo_TH]=chaining('TauH',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    %    [GrowthShare_TW,Gr_geo_TW]=chaining('TauW',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    %    [GrowthShare_BothZ,Gr_geo_BothZ]=chaining('Both+Z',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    %    [GrowthShare_All4,Gr_geo_All4]=chaining('Both+ZTgHome',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    %end;
end;

cshow(' ',[ThetaValues GrowthShare],'%12.3f','Theta GrowthShare');

definecolors;
figure(1); figsetup;
plot(ThetaValues,GrowthShare,'-','Color',myblue);
hold on;
plot(ThetaValues,GrowthShare,'o','Color',mygreen);
chadfig2('Theta','Share of growth due to tau_w and tau_h',1,0)
print Chaining2VaryTheta.eps
    
save(['Chaining2VaryTheta']);
diary off;

  % Theta  Share of Growth
  %   1.90      12.1
  %   2.12      26.0
  %   3.00      68.1
  %   4.00     101.3
  %   5.00     130.1

