% MasterProgram.m     "The Allocation of Talent and U.S. Economic Growth"
%
%  Main program to generate matlab results for the Talent paper.
%  Calls the other programs in the correct order and conducts robustness checks
%
%  Note: These cases can be run in parallel, e.g. by starting separate matlab sessions
%        and copying the code into a separate program (or just pasting it in interactively).
%
%  Each case takes about 2 hours to run. See the *.log files for results 
%  and *.ps and *.eps for figures. 


% Benchmark
tic
clear all; global CaseName;
CaseName='Benchmark';
SetParameters;
HighQualityFigures=0;
ReadCohortDataWW
EstimateTauZ2
CleanandShowTauAZ
SolveEqmBasic
Chaining2
toc

% abc
% ------------------------------------------

% % Robustness Check: zero out tauh/w in brawny occupations
% tic
% clear all; global CaseName;
% CaseName='NoBrawny';
% SetParameters;
% IgnoreBrawnyOccupations=1;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc

% % Robustness Check: choosing T(i,g) s.t. set tauw(2010)=tauh(2010)=0
% tic
% clear all; global CaseName;
% CaseName='NoFrictions2010';
% SetParameters;
% NoFrictions2010 = 1; 
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc


% % ------------------------------------------

% % WeightPigMiddle=1/2
% tic
% clear all; global CaseName;
% CaseName='WeightPigHalf';
% SetParameters;
% WeightPigMiddle=1/2;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc


% % NoConstrainTauH
% tic
% clear all; global CaseName;
% CaseName='NoConstrainTauH';
% SetParameters;
% ConstrainTauH=-999
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc



% % WeightPigMiddle=1
% tic
% clear all; global CaseName;
% CaseName='WeightPig1';
% SetParameters;
% WeightPigMiddle=1;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc

% % WeightPigMiddle=0
% tic
% clear all; global CaseName;
% CaseName='WeightPig0';
% SetParameters;
% WeightPigMiddle=0;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc



% %  eta=.20
% tic
% clear all; global CaseName;
% CaseName='Eta20';
% SetParameters;
% eta=.20
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc


% %  eta=.05
% tic
% clear all; global CaseName;
% CaseName='Eta05';
% SetParameters;
% eta=.05
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc



% % Robustness: Theta = 4
% tic
% clear all; global CaseName;
% CaseName='Theta4';
% SetParameters;
% theta=4;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc

% % Robustness: Theta = 1.7
% tic
% clear all; global CaseName;
% CaseName='ThetaLow';
% SetParameters;
% theta=1.7;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc


% % LFPMinFactor=1/3
% tic
% clear all; global CaseName;
% CaseName='LFP33';
% SetParameters;
% LFPMinFactor=1/3
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc

% % LFPMinFactor=2/3
% tic
% clear all; global CaseName;
% CaseName='LFP67';
% SetParameters;
% LFPMinFactor=2/3
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc

% abc

% --------------------------------------------------------

% % WageGapAdjustmentFactor=1/2
% tic
% clear all; global CaseName;
% CaseName='WageGapHalf';
% SetParameters;
% WageGapAdjustmentFactor=1/2;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc
% 
% % WageGapAdjustmentFactor=0
% tic
% clear all; global CaseName;
% CaseName='WageGapZero';
% SetParameters;
% WageGapAdjustmentFactor=0;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc
% 
% % HomeExperience = [1 1.2 1.35]
% tic
% clear all; global CaseName;
% CaseName='HomeExperience';
% SetParameters;
% WhatToChain='Output';
% HomeExperience = [1 1.2 1.35];
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc
% 
% % Sigma = 10
% tic
% clear all; global CaseName;
% CaseName='Sigma10';
% SetParameters;
% HighQualityFigures=0;
% sigma=10;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc
% 
% % Sigma = 1.05
% tic
% clear all; global CaseName;
% CaseName='SigmaCobb';
% SetParameters;
% HighQualityFigures=0;
% sigma=1.05
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc
% 
% 
% % Robustness Check: AlphaFixedSplit=1/2 -- Split 50/50 as AlphaSplitTauW1960
% tic
% clear all; global CaseName;
% CaseName='Alpha1960Half';
% SetParameters;
% AlphaFixedSplit=1/2
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc
% 
% 
% % Robustness Check: Splitting TauHat 50/50 in every year into tauw vs tauh
% tic
% clear all; global CaseName;
% CaseName='FiftyFifty';
% SetParameters;
% FiftyFiftyTauHat=1;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc
% 
% 
% 
% 
% % Chaining2VaryTheta
% %  - Benchmark parameters/A's/phi's/tau's but vary theta...
% Chaining2VaryTheta
% 


%------------------------------------------------------------------
%------------------------------------------------------------------
%------------------------------------------------------------------
%------------------------------------------------------------------
%------------------------------------------------------------------



% % TauWWisZero
% tic
% clear all; global CaseName;
% CaseName='TauWWisZero';
% SetParameters;
% HighQualityFigures=0;
% ReadCohortDataWW
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc

% abc


% % Benchmark
% tic
% clear all; global CaseName;
% CaseName='Benchmark';
% SetParameters;
% HighQualityFigures=0;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc

% % To check revenue TauH...
% %  eta=.30
% tic
% clear all; global CaseName;
% CaseName='Eta30';
% SetParameters;
% WhatToChain='Output';
% eta=.30
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% % SolveEqmBasic
% % Chaining2
% % toc

% abc




% % Robustness: Theta = 7
% tic
% clear all; global CaseName;
% CaseName='Theta7';
% SetParameters;
% theta=7;
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc




% % HomeExperience = [1 1.25 1.45]
% tic
% clear all; global CaseName;
% CaseName='HomeExperienceMid';
% SetParameters;
% WhatToChain='Output';
% HomeExperience = [1 1.25 1.45];
% ReadCohortData
% EstimateTauZ2
% CleanandShowTauAZ
% SolveEqmBasic
% Chaining2
% toc

% abc