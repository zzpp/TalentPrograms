% GetTExperience.m
%
%  Called from EstimateTauZ2.m to compute TExperience
%  (a block of code, rather than a function).
%
% TigYMO -- WM experience terms from WM wages.  Occupation-cohort-age specific 
%   Replacing what Erik had done.
%
% Estimate occupation-cohort-age specific TExperience terms from male's wage
% Note that TExperience for the young = 1 for every occupations
%
%  4/18/16 -- Lifecycle Tbar -- only coded for SameExperience=1
%     That is, all occupations have the same Tbar

if SameExperience~=1;
    disp 'GetTExperience.m has not been updated for heterogeneous experience. Stopping.';
    disp '(Though we do allow some flexibility for NoBrawny and NoFrictions2010)';
    keyboard;
end;

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
    

    % Fix missing values in a systematic way
    disp ' '; disp '===========================================================';
    disp 'GetTExperience.m:';
    disp 'Fixing tauhat_y missing values --> tauhat_y_cleaned (just for robustness cases)';
    disp ' -- Use first non-missing value';
    disp ' ';  disp '===========================================================';

    % tauhat_y
    tauhat_y_cleaned=tauhat_y;
    for g=2:Ngroups; disp ' ';
        disp '*********************';
        disp(GroupNames{g});
        disp '*********************'; disp ' ';
        for i=2:Noccs;
            % tauhat_y
            missingtauhat_y_cleaned=(isnan(squeeze(tauhat_y_cleaned(i,g,:))) | isinf(squeeze(tauhat_y_cleaned(i,g,:))));
            if all(missingtauhat_y_cleaned); 
                disp 'All tauhat_y_cleaned missing. Stopping...'; keyboard;
            elseif any(missingtauhat_y_cleaned);
                cshow(['tauhat_y_cleaned ' ShortNames{i}],squeeze(tauhat_y_cleaned(i,g,:))','%8.4f',[],'nonee',1);
                tauhat_y_cleaned(i,g,:)=fixmissing(squeeze(tauhat_y_cleaned(i,g,:)),missingtauhat_y_cleaned);
                cshow(['tauhat_y_cleaned ' ShortNames{i}],squeeze(tauhat_y_cleaned(i,g,:))','%8.4f',[],'nonee',1);
            end;
        end; % Occupations
    end; % Groups




Nymo=3; % Y=1,M=2,O=3 are the three indexes in the YMO structure
TigYMO=ones(Noccs,Nyears,Nymo); % For WM. 

for t=1:5;
    Cohort=7-t;
    wagebar_y=squeeze(Earnings(:,WM,Cohort,t));
    wagebar_m=squeeze(Earnings(:,WM,Cohort,t+1));
    if t==5;
        wagebar_o=zeros(67,1)*NaN;
    else;
        wagebar_o=squeeze(Earnings(:,WM,Cohort,t+2));
    end;
    pig_y=squeeze(p(:,WM,Cohort,t));
    pig_m=squeeze(p(:,WM,Cohort,t+1));
    if t==5;
        pig_o=zeros(67,1)*NaN;
    else;
        pig_o=squeeze(p(:,WM,Cohort,t+2));
    end;
    w_m=w(:,t+1);
    w_y=w(:,t);
    if t==5;
        w_o=zeros(67,1);
    else;
        w_o=w(:,t+2);
    end;
    s_y=s(:,t);     s_m=s(:,t+1);
    phi_y=phi(:,t); phi_m=phi(:,t+1);
    if t==5;
        s_o=zeros(67,1);  phi_o=zeros(67,1);
    else;
        s_o=s(:,t+2);     phi_o=phi(:,t+2);
    end;
    % Note well: pig_m/pig_y is the same as Pwork_m/Pwork_y since ptilde is constant within cohort.
    TigYMO(:,t,2)=(wagebar_m./wagebar_y)./((pig_m./pig_y).^(-mu))./(w_m./w_y)./(s_y.^phi_m./s_y.^phi_y); % middle
    TigYMO(:,t,3)=(wagebar_o./wagebar_y)./((pig_o./pig_y).^(-mu))./(w_o./w_y)./(s_y.^phi_o./s_y.^phi_y); % old
end;

% Thome_shifter = returns to experience in the Home sector
%Thome_shifter=[1 1 1 1 1; 1 1 1 1 1];
disp 'Augment Thome due to returns to experience; by same amount each decade for now'
% Obtain as aggregate earnings-weighted average of TigYMO -- Noccs x Nyears x Nymo
earningsweights=div(AggIncomeData_it,nansum(AggIncomeData_it,1));
earningsweights_avg=mean(earningsweights')';  % Noccs x 1
Thome_shifter=zeros(Nyears,Nymo)*NaN;    % Years x YMO
for t=1:Nyears;
    TigYMO_avg=nansum(mult(squeeze(TigYMO(:,t,:)),earningsweights_avg));
    Thome_shifter(t,:)=TigYMO_avg;
end;
% Just use averages -- too much noise...
%Thome_shifter=mult(ones(Nyears,Nymo),mean(Thome_shifter(2:4,:)))
Thome_shifter=mult(ones(Nyears,Nymo),HomeExperience);

% SameExperience option: use same returns to experience in all occupations
%  -- Use the earnings-weighted average returns in each year.
%  -- and same value returns to experience in home
if SameExperience==1;
    for t=1:Nyears;
        TigYMO_avg=nansum(mult(squeeze(TigYMO(:,t,:)),earningsweights(:,t)));
        if t==5; % Then update for Old
            TigYMO_avg(3)=Thome_shifter(t-1,3)/Thome_shifter(t-1,2)*TigYMO_avg(:,2); % Inflate middle
        elseif t==6; % Update for Middle and Old
            TigYMO_avg=Thome_shifter(t-1,:); % Same as previous decade
        end;
        TigYMO(:,t,:)=mult(ones(Noccs,3),TigYMO_avg);
        Thome_shifter(t,:)=TigYMO_avg; % and same at home
    end;
    %    Tbar=sum(TigYMO(8,:,:),3)'
    %Tbar=3*ones(Nyears,1) % Tbar=3 for checking
    %Tbar=[3 3.1 3.2 3.3 3.4 3.5]'
end;
Thome_shifter


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% T(i,g) = TExperience_y * TigYMO with GroupExpAdjustment
%    where
%       TExperience_y = 1 normally, or different for Brawny occs or NoFrictions2010
%         TigYMO      = Baseline experience adjustment from WM (cohort specific)
%    GroupExpAdjustment = Adjustment to experience for groups based on LFP (adjusts endogenously in counterfactuals)
%
%    Need to do all of this now, so we can compute tauhat *including* all terms in That
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TExperience_y:
%        True:  tauhat=That.^(1-eta).*relp.^(-1/theta) .* wagegap.^(-(1-eta)).*TbarHat^eta;
%        Want: tauhat=1 ==> That.^(1-eta)= 1 / ( relp.^(-1/theta) .* wagegap.^(-(1-eta)).*TbarHat^eta )
%                               = That.^(1-eta)./tauhat
%                so That_new = That_old ./ tauhat.^(1/(1-eta))
%        and recall TExperience(WM)=1.

TExperience_y=ones(size(tauhat_y));   % Noccs x Ngroups x Nyears
for t=1:Nyears;
    That_y(:,:,t)=That(:,:,7-t,t);
end;
if IgnoreBrawnyOccupations; % Then recover T(i,g) in those occs to yield tauhat=1
    % BrawnyOccupations (T/F) from Names67Occupations.m from Rendall
    % Assume no frictions for WW. Allow frictions for BW, but assume T(BW)=T(WW)
    TExperience_y(BrawnyOccupations,WW,:)=That_y(BrawnyOccupations,WW,:)./tauhat_y_cleaned(BrawnyOccupations,WW,:).^(1/(1-eta));  % Only decide occupation when young
    TExperience_y(BrawnyOccupations,BW,:)=That_y(BrawnyOccupations,WW,:)./tauhat_y_cleaned(BrawnyOccupations,WW,:).^(1/(1-eta));  % Use WW T's for BW
end;
if NoFrictions2010; % Then recover T(i,g) to yield tauhat=1 in 2010
    for t=1:Nyears; % Take from 2010, apply to all young cohorts 
        TExperience_y(:,:,t)=That_y(:,:,6)./tauhat_y_cleaned(:,:,6).^(1/(1-eta));  % 2010 = 6th decade. 
    end;
end;

% GroupExpAdjustment:
% Calculate common adjustment factor for experience accumulation
% Note that TigYMO calculated before is the maximum experience accumulation
%
% This adjusts the experience term for women to account for the fact
% that they have less experience than white men when LFP is rising rapidly over the life cycle
% (common adj for all occs)
% (e.g. Middle aged women enter the LF for the 1st time, not having worked when young, and so have less experience than WM) 
    
GroupExpAdjustment=ones(Ngroups,Nyears,Nymo); % YMO structure
for t=1:5;
    Cohort=7-t; % Cohort that is young at date t
    pY=squeeze(p(:,:,Cohort,t));
    pM=squeeze(p(:,:,Cohort,t+1)); % When middle aged
    lfpY=sum(pY(2:Noccs,:))'; % Labor Force Participation rate  Ngroupsx1
    lfpM=sum(pM(2:Noccs,:))'; 
    GroupExpAdjustment(:,t,2)=lfpY./lfpM /(lfpY(WM)/lfpM(WM)); % Adjust experience when M using LFP when Y vs M (rel to WM)
    if t<5; 
        pO=squeeze(p(:,:,Cohort,t+2)); 
        lfpO=sum(pO(2:Noccs,:))';  
        GroupExpAdjustment(:,t,3)=lfpY./lfpO /(lfpY(WM)/lfpO(WM)); % Adjust experience when O using LFP when Y vs O (rel to WM)
    end; % When middle aged
end; % Loop over young cohorts
GroupExpAdjustment(GroupExpAdjustment>1)=1; % Do not allow adjustment larger than 1 -- Chang's min(cf,1)

% Now compute T(i,g) = TExperience_y * TigYMO with GroupExpAdjustment
TExperience=zeros(size(p))*NaN;
for g=1:Ngroups; 
    for t=1:Nyears; % Loop over years when the young are born (time)
        Cohort=7-t;
        TExperience(:,g,Cohort,t)  =TExperience_y(:,g,t);  % Young
        TExperience(:,g,Cohort,t+1)=TExperience_y(:,g,t).*(1+(TigYMO(:,t,2)-1).*GroupExpAdjustment(g,t,2));  % Middle
        TExperience(:,g,Cohort,t+2)=TExperience_y(:,g,t).*(1+(TigYMO(:,t,3)-1).*GroupExpAdjustment(g,t,3));  % Old
    end;
    TExperience(:,:,:,7:8)=[]; % previous code creates two new decades;
    %What about in 1960 when we look at the 1950M women and 1940old women?
    %Let's just use the 1960 cohort adjustments. Cohort born in 1950 M=1960 O=1970
    %TExperience(:,g,7,1)=TExperience_y(:,g,1).*TigYMO(:,6,2).*GroupExpAdjustment(g,1,2); % Middle 
    % Actually, I don't think we ever use these, so just leave as NaNs 
end;

% That := T(i,g)/T(i,WM)
That=zeros(size(p)); % Need to resize TExperience_y for computing tauhat
for g=1:Ngroups;
    That(:,g,:,:)=TExperience(:,g,:,:)./TExperience(:,WM,:,:);
end;


% Finally, compute Tbar for all groups
% Have to adjust for future for 2000 and 2010 cohorts

Tbar=zeros(Noccs,Ngroups,Nyears)*NaN;
for g=1:Ngroups;
    for t=1:Nyears;
        if t<5;
            %Tbar(:,g,t)=sum(TExperience(8,g,7-t,(t:(t+2))));
            Tbar(:,g,t)=sum(squeeze(TExperience(:,g,7-t,(t:(t+2)))),2);
        elseif t==5;
            adjfactor=TExperience(:,g,3,6)./TExperience(:,g,3,5); %2010/2000
            Tbar(:,g,t)=TExperience(:,g,2,5)+TExperience(:,g,2,6).*(1+adjfactor);
        elseif t==6;
            Tbar(:,g,t)=Tbar(:,g,5); % Assume 2010 cohort = 2000 cohort
        end;
    end;
end;

TbarHat=ones(size(Tbar))*NaN;
for g=1:Ngroups;
    TbarHat(:,g,:)=div(Tbar(:,g,:),Tbar(:,WM,:));
end;

disp ' ';
disp 'Tbar and TbarHat by Group and Years for Doctors'
squeeze(Tbar(8,:,:))
squeeze(TbarHat(8,:,:))

disp ' ';
disp 'Tbar and TbarHat by Group and Years for FARM'
squeeze(Tbar(41,:,:))
squeeze(TbarHat(41,:,:))