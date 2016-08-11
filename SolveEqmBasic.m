% SolveEqmBasic.m    
%
%  Takes the TalentData.mat data on Taus, Z's, TgHome, A(i,t).
%  Solves for the equilibrium w(i) and Y
%
%  See 2015-06-02-SolvingGE.pdf notes.
%
%  Method: For each year,
%    1. Guess values for {mgtilde}, Y ==> 5 unknowns
%    2. Solve for {wi} from Hi^supply = Hi^demand
%    3. Compute mghat, Yhat 
%    4. Iterate until converge.

clear; global CaseName;
diarychad('SolveEqmBasic',CaseName);

global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData HAllData q 
global TauW_C phi_C mgtilde_C w_C % For keeping track of history in solution

load(['TalentData_' CaseName]); % From EstimateTauZ2 and earlier programs
ShowParameters;

[YModel,EarningsModel,YwkrModel,LFPModel,ConsumpYoungModel,EarningsAllModel,WageGapModel,WageGapAllModel,EarningsModel_g,wModel,HModel,HModelAll,pModel,ExitFlag]=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);

% Now show results using a separate program (so we can call it elsewhere when testing)
SolveEqmBasic_Display


GDPBaseline=YModel;
GDPBaseline_Young=GDPYoung_Model;
EarningsBaseline=EarningsModel;
EarningsAllBaseline=EarningsAllModel;
GDPwkrBaseline=YwkrModel;
LFPBaseline=LFPModel;
WageGapBaseline=WageGapModel;
WageGapAllBaseline=WageGapAllModel;
EarningsBaseline_g=EarningsModel_g;
ConsumpYoungBaseline=ConsumpYoungModel;
save(['SolveEqmBasic_' CaseName],'GDPBaseline','GDPwkrBaseline','GDPBaseline_Young','EarningsBaseline','EarningsBaseline_g','EarningsAllBaseline','ConsumpYoungBaseline','LFPBaseline','WageGapBaseline','WageGapAllBaseline');

% For Benchmark case, let's compute the gains from eliminating TauH, TauW and Both
if isequal(CaseName,'Benchmark');
    Y_NoTauH=SolveForEqm(zeros(size(TauH)),TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);    
    Y_NoTauW=SolveForEqm(TauH,zeros(size(TauW)),Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);    
    Y_NoTaus=SolveForEqm(zeros(size(TauH)),zeros(size(TauW)),Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);    

    Gain_NoTauH=Y_NoTauH./YModel-1;
    Gain_NoTauW=Y_NoTauW./YModel-1;
    Gain_NoTaus=Y_NoTaus./YModel-1;
    disp ' '; disp ' ';
    disp 'Additional output gain over baseline with no frictions (percent):';
    cshow(' ',[Decades 100*[Gain_NoTauH Gain_NoTauW Gain_NoTaus]],'%6.0f %12.1f','Year NoTauH NoTauW NoTauH/W');

    % For Baseline case, also show results if Zero TauW/TauH (for Altonji)
    disp ' '; disp ' ';
    disp '********************************************************************';
    disp '       Counterfactual results with ZERO TAUW AND TAUH';
    disp '********************************************************************'; disp ' ';
    
    [YModel,EarningsModel,YwkrModel,LFPModel,ConsumpYoungModel,EarningsAllModel,WageGapModel,WageGapAllModel,EarningsModel_g,wModel,HModel,HModelAll,pModel,ExitFlag]=SolveForEqm(zeros(size(TauH)),zeros(size(TauW)),Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    SolveEqmBasic_Display

    disp '********************************************************************';
    disp '    END of Counterfactual results with ZERO TAUW AND TAUH';
    disp '********************************************************************';

end;

diary off;
