function [YModel,EarningsModel,YwkrModel,LFPModel,ConsumpYoungModel,EarningsAllModel,WageGapModel,WageGapAllModel,EarningsModel_g,wModel,HModel,HModelAll,pModel,ExitFlag]=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);

% SolveForEqm.m    
%
% Given TauW, TauH, Z, TgHome, etc. this function solves for the general equilibrium.
%
%   Y    = GDP per person = Y in the model
%   Ywkr = GDP per worker = Y / LFP
%   LFP  = Aggregate LFP rate = Fraction of total population that is working
%
%  See 2015-06-02-SolvingGE.pdf notes.
%
%  Method: For each year,
%    1. Guess values for {mgtilde}, Y ==> 5 unknowns
%    2. Solve for {wi} from Hi^supply = Hi^demand
%    3. Compute mghat, Yhat 
%    4. Iterate until converge.

global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData 
global TauW_C phi_C mgtilde_C w_C StopHere % For keeping track of history in solution

StopHere=0;

% Initialize cohort history, needed for solution.
w_C=zeros(Noccs,Ncohorts); 
mgtilde0=11000; % mgtilde := mg^(1/theta*1/(1-eta)) -- better scaled
mgtilde_C=ones(Ngroups,Ncohorts)*mgtilde0; 
TauW_C=zeros(Noccs,Ngroups,Ncohorts); % Cohort order
for g=1:Ngroups;
    TauW_C(:,g,1:6)=flipud(squeeze(TauW(:,g,:))')';
end;


% Guesses
Y0=15000;
%x0=[11000 8000 8000 8000 Y0];
%x0=[1100 800 800 800 Y0]; % For theta(1-eta)=3.44 and eta=1/4
%x0=[1100 800 800 800 Y0]/3; % For theta(1-eta)=3.44 and eta=1/4
x0=[15000 8000 10000 8000 Y0]; % For theta(1-eta)=1.9 and eta=.10 See mgtilde_C(:,c)=x(1:4); line below for help
%options=optimset('Display','iter'); %,'Algorithm','trust-region-dogleg');
options=optimset('Display','none'); %,'Algorithm','trust-region-dogleg');
wModel=zeros(Noccs,Nyears);
HModel=zeros(Noccs,Nyears);
LFPModel=zeros(Nyears,1);
pModel=zeros(Noccs,Ngroups,3,Nyears); % YMO is 3rd dimension
HModelAll=zeros(Noccs,Ngroups,3,Nyears); % YMO is 3rd dimension
EarningsModel=zeros(Nyears,1);    % Total Labor Earnings (differs from Y if Revenue~=0)
EarningsModel_g=zeros(Ngroups,Nyears);    % Total Labor Earnings by Group
EarningsAllModel=zeros(Nyears,1); % Total Labor Earnings if everyone worked (Pwork=1)
ConsumpYoungModel=zeros(Nyears,1);
YModel=zeros(Nyears,1);
WageGapModel=zeros(Ngroups,Nyears);
WageGapAllModel=zeros(Ngroups,Nyears); % WageGap if everyone worked (Pwork=1)
ExitFlag=zeros(Nyears,1);

% Iterate over time to solve the model decade by decade
for t=1:Nyears;
    fprintf('.');
    fune_solve=@(x) e_solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
    [x,fval,flag]=fsolve(fune_solve,x0,options);
    ExitFlag(t)=flag; if flag~=1; disp 'Exit Flag not equal to one. Stopping...'; keyboard; end;
    [resid,wt,Ht,Yhat,HModelAllt,pModelt,LaborIncome,LaborIncome_g,WageGapt,ConsumpYoung_t,LaborIncomeAll,WageGapAllt]=e_solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar); 
    c=7-t;
    mgtilde_C(:,c)=x(1:4); % Drop the comma here to see the mgtilde if x0 guess is wrong
    w_C(:,c)=wt;
    wModel(:,t)=wt;
    HModel(:,t)=Ht;
    HModelAll(:,:,:,t)=HModelAllt;
    pModel(:,:,:,t)=pModelt;
    EarningsModel(t)=LaborIncome;
    EarningsModel_g(:,t)=LaborIncome_g;
    EarningsAllModel(t)=LaborIncomeAll;
    YModel(t)=Yhat;
    WageGapModel(:,t)=WageGapt;
    WageGapAllModel(:,t)=WageGapAllt;
    ConsumpYoungModel(t)=ConsumpYoung_t;
    %StopHere=1;
    %solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar); % Returns Noccs x 1 vectors of wages and H(i,t)  and NxG wtilde

    % Compute LFP and GDP per worker from the solution
    % First, we add up across YMO
    Pwork_gYMO=squeeze(sum(pModelt(2:Noccs,:,:))); % Ngroups x YMO
    Pwork_g=zeros(Ngroups,1);
    %NumPeople_g=zeros(Ngroups,1);
    for ymo=0:2;
        Pwork_g    =Pwork_g+Pwork_gYMO(:,1+ymo).*q(:,c+ymo,t);
        %NumPeople_g=NumPeople_g+q(:,c+ymo,t);
    end;
    LFPModel(t)=sum(Pwork_g); % No need to multiply by NumPeople_g, as we've already done that!
    
    if flag==1;
        x0=x; % Use most recent results for new starting point
    end;
end;
YwkrModel=YModel./LFPModel;  % GDP per worker = GDP per person * Persons/Wkrs


% -------------------------------------------------------
% Sub-functions
% -------------------------------------------------------


function [resid,wt,Ht,Yhat,HModelAllt,pmodelt,LaborIncome,LaborIncome_g,WageGapt,ConsumpYoung_t,LaborIncomeAll,WageGapAllt]=e_solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar); 

% Given a guess for x=[mgtilde Y] 5x1 and a year t (e.g. 1=1960), 
% solve for w(i) in year t and then compute key moments:
%
%    1. Guess values for {mgtilde}, Y ==> 5 unknowns
%    2. Solve for {wi} from Hi^supply = Hi^demand
%    3. Compute mghat, Yhat 
%    4. Iterate until converge.


global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData
global TauW_C phi_C mgtilde_C w_C pModel % For keeping track of history in solution

mgtilde_t=x(1:4);
Y_t=x(5);

[wt,Ht,wtildet,HModelAllt,pmodelt,Pworkt]=solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar); % Returns Noccs x 1 vectors of wages and H(i,t)  and NxG wtilde
mgtildehat=(sum(wtildet.^theta)).^mu;
rho=1-1/sigma;
mu=1/theta*1/(1-eta);
Yhat=sum( (A(:,t).*Ht).^rho ).^(1/rho);
resid=[mgtilde_t-mgtildehat Yhat-Y_t];

% WageGapt (1 x Ngroups) = WageBar(g)/WageBar(WM) net of taxes
%   Average across occupations
%   HModelAllt (Noccs x Ngroups x YMO) but HModelAllt already includes q
%     HAll_i(:,ymo+1)=(q(:,c,t)'.*pig_t.*texp_t.*AvgQuality)';
%   q (Ngroups x Ncohorts x Nyears)
%   pmodelt (Noccs x Ngroups x YMO)  
%   LaborIncomeAll: Total earnings at market prices if *everyone* worked (Pwork=1)
%     From 2016-02-17-EarningsAll.pdf notes, we multiply HModelAllt by Pwork^(mu-1).
%     The mu exponent gets the "per worker" version right, and the -1 adjusts for 
%     the aggregation, converting p(i,g) into ptilde.
%
%   Simple aggregates in the model are all "per person" since our economy has a population=1.

TotalEarnings_ig = mult(squeeze(1-TauW(:,:,t)).*sum(HModelAllt,3),wt);  % Noccs x Ngroups
LaborIncome_g=sum(TotalEarnings_ig(2:Noccs,:)); % 1 x Ngroups
LaborIncome=sum(sum(TotalEarnings_ig(2:Noccs,:)));
TotalEarningsAll_ig = mult(squeeze(1-TauW(:,:,t)).*sum(HModelAllt.*Pworkt.^(mu-1),3),wt);  % Noccs x Ngroups
LaborIncomeAll=sum(sum(TotalEarningsAll_ig(2:Noccs,:)));

lfp_gc=squeeze(sum(pmodelt(2:Noccs,:,:))); % This is Pwork_gc Ngroups x YMO
c=7-t; co=c+2;
NumWorkers_g = sum(q(:,c:co,t).*lfp_gc,2)';  % 1xG
WageBar_g  = sum(TotalEarnings_ig)./NumWorkers_g; %1xG
WageGapt=WageBar_g/WageBar_g(1);

NumWorkersAll_g = sum(q(:,c:co,t).*1,2)';  % 1xG  lfp_gc=1
WageBarAll_g  = nansum(TotalEarningsAll_ig)./NumWorkersAll_g; %1xG
WageGapAllt=WageBarAll_g/WageBarAll_g(1);

% Market Consumption: Updated 6/9/16. See Chad-TalentNotes.pdf (page 2c)
%     c* = 1/3*(1-eta)*LifetimeIncome = cYoung
%     e*(1+tauh) = eta*LifetimeIncome
EarningsYoung_ig = mult(squeeze(1-TauW(:,:,t)).*HModelAllt(:,:,1),wt);  % Noccs x Ngroups
LIYoung_ig=Tbar(:,:,t)./TExperience(:,:,c,t).*EarningsYoung_ig; % Noccs x Ngroups
% NumYoung=zeros(Nyears,1);
% for t=1:Nyears;
%     NumYoung(t)=sum(q(:,7-t,t));
% end;
NumYoungt=sum(q(:,7-t,t));
cY_ig=1/3*(1-eta)*LIYoung_ig;
ConsumpYoung_t=sum(sum(cY_ig))/NumYoungt; % Per young person
