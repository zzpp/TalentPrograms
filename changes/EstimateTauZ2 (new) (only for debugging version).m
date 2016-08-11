% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   EstimateTauZ2.m   (formerly called main_procedure)
%
%   Main program to estimate TauW, TauH, Z, and TgHome
%   Iterates over wHome as needed.
%
%   See the Note on Estimation for more information on how this program works.
%     
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; global CaseName;
diarychad('EstimateTauZ2',CaseName)

clc;
load(['CohortData_' CaseName '.mat']);
ShowParameters;

ssr=ones(100,1)*100;
iter=1;
end_criteria=100;

% WMequals0
%   Toggle = True if we set TauW(wm)=TauH(wm)=0 everywhere, leaving small positive revenue.
%   This is the only case currently implemented.
%   Otherwise, solves for common TauW(wm) and TauH(wm) in all occs to dissipate revenue so Agg Revenue = 0
WMequals0 = 1;   


% Initializing for storage
ExperienceCohortFactor=ones(Ngroups,Nyears,3); % YMO structure
Z=zeros(Noccs,Ngroups,Ncohorts)*NaN;  % Ordered by Cohort
TgHome=zeros(Noccs,Ngroups,Ncohorts)*NaN;  % Ordered by Cohort


% Initial value
wm_tauw_mat=[0 0 0 0 0 0]; % TauW subsidy rate to white men
wm_tauh_mat=[0 0 0 0 0 0]; % TauH subsidy rate to white men                           
%save wm_rent.mat wm_tauw_mat wm_tauh_mat

lambda=1; % Not in active use


%% Part I
% Estimate w(i), s(i) and phi(i) from white men given subsidy rates to white men
% a.	Function to use: rent_solvefor_w_phi.m
% b.	Data to save: wphis_rent_old.mat (estimated w, s, and phi)

    clc;
    %load wm_rent.mat; % load initial subsidy rates

    % Recover w(i), s(i), and phi(i) from the white men
    ShowData=1;

    
    Tbar=3*ones(Noccs,Ngroups,Nyears); % Initial guess for Tbar for WM. 
    [w,phi,s,pwm,mwm,twmhomeC]=solvefor_w_phi_givensubsidy(wm_tauw_mat,wm_tauh_mat,eta,beta,theta,gam,sigma,phiFarm,lambda,Tbar,ShowData,0);

    % Compute the T(i,g) and That := T(i,g)/T(i,WM) and iterate to update
    That=ones(size(p)); % Initial guess
    TbarHat=ones(size(Tbar))*NaN;
    for g=1:Ngroups;
        TbarHat(:,g,:)=div(Tbar(:,g,:),Tbar(:,WM,:));
    end;
    GetTExperience
    
    % Iterate until converges
    Told=Tbar(8,1,:);
    maxdiff=1; s_counter=1; % WM
    while maxdiff>.002 && s_counter<8;
        [w,phi,s,pwm,mwm,twmhomeC]=solvefor_w_phi_givensubsidy(wm_tauw_mat,wm_tauh_mat,eta,beta,theta,gam,sigma,phiFarm,lambda,Tbar,ShowData,s_counter);
        GetTExperience
        s_counter=s_counter+1;
        maxdiff=max(Told-Tbar(8,1,:));
        Told=Tbar(8,1,:); % WM
    end;
    
    % One last solvefor here to make sure our tauhat are consistent with Tbar
    % Calculate tauhat -- Relative to WM Note: All tauh and tauw will be
    % *relative to WM* for the bulk of the program. We'll only undo this at
    % the end (legacy of the fact that we initially set tauWM=1) -- Because
    % we estimate wHome and Thome to fix WM LFP at a given value in all
    % occs, the solution of the model depends only on relative taus! (in the
    % estimation, not in the equilibrium)
    %   -- omits TbarHat term for now, fixed below with tauhat_y:
    tauhat=That.^(1-eta).*relp.^(-1/theta) .* wagegap.^(-(1-eta));
    tauhat(isinf(tauhat))=NaN; % Code to handle missing data
    clear tauhat_y; 

    % Only makes sense for the young cohorts
    % and need to multiply by TbarHat term (GxT, common across occupations)
    for t=1:Nyears;
        ct=7-t;
        tauhat_y(:,:,t)=squeeze(tauhat(:,:,ct,t)).*TbarHat(:,:,t).^eta;
    end;
    oldtauhat=tauhat;
    tauhat=tauhat_y;  % Replace with the tauhat_y version: NxGxT
   
    % And plot for WW if IgnoreBrawnyOccupations || NoFrictions2010
    if IgnoreBrawnyOccupations || NoFrictions2010;
        disp 'TauHat for WW -- should be 1 in the right places if IgnoreBrawnyOccupations || NoFrictions2010';
        cshow(ShortNames,squeeze(tauhat(:,WW,:)),'%8.3f','1960 1970 1980 1990 2000 2010');
    end;
     
    % One last solvefor here to make sure our w/phi/s are consistent with Tbar
    [w,phi,s,pwm,mwm,twmhomeC]=solvefor_w_phi_givensubsidy(wm_tauw_mat,wm_tauh_mat,eta,beta,theta,gam,sigma,phiFarm,lambda,Tbar,ShowData,s_counter+1);
    disp ' ';
    fprintf('Iteration to get Tbar ended after %2.0f iterations',s_counter-1);
    disp ' ';


%% Part II
% Estimate TauW and TauH for three other groups (white women and black men/women)
% a.	Function to use: eval_young.m, eval_middle.m
% b.	Data to save: none

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

    
while alphacounter<AlphaIterMax && abs(AlphaChange)>.003;

    
    
for g=2:Ngroups
        
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

% Choose the initial THOME1960 as the average value from the first pass, relative to min
THOME1960=nanmean(earningsweights(:,1).*TgHome_Varying(1,:)') / nanmean(earningsweights_avg.*TgHome_g);
fprintf('THOME1960 = %12.6f\n',THOME1960);


for c=1:Nyears;
    estimatetauz; % Run the sub-program
end; % for c=1:Nyears

% Save z, tghome, and cf for each group
x_cohort_1=squeeze(x_young(6,:,:));
x_cohort_2=squeeze(x_young(5,:,:));
x_cohort_3=squeeze(x_young(4,:,:));
x_cohort_4=squeeze(x_young(3,:,:));
x_cohort_5=squeeze(x_young(2,:,:));
x_cohort_6=squeeze(x_young(1,:,:));
x_cohort_7=zeros(Noccs,11)*NaN; % Note: This is the one thing Chang used main_procedure_eval for.
x_cohort_8=zeros(Noccs,11)*NaN; %   I don't use it in solveeqm, so I'm dropping for now 8/27/15 CIJ

z_conv=[x_cohort_1(:,5) x_cohort_2(:,5) x_cohort_3(:,5) x_cohort_4(:,5) x_cohort_5(:,5) x_cohort_6(:,5) x_cohort_7(:,5) x_cohort_8(:,5)];
tghome=[x_cohort_1(:,10) x_cohort_2(:,10) x_cohort_3(:,10) x_cohort_4(:,10) x_cohort_5(:,10) x_cohort_6(:,10) x_cohort_7(:,10) x_cohort_8(:,10)];
Z(:,g,:)=z_conv;
TgHome(:,g,:)=tghome;


end; % for g=2:Ngroups

% ----------------------------------------------------------------

% Calculate TauW, TauH (ordered by cohort).
% Fix missing values systamtically.

    p(isnan(p))=0;
    WageBar=Earnings;
    WageBar(isnan(WageBar))=0;
    NumPeople(isnan(NumPeople))=0;
    
    % No NaNs here -- we need the zeros for tau(WM) since relative
    TauW=zeros(Noccs,Ngroups,Nyears);    % Ordered by Time
    TauH=zeros(Noccs,Ngroups,Ncohorts);  % Ordered by Cohort
    for g=2:Ngroups; % Leave WM=0; otherwise puts in NaNs!
        for t=1:6;
            Cohort=7-t;
            TauW(:,g,t)=squeeze(est_TauW(:,g,t));     %This will provide NaNs where missing.
            TauH(:,g,Cohort)=squeeze(est_TauH(:,g,t));
        end;
    end;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPLIT of tauhat into TauW and TauH (young)
%   - To update our 1960 assumption
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AlphaSplitYoung=-log(1-TauW)./log(tauhat_y);  % Noccs x Ngroups x Nyears
disp ' ';
disp 'AlphaSplitYoung for WW:';
cshow(ShortNames,squeeze(AlphaSplitYoung(:,2,:)),'%8.3f','1960 1970 1980 1990 2000 2010');
for g=2:Ngroups;
    meansplit(g,:)=squeeze(nansum(mult(squeeze(AlphaSplitYoung(:,g,:)),earningsweights_avg)));
end;
nonWMweights=earningsweights_g./sum(earningsweights_g(2:Ngroups));
nonWMweights(WM)=NaN;
meansplit_avg=sum(mult(meansplit(2:Ngroups,:),nonWMweights(2:Ngroups)));
disp ' ';
disp '============================================';
disp 'SPLIT of tauhat into TauW and TauH (young), earnings weighted'
disp ' - For comparison with our 1960 assumption'
disp '============================================';
cshow(GroupNames,meansplit,'%10.3f','1960 1970 1980 1990 2000 2010')
disp '-----------------------------------------------------------------------';
cshow('///Mean/// ',meansplit_avg,'%10.3f',[],[],1);
fprintf('  And the mean for all years is %10.3f\n',mean(meansplit_avg));
fprintf('The mean for yearsafter 1960 is %10.3f\n',mean(meansplit_avg(2:end)));

% And update
AlphaSplitNew=mean(meansplit_avg);
AlphaChange=AlphaSplitNew-AlphaSplitTauW1960;
alphacounter=alphacounter+1;
AlphaSplit(alphacounter)=AlphaSplitNew;
AlphaSplitTauW1960=AlphaSplitNew;


end; % End of AlphaSplit (alphacounter) loop
disp ' ';
disp 'List of AlphaSplitTauW1960 values we tried:';
blah=[(1:AlphaIterMax)' AlphaSplit];
cshow(' ',blah(1:(alphacounter-1),:),'%8.0f %8.4f','Iter AlphaSplit');
disp ' ';
AlphaSplitTauW1960=AlphaSplit(alphacounter-1);
fprintf('The final value of AlphaSplitTauW1960 = %8.5f\n',AlphaSplitTauW1960);
disp ' ';



%% Part III

    % Fix missing values in a systematic way
    disp ' '; disp '===========================================================';
    disp 'Fixing TauW / TauH / TgHome / Z missing values';
    disp ' -- Use first non-missing value';
    disp ' -- Missing p and WageBar ==> 0';
    disp ' ';  disp '===========================================================';

    for g=2:Ngroups; disp ' ';
        disp '*********************';
        disp(GroupNames{g});
        disp '*********************'; disp ' ';
        for i=2:Noccs;
            % TauW
            missingTauW=(isnan(squeeze(TauW(i,g,:))) | (squeeze(TauW(i,g,:))==1) );
            if all(missingTauW); 
                disp 'All TauW missing. Stopping...'; keyboard;
            elseif any(missingTauW);
                cshow(['TauW ' ShortNames{i}],squeeze(TauW(i,g,:))','%8.4f',[],'nonee',1);
                TauW(i,g,:)=fixmissing(squeeze(TauW(i,g,:)),missingTauW);
                cshow(['TauW ' ShortNames{i}],squeeze(TauW(i,g,:))','%8.4f',[],'nonee',1);
            end;
    
            % TauH
            missingTauH=(isnan(squeeze(TauH(i,g,1:6))) | isinf(squeeze(TauH(i,g,1:6))) );
            if all(missingTauH); 
                disp 'All TauH missing. Stopping...'; keyboard;
            elseif any(missingTauH);
                cshow(['TauH ' ShortNames{i}],squeeze(TauH(i,g,:))','%8.4f',[],'nonee',1);
                TauH(i,g,1:6)=fixmissing(squeeze(TauH(i,g,1:6)),missingTauH);
                cshow(['TauH ' ShortNames{i}],squeeze(TauH(i,g,1:6))','%8.4f',[],'nonee',1);
            end;

            % Z
            %missingZ=(isnan(squeeze(Z(i,g,1:6))) | (squeeze(Z(i,g,1:6))==1) );
            missingZ=isnan(squeeze(Z(i,g,1:6)));
            if all(missingZ); 
                disp 'All Z missing. Stopping...'; keyboard;
            elseif any(missingZ);
                cshow(['Z ' ShortNames{i}],squeeze(Z(i,g,:))','%8.4f',[],'nonee',1);
                Z(i,g,1:6)=fixmissing(squeeze(Z(i,g,1:6)),missingZ);
                cshow(['Z ' ShortNames{i}],squeeze(Z(i,g,1:6))','%8.4f',[],'nonee',1);
            end;

            % TgHome
            missingTgHome=(isnan(squeeze(TgHome(i,g,1:6))) | isinf(squeeze(TgHome(i,g,1:6))) );
            if all(missingTgHome); 
                disp 'All TgHome missing. Stopping...'; keyboard;
            elseif any(missingTgHome);
                cshow(['TgHome ' ShortNames{i}],squeeze(TgHome(i,g,:))','%8.4f',[],'nonee',1);
                TgHome(i,g,1:6)=fixmissing(squeeze(TgHome(i,g,1:6)),missingTgHome);
                cshow(['TgHome ' ShortNames{i}],squeeze(TgHome(i,g,1:6))','%8.4f',[],'nonee',1);
            end;
        
        end; % Occupations
    end; % Groups
    % Zero out the home sector tau's -- otherwise NaNs can mess up sums later
    TauW(1,:,:)=zeros(Ngroups,Nyears);
    TauH(1,:,:)=zeros(Ngroups,Ncohorts);
    

%% Part IIIB
% Compute AvgQuality and Human capital levels    
    
    AvgQuality=zeros(Noccs,Ngroups,Ncohorts,Nyears);
    for g=1:Ngroups; % This separate looping is needed!!
        % Calculate Average Quality of Workers
        for c=1:Ncohorts;
            % Note well: AvgQuality *includes* the TExperience (since that will enter H(.) later).
            AvgQuality(:,g,c,:)=squeeze(Earnings(:,g,c,:))./squeeze((1-TauW(:,g,:)))./w; %./squeeze(TExperience(:,g,c,:));
        end;    
        AvgQuality(isnan(AvgQuality))=0; % Replace NaNs with zeros (bc TauW=1 when noone in Forest)
        AvgQuality(isinf(AvgQuality))=0; % Replace Infss with zeros (bc TauW=1 when noone in Forest)
    
    end;

    % Get H(i,t) by adding up across cohorts and groups
    % Note: AvgQuality calculated above already implicitly includes Texp
    H=zeros(Noccs,Ngroups,Ncohorts,Nyears); % Efficiency units in each cell
    for i=1:Noccs;
        H(i,:,:,:)=q.*squeeze(p(i,:,:,:)).*squeeze(AvgQuality(i,:,:,:));
    end;
    Higt=squeeze(sum(H,3)); % Add over cohorts

    Hyoung=zeros(Noccs,Ngroups,Nyears);
    for t=1:Nyears;
        cYoung=CohortConcordance(t,2);
        Hyoung(:,:,t)=squeeze(H(:,:,cYoung,t));
    end;



%% Part IV
% Calculate equivalent subsidy level to white men
% a.	Function to use: solvefor_WMtau.m
% b.	Data to save: wm_rent.mat (subsidy rate to white men)

    % Zero out NaNs only for the revenue calculations 
    %TauWNaN0=TauW; TauWNaN0(isnan(TauW))=0;
    %TauHNaN0=TauH; TauHNaN0(isnan(TauH))=0;

    
    if WMequals0==0; % Solve for tau's for WM to dissipate revenue.
        % Given the *relative* tau's, solve for the tauhWM and tauwWM that zero out aggregate revenue
        [wm_tauw_mat,wm_tauh_mat,blahTauWabs,blahTauHabs,RevenueTauW,RevenueTauH]=solvefor_WMtau(TauW,TauH,w,Higt,Hyoung,eta,Noccs,Ngroups,Ncohorts,Nyears);
        
        % Display Output and Save
        label=['TauW   ';'TauH   '];
        disp ' ';
        disp ' Equivalent tax/subsidy to white men over time that leads to Zero Revenue';
        tle='1960 1970 1980 1990 2000 2010';
        cshow(label,[wm_tauw_mat; wm_tauh_mat],'%14.4f %14.4f %14.4f %14.4f %14.4f %14.4f',tle);
        %save wm_rent.mat wm_tauw_mat wm_tauh_mat  % Do not save TauWabs -- based on 0's in place of NaNs
    end;
        


% %% Part V
% % Estimate w(i), s(i) and phi(i) from white men given subsidy rates from Part IV
% % a.	Function to use: solvefor_w_phi_givensubsidy.m
% % b.	Data to save: wphis_rent_new.mat (estimated w, s, and phi)


%     % % Recover w(i), s(i), and phi(i) from WM
%     ShowData=1;

%     %load wphis_rent_old
%     w_old=w(1,:);
%     [w,phi,s,pwm,mwm,twmhomeC]=solvefor_w_phi_givensubsidy(wm_tauw_mat,wm_tauh_mat,eta,beta,theta,gam,sigma,phiFarm,lambda,ShowData);
%     w_new=w(1,:);
%     %save wphis_rent_new.mat w phi s pwm mwm twmhomeC;

%     if WMequals0==0; % If we need to iterate b/c of wm_tau to zero out rents
%         disp 'The option of WMequals0~=0 has not been fully implemented. This will not work!'; 
%         disp 'Note that the saved files here do not inherit the CaseName, so do not run more than one case at a time.';
%         keyboard;
%         ssr(iter)=sum(abs(w_new-w_old))  % Iterating until wHome changes are very small...
%         save ssr.mat ssr;
%         filename=['total_' num2str(iter)];
%         save(filename);
%     end;
%     end_criteria=sum(abs(w_new-w_old))
%    iter=iter+1
%end

%save wm_rent_final.mat wm_tauw_mat wm_tauh_mat
%save wphis_final.mat w phi s pwm mwm twmhomeC

% Variables to save
phiAll=[zeros(Noccs,2)*NaN phi]; % 1940 1950 ... 2010 Order in solvefor_w_phi_givensubsidy
phi_C=flipud(phiAll')';
HAllData=H;
Hit=squeeze(sum(Higt,2)); % Add over groups
TgHome(:,WM,:)=twmhomeC;
TgHome(1,1,:)=1; % For WM THOME=1

save(['EstimateTauZ2Data_' CaseName],'TauW','TauH','Z','TgHome','phi_C','Thome_shifter', 'TigYMO', ...
     'AvgQuality','H','HAllData','Higt','Hit','wm_tauw_mat','wm_tauh_mat','tauhat','tauhat_y', ...
     'w','phi','s','pwm','mwm','twmhomeC','earningsweights','THOME','TExperience','Tbar','Nymo');

diary off;


