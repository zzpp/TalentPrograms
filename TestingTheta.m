% TestingTheta.m
%
%   Test *across* parameter values: e.g. a range of eta values
%   to make sure the chaining results are smooth/continuous.


% TEST 
clear all; global CaseName;
CaseName='TestTheta';

ParamName='Theta';   
ParamRange=[1.8 4]
NumPoints=8  % In addition to endpoints
Param=interplin(ParamRange',NumPoints);
GrowthShare=zeros(length(Param),1);


iCounter=1;

while iCounter<=length(Param);
    save iCounterTestingTheta iCounter ParamName Param GrowthShare;
 
    clear; global CaseName; % To clear out *previous* run from earlier iters
    load iCounterTestingTheta;
    SetParameters;
    ChainSingleCase=1
    theta=Param(iCounter);
    ReadCohortData
    EstimateTauZ2
    CleanandShowTauAZ
    SolveEqmBasic
    Chaining2
    load iCounterTestingTheta
    GrowthShare(iCounter)=GrowthShare_TWTH(1);
    iCounter=iCounter+1;
end;

diarychad('TestingTheta');
cshow(' ',[Param GrowthShare],'%12.3f',[ParamName ' GrowthShare']);

definecolors;
figure(1); figsetup;
plot(Param,GrowthShare,'-','Color',myblue);
hold on;
plot(Param,GrowthShare,'o','Color',mygreen);
chadfig2(ParamName,'Share of growth due to tau_w and tau_h',1,0)
print TestingTheta.eps
diary off;
