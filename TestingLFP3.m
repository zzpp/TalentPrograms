% TestingLFP3.m
%
%   Test *across* parameter values: e.g. a range of eta values
%   to make sure the chaining results are smooth/continuous.


% TEST 
clear all; global CaseName;
CaseName='TestLFP3';

ParamName='LFPMinFactor';   
ParamRange=[.400 .450]
NumPoints=8  % In addition to endpoints
Param=interplin(ParamRange',NumPoints);
GrowthShare=zeros(length(Param),1);


iCounter=1;

while iCounter<=length(Param);
    save iCounterTestingLFP3 iCounter ParamName Param GrowthShare;
 
    clear; global CaseName; % To clear out *previous* run from earlier iters
    load iCounterTestingLFP3;
    SetParameters;
    ChainSingleCase=1;
    LFPMinFactor=Param(iCounter);
    ReadCohortData
    EstimateTauZ2
    CleanandShowTauAZ
    SolveEqmBasic
    Chaining2
    load iCounterTestingLFP3
    GrowthShare(iCounter)=GrowthShare_TWTH;
    iCounter=iCounter+1;
end;

diarychad('TestingLFP3');
cshow(' ',[Param GrowthShare],'%12.3f',[ParamName ' GrowthShare']);

definecolors;
figure(1); figsetup;
plot(Param,GrowthShare,'-','Color',myblue);
hold on;
plot(Param,GrowthShare,'o','Color',mygreen);
chadfig2(ParamName,'Share of growth due to tau_w and tau_h',1,0)
print TestingLFP3.eps
diary off;
