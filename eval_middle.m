
% eval_middle.m: Estimate TauW for the middle aged (e.g. the 1960 cohort in 1970)
% Merges old eval_middle.m and eval_young_giventauw. 
%     Pass empty TauW to generate a given alpha_set split of tauhat(c) for young, or
%     Pass a value of TauW to take that as TauW0

function x=eval_middle(Thome_shifter,alpha_set,TauW,Weights,Tghome_mat,z_mat,mwm,g,Cohort,w,phi,s,p,Earnings,tauhat,TExperience,eta,beta,theta,gam,mg,lambda,THOME,Tbar,ConstrainTauH)

    % Distribute Thome Shifter
    Noccs=size(p,1);
    Tghome=zeros(Noccs,3);
    Tghome(:,1)=Thome_shifter(1).*Tghome_mat;
    Tghome(:,2)=Thome_shifter(2).*Tghome_mat;
    Tghome(:,3)=Thome_shifter(3).*Tghome_mat;

    TauW0=zeros(Noccs,1)*NaN;
    TauW1=zeros(Noccs,1)*NaN;
    GAP_P1=zeros(Noccs,1)*NaN;
    GAP_W1=zeros(Noccs,1)*NaN;

    PWorkData=zeros(Noccs,1)*NaN;
    PWork1=zeros(Noccs,1)*NaN;
    PTilde0=zeros(Noccs,1)*NaN;

    P1_data=zeros(Noccs,1)*NaN;
    P1_est=zeros(Noccs,1)*NaN;
    W1_data=zeros(Noccs,1)*NaN;
    W1_est=zeros(Noccs,1)*NaN;
    AlphaSplit=zeros(Noccs,1)*NaN;

    % Solve the model (estimate TauW) for each occupation
    for occ=2:Noccs; 
        if isempty(TauW); 
            tauw0=[];        % This is the case for 1960 where we use the alpha_set to split tauhat
        else;
            tauw0=TauW(occ); % This the "given tauw" case for years after 1960
        end;
        z0=z_mat(occ);
        x=solveocc(Tghome,alpha_set,tauw0,Weights,z0,occ,g,Cohort,w,phi,s,p,Earnings,tauhat,TExperience,eta,beta,theta,gam,mg,lambda,THOME,Tbar,ConstrainTauH);
        TauW0(occ)=x(1);
        TauW1(occ)=x(2);
        GAP_P1(occ)=x(3);
        GAP_W1(occ)=x(4);
        PWorkData(occ)=x(5);
        PWork1(occ)=x(6);
        W1_data(occ)=x(7);
        W1_est(occ)=x(8);
        P1_data(occ)=x(9);
        P1_est(occ)=x(10);
        PTilde0(occ)=x(11);
        AlphaSplit(occ)=x(12);
    end;
    P1_data(1)=1-nansum(P1_data(2:Noccs));
    P1_est(1)=1-nansum(P1_est(2:Noccs));
    
x=[Tghome TauW0 TauW1 GAP_P1.*100 GAP_W1 PWorkData PWork1 W1_data W1_est P1_data P1_est PTilde0 AlphaSplit];


function x=solveocc(Tghome,alpha_set,tauw0,Weights,z0,occ,g,Cohort,w,phi,s,p,wagebar,tauhat,Tig,eta,beta,theta,gam,mg,lambda,THOME,Tbar,ConstrainTauH)
    
    HOME=1;
    c=7-Cohort;
    WeightPW=Weights(1);
    WeightWage=Weights(2);
    
    p      =squeeze(p(occ,g,:,:));
    wagebar=squeeze(wagebar(occ,g,:,:));
    tauhat =squeeze(tauhat(occ,g,:));
    Tghome =squeeze(Tghome(occ,:));
    Tig    =squeeze(Tig(occ,g,:,:));
    Tbar   =squeeze(Tbar(occ,g,:));
    THOME=THOME(g,c); % Cohort based
    wHome=w(HOME,:);  % Time based since from WM
    phiHome=phi(occ,:).^lambda;
    s=s(occ,:);
    w=w(occ,:);
    phi=phi(occ,:);

    if isempty(tauw0);
        tauw0=1-tauhat(c)^(-alpha_set(occ));
    end;
    homestuff=THOME*Tghome(1)*wHome(c)*s(c)^phiHome(c);
    occstuff =Tig(Cohort,c)*(1-tauw0)*w(c)*s(c)^phi(c);
    PworkYoung=1-p(Cohort,c)*(homestuff/occstuff)^theta;
    
    wtilde=(Tbar(c)*w(c)*s(c)^phi(c)*(1-s(c))^((1-eta)/beta)*z0^((1-eta)/beta))/tauhat(c);
    ptilde0=wtilde^theta/mg;
    t=c+1;
    PworkMiddle=p(Cohort,t)/ptilde0;
    if PworkMiddle>0.99; PworkMiddle=0.99; end;
    if PworkMiddle<0 || PworkMiddle>1; fprintf('PworkMiddle=%6.3f... Stopping in eval_middle!\n',PworkMiddle); keyboard; end;

    mu=1/theta*1/(1-eta);
    growthden=Tig(Cohort,c)*PworkYoung^(-mu)*w(c)*s(c)^phi(c)*(1-tauw0);

    if isnan(Tghome)==1; % For missing data in previous cohorts (e.g. Black Women Architects)
        tauhat1=tauhat(c+1);
        tauw1=1-tauhat1^(-alpha_set(occ));
        x=[NaN tauw1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
    else;
        wagegrowth1=wagebar(Cohort,t)/wagebar(Cohort,c);

        % Now estimate tauw1 in two ways (Pwork and wagegrowth) and take a weighted average.
        % First, from PworkMiddle:
        stuff1=wHome(t)*THOME*Tghome(2)*s(t)^phiHome(t) / (w(t)*Tig(Cohort,t)*s(t)^phi(t));
        tauw1P=1-(PworkMiddle/(1-PworkMiddle)*ptilde0)^(1/theta)*stuff1;
        
        % Now, from wagegrowth
        funW=@(tauw) e_wagegrowth(tauw,p(Cohort,c),p(Cohort,t),wagegrowth1,Tghome(2),Tig(Cohort,t),wHome(t),s(t),s(c),phiHome(t),w(t),phi(t),mg,eta,beta,theta,growthden,ptilde0,0,1,THOME);
        [tauw1W,fW,flagW]=fminbnd(funW,-2,.99);
        %testfzero(funW,(-1:.05:.99)); hold on; plot(tauw1W,fW,'ro'); wait;
        if flagW~=1; disp 'fminbnd e_wagegrowth in eval_middle error, stopping...'; keyboard; end;
        
        % Average the two and Returns the models values of PworkMiddle and wagegrowth
        tauw1 = 1 - (1-tauw1P)^WeightPW*(1-tauw1W)^WeightWage;  
        
        % Do not allow TauW<0 unless tauhat<1. That is, we require TauW and TauH to 
        % have the same sign; otherwise set TauW=0 or TauH=0.
        tauhat1=tauhat(c+1);
        tauh1=(tauhat1*(1-tauw1))^(1/eta)-1;
        if tauh1<ConstrainTauH;  % Perhaps we do not allow tauh to be too close to -1...
            tauh1=ConstrainTauH;
            tauw1=1-(1+tauh1)^eta/tauhat1;
        end;
        if tauw1<0 && tauh1>0; 
            if tauhat1>1;
                tauw1=0;
            else
                tauh1=0;
                tauw1=1-1/tauhat1;
            end;
        elseif tauw1>0 && tauh1<0;
            if tauhat1>1;
                tauh1=0;
                tauw1=1-1/tauhat1;
            else;
                tauw1=0;
            end;
        end;

        
        [e,mwagegrowth1,mPwork1,mpig1]=funW(tauw1);
        gap_p1 = abs(PworkMiddle-mPwork1);
        gap_w1 = abs(wagegrowth1-mwagegrowth1);
        alphasplit=-log(1-tauw1)./log(tauhat(c+1));  % Implied split of tauhat(c+1)
        x=[tauw0 tauw1 gap_p1 gap_w1 PworkMiddle mPwork1 wagegrowth1 mwagegrowth1 p(Cohort,t) mpig1 ptilde0 alphasplit];
        %if THOME>1 && Cohort<5 %g==2 && Cohort>=3 && occ==2;
        %if occ==22 && g==2;
        %    disp 'Stopping for Sales Managers in eval_middle...'; keyboard;
        %end;
    end;
    if isnan(tauw1); % For missing data in previous cohorts (e.g. Black Women Architects)
        tauhat1=tauhat(c+1);
        tauw1=1-tauhat1^(-alpha_set(occ));
        x=[NaN tauw1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
    end;
    %fprintf('Occ=%2.0f p1=%5.3f PWork=%5.3f\n',[occ mpig1 mPwork]);
    %keyboard

    
function [ssr,mwagegrowth,mPwork,mpig]=e_wagegrowth(tauw,pig_y,pig,wagegrowth,Tghome,Tig,wHome,s,s_y,phiHome,w,phi,mg,eta,beta,theta,growthden,ptilde0,WeightPig,WeightWage,THOME);

    pstuff=THOME*Tghome*wHome*s^phiHome / ((1-tauw)*Tig*w*s^phi);
    mPwork=1/(1+ptilde0*pstuff^theta);
    mpig=ptilde0*mPwork;

    % wagebar(c,t) -- assumes wage growthden already passed
    mu=1/theta*1/(1-eta);
    growthnum=Tig*mPwork^(-mu)*w*s_y^phi*(1-tauw);
    mwagegrowth=growthnum/growthden;
    e  = (mwagegrowth-wagegrowth);  
    ssr=e^2;
    %if mPwork<.11 && mPwork>.10; disp 'pausing in eval_middle... .103?'; keyboard; end;
    
    
