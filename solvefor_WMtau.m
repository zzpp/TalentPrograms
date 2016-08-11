% solvefor_WMtau.m: Calculate equivalent subsidy rates (tauh and tauw) to white men
%
% Note well: All economic behavior in the model is invariant to the levels
% of the *common* tauh(WM) and tauw(WM). (common across occupation). So we
% do not need to resolve for the equilibrium objects!
%
%  TauW and TauH contain estimates of tau *relative to* WM. Here, we figure
%  out the equivalent subsidy rates to WM that will make total revenues
%  equal zero.
%
%  Step 1:  Guess values for tauw(WM) and tauh(WM).
%  Step 2:  Compute revenue (easy, since behavior is given).
%  Step 3:  Solve until total revenue from each tax is zero.
%
%  Note TauH is Noccs x Ngroups x Ncohorts and ordered by Cohort, not Time...
%  The returned TauHabs will be also...
%  However, wm_tauh_mat retains the 1xT order, like wm_tauw_mat.

function [tauwWM,tauhWM,TauWabs,TauHabs,RevenueTauW,RevenueTauH]=solvefor_WMtau(TauW,TauH,w,Higt,Hyoung,eta,Noccs,Ngroups,Ncohorts,Nyears)

    factor=1.5;
    NumTries=5;

    tauwWM0=[-.8 .1];
    for t=1:Nyears;
        f_tauwrevenue=@(tauwWM) tauw_revenue(tauwWM,TauW,t,w,Higt,Noccs,Ngroups);
        tauwWM(t)=fzerochad(f_tauwrevenue,tauwWM0,factor,NumTries);
        [total,TauWabs(:,:,t),RevenueTauW(:,:,t)]=tauw_revenue(tauwWM(t),TauW,t,w,Higt,Noccs,Ngroups);
    end;
    

    tauhWM0=[-.9 .1];
    TauHabs=zeros(Noccs,Ngroups,Ncohorts)*NaN;
    for t=1:Nyears;
        f_tauhrevenue=@(tauhWM) tauh_revenue(tauhWM,TauH,TauW,tauwWM,t,w,Hyoung,eta,Noccs,Ngroups);
        tauhWM(t)=fzerochad(f_tauhrevenue,tauhWM0,factor,NumTries);
        c=7-t; % Since TauH is ordered by cohort, not time.
        [total,TauHabs(:,:,c),RevenueTauH(:,:,t)]=tauh_revenue(tauhWM(t),TauH,TauW,tauwWM,t,w,Hyoung,eta,Noccs,Ngroups);
    end;

    
function [TotalRevenueTauW,TauWabs_t,RevenueTauW] = tauw_revenue(tauwWM,TauW,t,w,Higt,Noccs,Ngroups);
    
    TauWabs_t = 1 - (1-TauW(:,:,t))*(1-tauwWM); 
    RevenueTauW=zeros(Noccs,Ngroups);
    for g=1:Ngroups;
        RevenueTauW(:,g)=TauWabs_t(:,g).*w(:,t).*Higt(:,g,t);
    end;
    TotalRevenueTauW=sum(sum(RevenueTauW(2:Noccs,:)));

    
function [TotalRevenueTauH,TauHabs_c,RevenueTauH] = tauh_revenue(tauhWM,TauH,TauW,tauwWM,t,w,Hyoung,eta,Noccs,Ngroups);
  
    c=7-t; % Cohort
    %  (1+TauH(:,:,t))^eta = (1+TauHabs_t)^eta /(1+tauhWM)^eta 
    TauHabs_c = (1+TauH(:,:,c)) * (1+tauhWM) - 1;
    TauWabs_t = 1 - (1-TauW(:,:,t))*(1-tauwWM(t)); 
    RevenueTauH=zeros(Noccs,Ngroups);
    for g=1:Ngroups;
        RevenueTauH(:,g)=eta*TauHabs_c(:,g)./(1+TauHabs_c(:,g)).*(1-TauWabs_t(:,g)).*w(:,t).*Hyoung(:,g,t);
    end;
    TotalRevenueTauH=sum(sum(RevenueTauH(2:Noccs,:)));
