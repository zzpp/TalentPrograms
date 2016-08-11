% Chaining2.m   
%
% How much of growth is due to changing TauW and TauH?
%
% To answer, we chain to compute growth due to TauW and TauH. That is:
%
%    gI(60,70) = Growth rate of Y at A60, phi60, Z60 with just changing TauW and TauH
%    gF(60,70) = Growth rate of Y at A70, phi70, Z70 with just changing TauW and TauH
%     g(60,70) = 1/2*(gI + gF) and cumulate
%
% Note: We have to be careful in handling the cohort variables.
% Note: We are using "Earnings" rather than "Production" as output measure.
%       That is, the sum of (1-tauw)*w*H. Equals production if Revenue=0.
%
%  Let S(t) denote the "state" at date t. This includes A(t) and wH(t), but also 
%  [phi(t) phi(t-1) and phi(t-2)] for older cohorts. Ditto for other cohort variables Z, 
%  TgHome, and TauH.  Think of state as "Y M O" values.
%
%  When solving for GDP(1990 TauH and TauW, but 1980 state for all else), we need to use 
%  Z80, Z70, Z60 for Zy Zm Zold.
%
%  In the LR, we may want to rewrite all programs to include this "state" explicitly.
%  For now, however, I am just trying to be careful and using our "time" approach.
%  This means that only the relevant (e.g. 1980 and 1990) elements of the matrix of Y values 
%  below should be considered. The rest are "junk".
%
% Could we also do the opposite: growth due to A/phi/Z -- how much is left to be attributed to Taus?
% The problem with this second approach is that our model does not fit exactly, so the residual
% calculation is not as useful? Not done currently...

clear; global CaseName;
diarychad('Chaining2',CaseName);

global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData HAllData Decades ExperienceCohortFactor
global TauW_C phi_C mgtilde_C w_C WhatToChain % For keeping track of history in solution

load(['TalentData_' CaseName]); % From EstimateTauZ2 and earlier programs
ShowParameters;

[GrowthShare_TWTH,Gr_geo_TWTH,YBaseline]=chaining('TauWTauH',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
if ~ChainSingleCase;
    [GrowthShare_TH,Gr_geo_TH]=chaining('TauH',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    [GrowthShare_TW,Gr_geo_TW]=chaining('TauW',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    [GrowthShare_BothZ,Gr_geo_BothZ]=chaining('Both+Z',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    [GrowthShare_All4,Gr_geo_All4]=chaining('Both+ZTgHome',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
end;

%sfigure(1); figsetup;
%  Draw a figure showing YBaseline as well as cumulative contributions over time...

    
save(['Chaining2_' CaseName]);
diary off;

