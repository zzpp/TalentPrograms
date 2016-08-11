
% estimatetauz.m
%
%  This is a sub-program to EstimateTauZ2. In particular, this code calls
%  eval_young and eval_middle to estimate TauW, TauH, Z, and TgHome.
%
%  We break it out into a separate piece so that we can call it twice.
%   -- The first time through we estimate TgHome for each decade.
%   -- The second time through we impose min(TgHome) across the decades for each occ,
%      so that TgHome is constant over time.
%
%  First broken out on 10/12/15.

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3a. Solve the Problem of the Young Cohort
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if c==1 | FiftyFiftyTauHat;
        initialtauw0=[]; % For 1960 or FiftyFifty robustness, we use alpha_set instead of passing a given tauw0
    else;                % For later cohorts we use given TauW from previous cohort (who is now middle aged)
        initialtauw0=TauW1;
    end;

    % Estimate Mg to match “average of Z = 1” condition
    Cohort=7-c;
    Zocc=22  % Sales
    [x_young(c,:,:),est_mg(c),THOME(g,c)]=eval_young(alpha_set,PwY_target,initialtauw0,mwm,g,Cohort,c,w,phi,s,p,Earnings,tauhat,TExperience,eta,beta,theta,gam,lambda,TgHome_g,FiftyFiftyTauHat,LFPMinFactor,THOME1960,Tbar,Zocc,ConstrainTauH); %,StopIt);

    % Display Output
    disp ' ';
    disp ' ';
    disp '------------------------';
    fprintf(' Cohort %1.0f (Young in %4.0f)\n',[Cohort Decades(c)]);
    disp ' Calculation for the young';
    disp '------------------------';
    disp ' ';
    fprintf(' Converged Mg = %12.8f\n',est_mg(c)./mwm(c));
    fprintf('     THOME(g) = %8.4f\n',THOME(g,c));
    fprintf('  sum(ptilde0)= %8.4f\n',nansum(x_young(c,:,3)));
    fmt='%10.3f %10.3f %10.3f %10.3f %8.3f %8.3f %9.3f %9.3f %15.1f %10.3f %10.1f';
    tle='p_data p_implied ptilde0 PworkY z alpha TauHat TauW TauH Tghome wtilde';
    cshow(ShortNames,[squeeze(x_young(c,:,:))],fmt,tle);

  
    % Descriptive Statistics for Tghome
    TgHome_g=x_young(c,:,10)';
    x_young(c,HOME,10)=THOME(g,c); % Store THOME in TgHome(1) for reporting and SolveEqm stuff
    z_mat=x_young(c,:,5);
    stat_Thome_z=zeros(2,2)*NaN;
    stat_Thome_z(:,1)=[mean(TgHome_g(isfinite(TgHome_g)));std(TgHome_g(isfinite(TgHome_g)))];
    stat_Thome_z(:,2)=[mean(z_mat(isfinite(z_mat)));std(z_mat(isfinite(z_mat)))];
    label=['mean   ';'std dev'];
    disp ' ';
    disp ' Sample statistics';
    tle='Thome_Young Z';
    cshow(label,[stat_Thome_z],'%16.4f %16.4f',tle);

    pwork_max=nanmax(x_young(c,:,4)); 
    pwork_min=nanmin(x_young(c,:,4)); 
    if pwork_max>100 | pwork_min<0; fprintf('Pwork max=%8.3f   min=%8.3f\n',[pwork_max pwork_min]); disp 'Pwork error...'; keyboard; end;
    alpha=squeeze(x_young(c,:,6)); % For 1960 second pass to eval_middle. Crucial: this is how tauw is passed.

    if c==1;
        Alpha1MiddleSplit(:,g,1)=x_young(c,:,6); % Save the 1960 split from eval_young. Rest is from eval_middle
    end;
    if abs(x_young(c,1,1)-x_young(c,1,2))>1; 
        disp 'Stopping: p_data(HOME) is too far from p_implied(HOME)... in estimatetauz.m'; keyboard;
    end;
    if abs(nansum(x_young(c,:,3))-100)>1;
        disp 'sum(ptilde0) is too far from 100%. Stopping...'; keyboard;
    end;
    
    
  
    if c==1 | FiftyFiftyTauHat; % For 1960 cohort or FiftyFifty robustness, assign the split we've estimated
        TauWsplit=squeeze(x_young(c,:,8))';
        est_TauW(:,g,c)=TauWsplit; % young
        est_TauH(:,g,c)=(squeeze(tauhat(:,g,c)).*(1-TauWsplit)).^(1/eta)-1; % young
    end;

    
if c~=6 & ~FiftyFiftyTauHat; % No need to solve for the Middle in the last year or if split 50/50
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3b. Solve the Problem of the Middle in the Next Year
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Estimate TauW for the middle in the next year using eval_middle.m
    x_middle(c,:,:)=eval_middle(Thome_shifter(c,:),alpha,initialtauw0,Weights,TgHome_g,z_mat,mwm,g,Cohort,w,phi,s,p,Earnings,tauhat,TExperience,eta,beta,theta,gam,est_mg(c),lambda,THOME,Tbar,ConstrainTauH);

    % Display Output
    disp ' ';
    disp ' ';
    disp '------------------------';
    fprintf(' Cohort %1.0f (Young in %4.0f)\n',[Cohort Decades(c)]);
    disp ' Calculation for the middle (i.e. when this cohort goes from Y to M)';
    disp '------------------------';
    tle='ThomeY ThomeM ThomeO TauW0 TauW1 gapPW gap_w1 PWdata PW_est W1_data W1_est p1_data p1_est ptilde0 alphaM';
    cshow(ShortNames,[squeeze(x_middle(c,:,1:15))],'%8.3f',tle);
    %Alpha1MiddleSplit(:,g,c+1)=x_middle(c,:,12); % Save the alpha split recovered from Y to M
    
    % Descriptive Statistics for TauW
    TauW0=x_middle(c,:,4)';
    TauW1=x_middle(c,:,5)';
    stat_TauW=zeros(2,2)*NaN;
    stat_TauW(:,1)=[mean(TauW0(isfinite(TauW0)));std(TauW0(isfinite(TauW0)))];
    stat_TauW(:,2)=[mean(TauW1(isfinite(TauW1)));std(TauW1(isfinite(TauW1)))];
    label=['mean   ';'std dev'];
    disp ' ';
    disp ' Sample statistics';
    tle='TauW0 TauW1';
    cshow(label,[stat_TauW],'%16.4f %16.4f',tle);

    pwork_max=nanmax(x_middle(c,:,9)); 
    pwork_min=nanmin(x_middle(c,:,9)); 
    if pwork_max>1 | pwork_min<0; fprintf('Pwork max=%8.4f   min=%8.4f\n',[pwork_max pwork_min]); disp 'Pwork error...'; keyboard; end;
    
    % Every cohort in a year shares the same TauW
    est_TauW(:,g,c+1)=TauW1; % young
    est_TauH(:,g,c+1)=(squeeze(tauhat(:,g,c+1)).*(1-TauW1)).^(1/eta)-1; % young

end; % if c~=6

%disp 'Stopping in estimatetauz.m'; abc