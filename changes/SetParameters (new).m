% SetParameters.m
%
%  Sets the Benchmark basic parameters for the Talent project

% Make sure all relevant files are in path
curpath=path;
if isempty(strfind(curpath,'ChadMatlab'));% | isempty(strfind(curpath,'Work/procs'));
    if exist('ChadMatlab')==7; 
        curdir=pwd;
        path([curdir '/ChadMatlab'],path); 
    end; 
end;
if isempty(strfind(curpath,'ZihoMatlab'));% | isempty(strfind(curpath,'Work/procs'));
    if exist('ZihoMatlab')==7; 
        curdir=pwd;
        path([curdir '/ZihoMatlab'],path); 
    end; 
end;

% Parameters:

    eta=0.103;
    theta=2.12;
    %theta=KeyThetaParam/(1-eta);
    
    % On beta: Weight in utility on log(c) versus log(1-s) - 3 period model
    % In the new 4/4/16 lifecycle version, beta is replaced by 3*beta, so I'm just
    % making that adjustment here rather than replacing beta with 3*beta in all programs
    % that follow ==> it stays at 0.693.
    beta=3*0.693/3;  
    sigma=3;
    HOME=1;
    WhatToChain='Output'; % 'Output' and 'Earnings' are the alternatives
    FiftyFiftyTauHat=0; % Turn this on for robustness to split tauhat 50/50 in every year
    IgnoreBrawnyOccupations=0; % Turn this on for robustness to zero out tauh/w in brawny occupations
    NoFrictions2010=0;  % Turn this on for robustness to choose T(i,g,2010) s.t. set tauw(2010)=tauh(2010)=0.    
    LFPMinFactor=0.5;   % In eval_young, adjust TgHome so that PworkYoung is not below .5*Target
    WageGapAdjustmentFactor=1; % Fraction of Wage Gap to preserve. Zero ==> use Earnings(WM)
    AlphaFixedSplit=0;  % Alternative is e.g. AlphaFixedSplit=0.5 to use that AlphaSplitTauW1960 value and not iterate
    phiFarm=flipud([   % From Pete, 2/25/16
 	1.3774   % 2010	
 	1.4463   % 2000	
 	1.4251   % 1990	
 	1.303   % 1980	
 	1.1759   % 1970	
 	0.9984   % 1960	
     ])

    %EvalYoungStartRange=[.001 .03];  % For use in estimatetauz in calling eval_young
    ChainSingleCase=0; % Turn on if we only wish to chain the TauWTauH case
    HighQualityFigures=0; % Turn on to place labels in certain figures ==> programs wait for user input
    WeightPigMiddle=1/4;  % Weight on Pig (vs WageGrowth) in eval_middle.m
                          
    %AlphaSplitTauW1960=0.21; % Initial split of tauhat into TauW (versus TauH) in 1960
    SameExperience=1;  % Defaults is same returns to experience in all occs
    HomeExperience=[1 1.3 1.5]; % Returns to experience at home if SameExperience==0
    ConstrainTauH=-0.8;  % Lower bound on how negative TauH can get (meaningless if below -1). -999=unconstrained