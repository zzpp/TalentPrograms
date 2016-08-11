function [GrowthShare,Gr_geo,YBaseline]=chaining(WhatChanges,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);

%function [Yconstanttau YconstantApq]=chaining(WhatChanges,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
%
% Details of the chaining.
%
%  WhatChanges={'TauWTauH','TauW','TauH','Both+Z','Both+ZTgHome'} determines how much is allowed to change

global Nyears Decades ExperienceCohortFactor HAllData CaseName WhatToChain

if isequal(WhatChanges,'TauW');         ChangeTauH=0; ChangeTauW=1; ChangeZ=0; ChangeTgHome=0; end;
if isequal(WhatChanges,'TauH');         ChangeTauH=1; ChangeTauW=0; ChangeZ=0; ChangeTgHome=0; end;
if isequal(WhatChanges,'TauWTauH');     ChangeTauH=1; ChangeTauW=1; ChangeZ=0; ChangeTgHome=0; end;
if isequal(WhatChanges,'Both+Z');       ChangeTauH=1; ChangeTauW=1; ChangeZ=1; ChangeTgHome=0; end;
if isequal(WhatChanges,'Both+ZTgHome'); ChangeTauH=1; ChangeTauW=1; ChangeZ=1; ChangeTgHome=1; end;
if isequal(WhatChanges,'NoChange');     ChangeTauH=0; ChangeTauW=0; ChangeZ=0; ChangeTgHome=0; end;


disp ' '; disp ' ';
disp '---------------------------------------------------';
disp (['   The chaining calculations for ' WhatChanges]);
disp '---------------------------------------------------';

% BASELINE -- First we get the baseline values, useful in both sides of chaining
%YBaseline=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
load(['SolveEqmBasic_' CaseName]);

WageGapBaseline=WageGapBaseline';
WageGapBaseline(:,1)=[];
WageGapAllBaseline=WageGapAllBaseline';
WageGapAllBaseline(:,1)=[];
YBaseline=[GDPBaseline GDPwkrBaseline LFPBaseline EarningsBaseline EarningsAllBaseline ConsumpYoungBaseline WageGapBaseline WageGapAllBaseline EarningsBaseline_g'];
chaintle={'GDP per person','GDP per worker','Labor Force Participation (LFP)','Earnings','EarningsAll','ConsumpYoung (market)','WageGapWW','WageGapBM','WageGapBW','WageGapAllWW','WageGapAllBM','WageGapAllBW','EarningsWM','EarningsWW','EarningsBM','EarningsBW'};

% First, solve for Yinit := Y(70,60) = Y with 70 taus but 60 state elsewhere
% Loop from t=1:(Nyears-1) and just move the tau's
Yinit=ones(size(YBaseline))*NaN;
Yi_output=Yinit; Yi_wkr=Yinit; Yi_earnings=Yinit; LFPi=Yinit;
fprintf('Solving for Yinit (e.g. Y with 1970 taus but the 1960 state)');

for t=1:(Nyears-1); % Loop over the year we take the state from (e.g. A/phi/Z)
  % Just move the Tau's
  disp ' ';
  TauWnext=TauW;
  if ChangeTauW; TauWnext(:,:,t)=TauW(:,:,t+1); end;

  % Cohort states, be careful!
  TauHnext=TauH; Znext=Z; TgHomenext=TgHome;
  c=7-t;  CurrentCohorts=[c c+1 c+2]; % 1960 cohort, e.g.
  cN=c-1; NextCohorts=[cN cN+1 cN+2]; % 1970 cohort
  if ChangeTauH; TauHnext(:,:,CurrentCohorts)=TauH(:,:,NextCohorts); end;
  if ChangeZ; Znext(:,:,CurrentCohorts)=Z(:,:,NextCohorts); end;
  if ChangeTgHome; TgHomenext(:,:,CurrentCohorts)=TgHome(:,:,NextCohorts); end;

  [y_output,y_earnings,y_wkr,lfp,consumpmkt,earningsall,wagegap,wagegapall,earnings_g]=SolveForEqm(TauHnext,TauWnext,Znext,TgHomenext,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
  Yinit(t,:)=[y_output(t) y_wkr(t) lfp(t) y_earnings(t) earningsall(t) consumpmkt(t) wagegap(2:4,t)' wagegapall(2:4,t)' earnings_g(:,t)'];
end;

gI=Yinit./YBaseline;
fmt='%6.0f %9.0f %9.0f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f';
cshow(' ',[Decades YBaseline(:,1) Yinit(:,1) gI],fmt,'Decade Baseline Yinit GrowthY gIYwkr gILFP gIearn gearnAll gIcons gGapWW gGapBM gGapBW gGpAllWW gGpAllBM gGpAllBW gEarnWM gEarnWW gEarnBM gEarnBW')


% Second, solve for Yfinal := Y(60,70) = Y with 60 taus but 70 state elsewhere
Yfinal=ones(size(YBaseline))*NaN;
disp ' ';
fprintf('Solving for Yfinal (e.g. Y with 1960 taus but the 1970 state)');

for t=2:Nyears; % Loop over the year we take the state from (e.g. A/phi/Z)
  % Just move the Tau's
  disp ' ';
  TauWprev=TauW;
  if ChangeTauW; TauWprev(:,:,t)=TauW(:,:,t-1); end;

  % Cohort states, be careful!
  TauHprev=TauH; TauHprev(:,:,8)=TauHprev(:,:,6); TauHprev(:,:,7)=TauHprev(:,:,6); % Placeholders
  TgHomeprev=TgHome; TgHomeprev(:,:,8)=TgHomeprev(:,:,6); TgHomeprev(:,:,7)=TgHomeprev(:,:,6); % Placeholders
  Zprev=Z; Zprev(:,:,8)=Zprev(:,:,6); Zprev(:,:,7)=Zprev(:,:,6); % Placeholders
  c=7-t;  CurrentCohorts=[c c+1 c+2]; % 1970 cohort, e.g.
  cP=c+1; PrevCohorts=[cP cP+1 cP+2]; % 1960 cohort
  if ChangeTauH; TauHprev(:,:,CurrentCohorts)=TauHprev(:,:,PrevCohorts); end; % Using 'prev' to handle cohorts 7,8
  if ChangeZ; Zprev(:,:,CurrentCohorts)=Zprev(:,:,PrevCohorts); end;
  if ChangeTgHome; TgHomeprev(:,:,CurrentCohorts)=TgHomeprev(:,:,PrevCohorts); end;

  [y_output,y_earnings,y_wkr,lfp,consumpmkt,earningsall,wagegap,wagegapall,earnings_g]=SolveForEqm(TauHprev,TauWprev,Zprev,TgHomeprev,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);
  Yfinal(t,:)=[y_output(t) y_wkr(t) lfp(t) y_earnings(t) earningsall(t) consumpmkt(t) wagegap(2:4,t)' wagegapall(2:4,t)' earnings_g(:,t)'];
end;

gF=YBaseline./Yfinal;
cshow(' ',[Decades YBaseline(:,1) Yfinal(:,1) gF],fmt,'Decade Baseline Yfinal GrowthY gFYwkr gFlfp gFearn gearnAll gFcons gGapWW gGapBM gGapBW gGpAllWW gGpAllBM gGpAllBW gEarnWM gEarnWW gEarnBM gEarnBW')



% Now merge gI and gF to get the geometric average  % Adjust timing
gI=trimr(gI,0,1); 
gF=trimr(gF,1,0); 
Gr_geo=(gI.^(1/2)).*(gF.^(1/2));

disp ' ';
disp 'Here are the growth factors, Laspeyeres, Paasche, and GeoAvg:';
fmt='%5.0f %5.0f %8.4f %8.4f %8.4f';
tle='Yearto Year gInit gFinal GeoAvg';
years=[trimr(Decades,0,1) trimr(Decades,1,0)];
for i=1:length(chaintle);
    disp ' '; disp(chaintle{i});
    cshow(' ',[years gI(:,i) gF(:,i) Gr_geo(:,i)],fmt,tle);
end;
disp ' '; 
disp 'Cumulative growth from changes:'
for i=1:length(chaintle);
    fprintf([chaintle{i} ' = %8.4f\n'],prod(Gr_geo(:,i))); 
end;
disp ' ';
TT=Decades(6)-Decades(1);

growthBaseline=1/TT*log(YBaseline(Nyears,:)./YBaseline(1,:));
growthDueToVar=1/TT*log(prod(Gr_geo));
GrowthShare=growthDueToVar./growthBaseline*100;
disp ' ';
disp '///////////////////////////// KEY RESULT //////////////////////////////';
for i=1:length(chaintle);
    disp ' '; disp(chaintle{i});
    fprintf('      Average annual growth of baseline (model) measure: %8.4f\n',growthBaseline(i)*100);
    fprintf(['        Average annual growth due to changing ' WhatChanges '      : %8.4f\n'],growthDueToVar(i)*100);
    fprintf(['                         >>>>>   Share accounted for by ' WhatChanges ' is %6.1f percent  <<<<<\n'],GrowthShare(i));
end;


%disp ' ';
%fprintf('Note well: %7.4f x %7.4f = %7.4f\n',[prod(Gr_geo) prod(GrAp_geo) prod(Gr_geo)*prod(GrAp_geo)]);
%disp ' '; disp ' ';

%Yconstanttau=100*[1; cumprod(GrAp_geo)];
%YconstantApq=100*[1; cumprod(Gr_geo)];

%if isequal(WhatChanges,'TauWTauH');
%    save(['Chaining2TauWTauH_' CaseName]);
%end;
