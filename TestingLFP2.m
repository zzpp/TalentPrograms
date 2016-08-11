% TestingLFP2.m
%
%   Test *across* parameter values: e.g. a range of eta values
%   to make sure the chaining results are smooth/continuous.




% LFPMinFactor=0.581
clear all; global CaseName;
CaseName='LFP581';
SetParameters;
LFPMinFactor=0.581
ReadCohortData
EstimateTauZ2

% LFPMinFactor=0.585
clear all; global CaseName;
CaseName='LFP585';
SetParameters;
LFPMinFactor=0.585
ReadCohortData
EstimateTauZ2



abc

% TEST 
clear all; global CaseName;
CaseName='TestLFP2';

ParamName='LFPMinFactor';   
ParamRange=[.556 .593]
NumPoints=8  % In addition to endpoints
Param=interplin(ParamRange',NumPoints);
GrowthShare=zeros(length(Param),1);


iCounter=1;

while iCounter<=length(Param);
    save iCounterTestingLFP2 iCounter ParamName Param GrowthShare;
 
    clear; global CaseName; % To clear out *previous* run from earlier iters
    load iCounterTestingLFP2;
    SetParameters;
    ChainSingleCase=1;
    LFPMinFactor=Param(iCounter);
    ReadCohortData
    EstimateTauZ2
    CleanandShowTauAZ
    SolveEqmBasic
    Chaining2
    load iCounterTestingLFP2
    GrowthShare(iCounter)=GrowthShare_TWTH(1)
    iCounter=iCounter+1;
end;

diarychad('TestingLFP2');
cshow(' ',[Param GrowthShare],'%12.3f',[ParamName ' GrowthShare']);

definecolors;
figure(1); figsetup;
plot(Param,GrowthShare,'-','Color',myblue);
hold on;
plot(Param,GrowthShare,'o','Color',mygreen);
chadfig2(ParamName,'Share of growth due to tau_w and tau_h',1,0)
print TestingLFP2.eps
diary off;
