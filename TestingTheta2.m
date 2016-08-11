% TestingTheta2.m
%
%   Test *across* parameter values: e.g. a range of eta values
%   to make sure the chaining results are smooth/continuous.


% TEST 
clear all; global CaseName;
CaseName='TestTheta2';

ParamName='Theta';   
ParamRange=[4 5]
NumPoints=9  % In addition to endpoints
Param=interplin(ParamRange',NumPoints);
GrowthShare=zeros(length(Param),1);


iCounter=1;

while iCounter<=length(Param);
    save iCounterTestingTheta2 iCounter ParamName Param GrowthShare;
 
    clear; global CaseName; % To clear out *previous* run from earlier iters
    load iCounterTestingTheta2;
    SetParameters;
    ChainSingleCase=1
    theta=Param(iCounter);
    ReadCohortData
    EstimateTauZ2
    CleanandShowTauAZ
    SolveEqmBasic
    Chaining2
    load iCounterTestingTheta2
    GrowthShare(iCounter)=GrowthShare_TWTH;
    iCounter=iCounter+1;
end;

diarychad('TestingTheta2');
cshow(' ',[Param GrowthShare],'%12.3f',[ParamName ' GrowthShare']);

definecolors;
figure(1); figsetup;
plot(Param,GrowthShare,'-','Color',myblue);
hold on;
plot(Param,GrowthShare,'o','Color',mygreen);
chadfig2(ParamName,'Share of growth due to tau_w and tau_h',1,0)
print TestingTheta2.eps
diary off;
