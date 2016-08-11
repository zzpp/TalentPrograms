% eval_young.m: Evaluate model for the young (e.g. in 1960) 
% Returns both mg and x for evaluation. 
%     Pass empty TauW to generate a given alpha_set split of tauhat, or
%     Pass a value of TauW to take that as TauW0
%
%   TgHome = Varies by occupation, with mean=1
%   THOME  = Varies over time *and group* but not across occupation
%            (Recall wHome is a technological parameter, not a price!)
%
    
function [x,mg,THOME]=eval_young(alpha_set,PwY_target,TauW0,mwm,g,Cohort,c,w,phi,s,p,Earnings,tauhat,TExperience,eta,beta,theta,gam,lambda,TgHome,FiftyFiftyTauHat,LFPMinFactor,THOME1960,Tbar,Zocc,ConstrainTauH,StopIt);

    funTHOME=@(THOME) e_solveTHOME(THOME,alpha_set,PwY_target,TauW0,mwm,g,Cohort,c,w,phi,s,p,Earnings,tauhat,TExperience,eta,beta,theta,gam,lambda,TgHome,FiftyFiftyTauHat,LFPMinFactor,Tbar,Zocc,ConstrainTauH);

    if isempty(TgHome); 
        THOME=1; % For 1960, normalize THOME=1 and estimate TgHome
    elseif c==1 && ~FiftyFiftyTauHat;
        THOME=THOME1960; % ON 2nd pass, set initial value to rough average
    else;
        %THOME=fzerochad(funTHOME,[1 1.2],1.3,7);
        %THOME=fzerochad(funTHOME,[.8 1.2],1.3,7);  % 1/23/16 for eta=1/2 HomeExp=[1 1.20 1.35]
        upperbound=max([3 THOME1960+.5]);
        THOME=fminbnd(funTHOME,.4,upperbound);
        if THOME<.41 || THOME>(upperbound-.02); disp 'THOME close to bound...'; keyboard; end;
    end;    
    
    [err,x,mg]=funTHOME(THOME);
    
    
function [error,x,mg]=e_solveTHOME(THOME,alpha_set,PwY_target,TauW0,mwm,g,Cohort,c,w,phi,s,p,Earnings,tauhat,TExperience,eta,beta,theta,gam,lambda,TgHome,FiftyFiftyTauHat,LFPMinFactor,Tbar,Zocc,ConstrainTauH);
    
    Noccs=size(p,1); 
    wtilde=zeros(Noccs,1)*NaN;
    p_data=zeros(Noccs,1)*NaN;
    ptilde0=zeros(Noccs,1)*NaN;
    PworkYoung=zeros(Noccs,1)*NaN;
    z_implied=zeros(Noccs,1)*NaN;
    alpha=zeros(Noccs,1)*NaN;
    TauHatTrue=zeros(Noccs,1)*NaN;
    TauW=zeros(Noccs,1)*NaN;
    TauH=zeros(Noccs,1)*NaN;
    if isempty(TgHome); 
        TgHome=zeros(Noccs,1)*NaN;   
    end;

    % First, let's use solveocc to solve for mg by looking at the occupation Zocc where we
    % normalize z=1 and use wagebar to solve for mg
    if isempty(TauW0); 
        tauw0=[];        % This is the case for 1960 where we use the alpha_set to split tauhat
    else;
        tauw0=TauW0(Zocc);  % This the "given tauw" case for years after 1960
    end;
    mg=[];
    [x,mg]=solveocc(Zocc,mg,alpha_set,PwY_target,tauw0,g,Cohort,c,w,phi,s,p,Earnings,tauhat,TExperience,eta,beta,theta,gam,lambda,THOME,TgHome,FiftyFiftyTauHat,LFPMinFactor,Tbar,Zocc,ConstrainTauH);
    
    % Now we iterate over the rest to find z
    for occ=2:Noccs;
        if isempty(TauW0); 
            tauw0=[];        % This is the case for 1960 where we use the alpha_set to split tauhat
        else;
            tauw0=TauW0(occ);  % This the "given tauw" case for years after 1960
        end;
        [x,mg]=solveocc(occ,mg,alpha_set,PwY_target,tauw0,g,Cohort,c,w,phi,s,p,Earnings,tauhat,TExperience,eta,beta,theta,gam,lambda,THOME,TgHome,FiftyFiftyTauHat,LFPMinFactor,Tbar,Zocc,ConstrainTauH);
        wtilde(occ)=x(1);
        p_data(occ)=x(2);
        ptilde0(occ)=x(3);
        PworkYoung(occ)=x(4);
        z_implied(occ)=x(5);
        alpha(occ)=x(6);
        TauHatTrue(occ)=x(7);
        TauW(occ)=x(8);
        TauH(occ)=x(9);
        TgHome(occ)=x(10);
    end;
    
    p_implied=ptilde0.*PworkYoung;
    pHome=1-nansum(p_data(2:Noccs));
    pHomeEst=1-nansum(p_implied(2:Noccs));
    p_data(1)=pHome;
    p_implied(1)=pHomeEst;
    x=[p_data.*100 p_implied.*100 ptilde0.*100 PworkYoung.*100 z_implied alpha TauHatTrue TauW TauH TgHome wtilde];
    error=nansum(ptilde0)-1;    
    error=sum(error.^2);

    
function [x,mg]=solveocc(occ,mg,alpha_set,PwY_target,tauw0,g,Cohort,c,w,phi,s,p,wagebar,tauhat,Tig,eta,beta,theta,gam,lambda,THOME,TgHome,FiftyFiftyTauHat,LFPMinFactor,Tbar,Zocc,ConstrainTauH)
    % Find the z value so that occ wagebar matches earnings data.
    %  or if occ==Zocc, then set z=1 and find mg to match wagebar.
    
    HOME=1;
    wHome=w(HOME,c);
    p      =squeeze(p(occ,g,:,:));
    wagebar=squeeze(wagebar(occ,g,:,:));
    tauhat =squeeze(tauhat(occ,g,:));  
    Tig    =squeeze(Tig(occ,g,:,:));
    Tbar   =squeeze(Tbar(occ,g,:));
    s=s(occ,:);
    w=w(occ,:);
    phi=phi(occ,:);
    phiHome=phi(c)^lambda;
    TgHome =TgHome(occ);
    alpha0=alpha_set;

    % Step 1: Get tauw0
    if (isempty(tauw0) & isnan(TgHome)) | FiftyFiftyTauHat; % 1960 or FiftyFifty robustness ==> split tauhat acc to alpha_set
    	tauw0=1-tauhat(c)^(-alpha_set);
    elseif c==1 & ~isnan(TgHome); % This means it is our 2nd pass through for 1960: estimate alpha split to match PwY_target
        homestuff=TgHome*THOME*wHome*s(c)^phiHome;
        occstuff2 =Tig(Cohort,c)*w(c)*s(c)^phi(c);
        stuff=p(Cohort,c)*(homestuff/occstuff2)^theta;  % Uses p(Cohort,c) which is how we hit the p's
        alpha0=log((1-PwY_target(c))/stuff)/(theta*log(tauhat(c))); % Confirmed 2/1/16
        if alpha0<0; alpha0=0; end;
        if alpha0>1; alpha0=1; end;
        if isnan(alpha0); alpha0=alpha_set; end;
        if alpha0==0 || alpha0==1; % Then select TgHome to match PwY_target (from code below)
            TgHome=NaN;            % (invoked by NaN)
        end;
    	tauw0=1-tauhat(c)^(-alpha0);
    end;
    tauh0=(tauhat(c)*(1-tauw0))^(1/eta)-1;
    if tauh0<ConstrainTauH;  % Perhaps we do not allow tauh to be too close to -1...
        tauh0=ConstrainTauH;
        tauw0=1-(1+tauh0)^eta/tauhat(c);
        alpha0=-log(1-tauw0)/log(tauhat(c));
        TgHome=NaN;  % To match PwY_target
    end;
    
    % Step 2: Get PworkYoung
    if isnan(TgHome);
        % set Tghome to match probability of working at young
        if p(Cohort,c)==0||wagebar(Cohort,c)==0||isnan(p(Cohort,c))==1||isnan(wagebar(Cohort,c))==1;
            TgHome=NaN;
        else;
            homestuff2=THOME*wHome*s(c)^phiHome;
            occstuff =Tig(Cohort,c)*(1-tauw0)*w(c)*s(c)^phi(c);
            TgHome=occstuff/homestuff2*( (1-PwY_target(c))/p(Cohort,c) )^(1/theta);
            if TgHome<0 | ~isreal(TgHome); disp 'Negative TgHome. Weird. Stopping...'; keyboard; end;
        end;
    end; 

    homestuff=THOME*TgHome*wHome*s(c)^phiHome;
    occstuff =Tig(Cohort,c)*(1-tauw0)*w(c)*s(c)^phi(c);
    stuff=(homestuff/occstuff)^theta;
    PworkYoung=1-p(Cohort,c)*(homestuff/occstuff)^theta; 

    % If PworkYoung gets extremely small, adjust TgHome (e.g. LFPMinFactor=.5)
    if PworkYoung<LFPMinFactor*PwY_target(c);
        PworkYoung=LFPMinFactor*PwY_target(c);
        homestuff2=THOME*wHome*s(c)^phiHome;
        occstuff =Tig(Cohort,c)*(1-tauw0)*w(c)*s(c)^phi(c);
        TgHome=occstuff/homestuff2*( (1-PwY_target(c))/p(Cohort,c) )^(1/theta);
    end;
    
    
    % Step 3: If occ==Zocc, then solve for mg to match wagebar and set z=1
    %   Otherwise, use mg and solve wagebar for z
    gg=gam*eta^(eta/(1-eta));
    mu=(1/theta)*(1/(1-eta));
    if occ==Zocc;
        mg=PworkYoung*(wagebar(Cohort,c)*(1-s(c))^(1/beta)/gg*Tbar(c)/Tig(Cohort,c))^(theta*(1-eta));
        z=1;
    else;
        z=(gg*(mg/PworkYoung)^mu*Tig(Cohort,c)/Tbar(c)/wagebar(Cohort,c))^beta/(1-s(c)); 
    end;

    wtilde=Tbar(c)*w(c)*s(c)^phi(c)*((1-s(c))*z)^((1-eta)/beta)/tauhat(c);
    ptilde0=wtilde^theta/mg;
    
    p_data=p(Cohort,c);
    x=[wtilde; p_data; ptilde0; PworkYoung; z; alpha0; tauhat(c); tauw0; tauh0; TgHome];

    %if occ==23; disp 'Stopping in Secretaries'; keyboard; end;
    %if occ==41; disp 'Stopping in FarmMgrs'; keyboard; end;