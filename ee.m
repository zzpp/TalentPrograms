clear
load blahTbar
g=2
ConstrainTauH=-0.8


    est_TauW=zeros(Noccs,Ngroups,Nyears)*NaN; 
    est_TauH=zeros(Noccs,Ngroups,Nyears)*NaN;
    Z(:,WM,:)=ones(Noccs,Ncohorts);
    TgHome(:,WM,:)=ones(Noccs,Ncohorts);
    THOME=zeros(Ngroups,Nyears)*NaN; % This will capture time variation, cohort effect like TgHome
    wHome(WM,:)=1;
    save blahTbar;

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Prepare to Loop over AlphaSplitTauW1960 to find the 
    % fixed point split of tauhat into TauW and TauH
    % that we should start with
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AlphaIterMax=10; % Max number of iterations
    alphacounter=1;
    AlphaChange=1;
    AlphaSplitTauW1960=0.5; % Default starting value
    if AlphaFixedSplit>0;
        AlphaSplitTauW1960=AlphaFixedSplit;  % Then just use this split and do not iterate
        AlphaIterMax=2;
    end;
    if FiftyFiftyTauHat==1;
        AlphaSplitTauW1960=0.5; % Default starting value and don't iterate
        AlphaIterMax=2;
    end;
    AlphaSplit=zeros(AlphaIterMax,1);
    AlphaSplit(1)=AlphaSplitTauW1960;

    
    
        
    disp ' '; disp ' '; 
    disp '--------------------------------------------------------------------------------------------------';
    disp(['                          >>>>> ' GroupNames{g} ' <<<<<'])
    disp '--------------------------------------------------------------------------------------------------';
    g

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Set Pre-determined Parameter Values
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load(['CohortData_' CaseName '.mat']);
    %load wphis_rent_old;

    % Aggregate Earnings (for weighting)
    AggIncomeData=NumPeople.*Earnings;
    AggIncomeData_igt=squeeze(nansum(AggIncomeData,3));
    AggIncomeData_it=squeeze(nansum(AggIncomeData_igt,2));
        

    % a. target for probability of working at young = aggregate labor force participation rate
    PwY_target = zeros(6,1)*NaN;
    for c=1:6;
        p1      =squeeze(p(:,g,7-c,c));
        p1(1)=0;
        PwY_target(c)=sum(p1); % aggregate labor force participation rate
    end
    PwY_target

    % b. target only wage growth (not propensity) to estimate TauW for the middle
    %            alpha1=WeightPig*alphaP + WeightWage*alphaW;  % Weights should sum to one

    %Weights = [1/2 1/2] % WeightPig; WeightWage
    Weights = [WeightPigMiddle 1-WeightPigMiddle] % WeightPig; WeightWage
    disp ' ';
    
    % c. alpha (rule to divide TauHat into TauW and TauH) for the young in 1960 = 0.5
    alpha_set = AlphaSplitTauW1960
    Alpha1MiddleSplit=zeros(Noccs,Ngroups,Nyears)*NaN; % For saving the TauHat split. 1960=eval_young. 1970-2010=eval_middle
    
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Loop over cohorts to solve for TauW, TauH, Z, TgHome
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Places to save
est_mg=zeros(1,6)*NaN;
est_alpha1=zeros(1,5)*NaN;
x_young=zeros(Nyears,Noccs,11)*NaN;
x_middle=zeros(Nyears,Noccs,15)*NaN;
THOME1960=NaN;
save blah;

% First time, we estimate TgHome for every decade, storing in x_young(Nyears,Noccs,11);
for c=1:Nyears;
    TgHome_g=[];  % Passing the empty matrix tells estimatetauz to estimate TgHome every decade.
    estimatetauz; % Run the sub-program
end; % for c=1:Nyears

% This time, obtain the min(TgHome) across decades for each occ and impose that as constant over time.
TgHome_Varying=squeeze(x_young(:,:,10));  % Nyears x Noccs
TgHome_g=nanmin(TgHome_Varying)';
tle='1960 1970 1980 1990 2000 2010 Min';
disp ' ';
disp 'Estimates of TgHome by Decade, together with the min value we will impose as constant...'
cshow(ShortNames,[TgHome_Varying' TgHome_g],'%8.3f',tle);
save blah;
