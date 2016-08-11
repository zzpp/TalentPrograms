% TestChaining2.m   
%
% How much of growth is due to changing TauW and TauH?  Testing the Chaining2 and Eqm solvers....
%


clear; global CaseName;
CaseName='Benchmark';
diarychad('TestChaining2');

global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData HAllData Decades ExperienceCohortFactor
global TauW_C phi_C mgtilde_C w_C WhatToChain % For keeping track of history in solution

load(['TalentData_' CaseName]); % From EstimateTauZ2 and earlier programs
ShowParameters;


% What if we SolveForEqm using 1960 state and 1970 TauW. Does this really give what Chaining2 does?
%[YBase,EarningsModel,wModel,HModel,HModelAll,pModel,ExitFlag]=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
% YBase=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
% disp ' ';
% TauWnext=TauW;
% TauWnext(:,:,1:5)=TauW(:,:,2:6);
% Ytauw=SolveForEqm(TauH,TauWnext,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
% cshow(' ',[Decades YBase Ytauw],'%9.0f','Year Baseline Y_TauWnext');
%      Year BaselineY_TauWnext
% ---------------------------
%      1960    15642    15617
%      1970    20074    20668
%      1980    19812    20356
%      1990    26280    26211
%      2000    32441    32520
%      2010    35403    35253


% % TAUW 0.4155
% disp ' '; disp ' ';
% disp 'Now, lets see how the chaining looks if we go to uniform 0.4155 TauW = mean in 1960...';
% TauW=ones(size(TauW))*.4155;
% [YModel,EarningsModel,wModel,HModel,HModelAll,pModel,ExitFlag]=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
% Y_halfW=YModel;
% SolveEqmBasic_Display

% load(['SolveEqmBasic_' CaseName]);
% YBaseline=GDPBaseline;
% cshow(' ',[Decades YBaseline Y_halfW],'%9.0f','Year Baseline Y_TauW4155');
%      Year BaselineY_TauW4155
% ---------------------------
%      1960    15642    26656
%      1970    20074    28189
%      1980    19812     9053
%      1990    26280    13590
%      2000    32441    15133
%      2010    35403    15690

% RESULTS IN COMMENT BELOW... OKAY. SMALL IN 1960?
disp ' '; disp ' ';
disp 'Now, lets see how the chaining looks if we go to Zero TauW and TauH (from Benchmark)...';
TauH=zeros(size(TauH));
TauW=zeros(size(TauW));
[YModel,EarningsModel,wModel,HModel,HModelAll,pModel,ExitFlag]=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
Y_zero=YModel;
SolveEqmBasic_Display

load(['SolveEqmBasic_' CaseName]);
YBaseline=GDPBaseline;
cshow(' ',[Decades YBaseline Y_zero],'%9.0f','Year Baseline Y_ZeroTau');
%     Year BaselineY_ZeroTau
% ---------------------------
%      1960    15642    15967
%      1970    20074    23245
%      1980    19812    24645
%      1990    26280    32369
%      2000    32441    38732
%      2010    35403    39317




% FINE.
% disp 'Next, lets see what happens in the NoChange case, ie. 60,60 and 70,70, etc.';
% disp 'This should give zero growth...';
% GrowthShare_TWTH=chaining('NoChange',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma)




% GrowthShare_TWTH=chaining('TauWTauH',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
% if ~ChainSingleCase;
%     chaining('TauH',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
%     chaining('TauW',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
%     chaining('Both+Z',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
%     chaining('Both+ZTgHome',TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma);
% end;

diary off;

