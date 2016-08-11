
% solvefor_w_phi_givensubsidy.m: Estimate w(i) and phi(i) given subsidy rates to white men
%
%   Chad fixes on 8/25/15 related to 1-tauw in "term2" being replaced by (1+tauh)^eta
%   See my 8/25/15 notes in 2015-08-25-FixingSolve_w_phi.pdf
%   12/29/15 -- Get THome_CohortOrder as min across decades rather than 1960, consistent with other groups
%    4/4/16 -- Life cycle model

%   4/18/16 -- Includes T/Tbar in the wagebar/Pwork equations. But this requires Tbar estimates
%   Assume Ty=1.  Note Tbar=Nyearsx1 -- just for WM in this program.


function [W,PHI,S,PworkYWM,MWM,THome_CohortOrder]=solvefor_w_phi_givensubsidy(wm_tauw_mat,wm_tauh_mat,eta,beta,theta,gam,sigma,phiFarm,lambda,Tbar,ShowData);

%if exist('ShowData')~=1; ShowData=0; end;

global CaseName;
load(['CohortData_' CaseName '.mat']);

if exist('tauw')~=1; tauw=zeros(size(p)); end;
if exist('tauh')~=1; tauh=zeros(size(p)); end;

FARM=41+1  % This is the occupation number for Farm Non-Managers *after* dropping the two occs with missing values
HOME=1;
Mkt=2:Noccs; % Market Occupation numbers
Ty=1; % Implicitly assumed below, not passed to the functions.
Tbar=squeeze(Tbar(:,1,:)); % Pull WM ==> Noccs x Nyears

% Store results in Noccs x Decades matrices
W=zeros(Noccs,Nyears)*NaN;
PHI=W; S=W; PworkYWM=W; THome=W;
thome=[];
MWM=zeros(Nyears,1)*NaN;   % Nyears x 1


for loopthome=1:2;  % The first time we use time-varying thome, the second we impose the min across decades
    if loopthome==1; 
        disp ' ';
        disp 'First, we estimate allowing THome to differ by decade...';
        sectiontitle='          %4.0f  (thome varying)\n';
    else; 
        disp ' ';
        disp 'Now, we impose the minimum value of thome in each occ from across decades';
        thome=nanmin(THome')';
        tle='1960 1970 1980 1990 2000 2010 Min';
        disp 'Estimates of TgHome(WM) by Decade, together with the min value we will impose as constant...'
        cshow(ShortNames,[THome thome],'%8.3f',tle);
        sectiontitle='          %4.0f  (thome at min value)\n';
    end;
    
    % Loop over the decades
    for t=1:Nyears;

        disp ' '; disp ' ';
        disp '-------------------------------------------------------------';
        fprintf(sectiontitle,CohortConcordance(t,1));
        disp '-------------------------------------------------------------';

        YoungCohort=CohortConcordance(t,2);
        wagebar=squeeze(Earnings(:,:,YoungCohort,t)); 
        pt=squeeze(p(:,:,YoungCohort,t));

        wm_tauw=wm_tauw_mat(t);
        wm_tauh=wm_tauh_mat(t);

        if loopthome==1;
            thome=[]; % Let it vary by decade in the first loop
        end;
        pHome=1-sum(pt(Mkt,WM))
        f=@(ww) solveWHome(wm_tauw,wm_tauh,ww,wagebar,pt,lambda,beta,eta,theta,gam,FARM,phiFarm(t),pHome,thome,Tbar(:,t));
        wHome=fminsearch(f,1200);  % 1000 is a better starting point when theta=2
        %wHome=fminsearch(f,300); % for theta=1.42
        if wHome<0;
            iter=1;
            while wHome<0 && iter<4;
                wHome=fminsearch(f,1200/(3*iter));
                iter=iter+1;
            end;
            if wHome<0; disp 'wHome<0 error. stopping...'; keyboard; end;
        end;
        
        [err,pHomeEst,thome,mwm,Pwork,s,phi,w]=solveWHome(wm_tauw,wm_tauh,wHome,wagebar,pt,lambda,beta,eta,theta,gam,FARM,phiFarm(t),pHome,thome,Tbar(:,t));
        w(HOME)=wHome;

        fmt='%8.3f %8.3f %8.3f %8.1f %8.3f %8.3f %8.1f %8.1f %8.3f';
        tle='Pwork s phi w THome';
        cshow(OccupationNames,[Pwork s phi w thome],fmt,tle);

        mwm
        disp 'Note: We assumed values for phiFARM and phiHOME here...';
        disp '      and solved for wHome to match Labor Force Participation.';
        fprintf('pHome = %6.4f    pHomeEst = %6.4f\n',[pHome pHomeEst]); disp ' ';

        % Check for errors
        if abs(phiFarm(t)-phi(FARM))>1e-2; disp 'Error in phi(FARM) not matching up...'; keyboard; end;
        %  if abs(pHomeEst-pHome)>1e-2; disp 'Error in pHomeEst not matching up...'; keyboard; end;

        W(:,t)=w; PHI(:,t)=phi; S(:,t)=s; PworkYWM(:,t)=Pwork; MWM(t)=mwm; THome(:,t)=thome;

    end; % Looping over decades
end; % Two loops for thome
disp ' ';
disp 'Values for w(i,t) --- wage per unit of human capital';
tle='1960 1970 1980 1990 2000 2010';
cshow(OccupationNames,W,'%8.0f',tle);

disp ' '; disp ' ';
disp 'Values for phi(i,t)';
tle2='1960 1970 1980 1990 2000 2010';
cshow(OccupationNames,PHI,'%8.3f',tle2);

disp ' '; disp ' ';
disp 'Values for PworkYoungWM(i,t)';
cshow(OccupationNames,PworkYWM,'%8.3f',tle);

disp ' '; disp ' ';
disp 'Values for THomeWM(i,t)';
tle2='1940 1950 1960 1970 1980 1990 2000 2010';
cshow(OccupationNames,[ones(Noccs,2)*NaN THome],'%8.3f',tle2);

THome_CohortOrder=flipud([ones(Noccs,2)*NaN THome]')';

% --------------------------------------------------------
% FUNCTIONS 
% --------------------------------------------------------

function [error,pHomeEst,THome,mwm,Pwork,s,phi,w]=solveWHome(wm_tauw,wm_tauh,wHome,wagebar,p,lambda,beta,eta,theta,gam,FARM,phiFarm,pHome,thome,Tbar);

Noccs=length(p);
Mkt=2:Noccs; % Market occupations
WM=1;

% Use Farm to get mwm
% Estimate THome_farm
sFarm=1/(1+(1-eta)/beta/phiFarm);
wagebarFarm=wagebar(FARM,WM);
if isempty(thome);
    f=@(ss) e_solves_THfarm(ss,wm_tauw,wm_tauh,sFarm,wagebarFarm,wHome,phiFarm,lambda,beta,eta,theta,gam,pHome,Tbar(FARM));
    THfarm=fminsearch(f,1);
else;
    THfarm=thome(FARM);
end;
phiFarmHome=phiFarm^lambda;
term1=( (Tbar(FARM)*wagebar(FARM,WM)*(1-sFarm)^(1/beta))/(gam*eta^(eta/(1-eta))) )^(theta*(1-eta));
term2=((Tbar(FARM)*THfarm*wHome*sFarm^phiFarmHome*(1-sFarm)^((1-eta)/beta))^theta)/(1+wm_tauh)^(eta*theta);
mwm=term1-term2;

s=zeros(Noccs,1)*NaN; w=s; Pwork=s; phi=s; wagefit=s; 
if isempty(thome); THome=s; else; THome=thome; end;

for i=Mkt;
    fwage=@(ss) solves(wm_tauw,wm_tauh,ss,wagebar(i,WM),p(i,WM),mwm,wHome,lambda,beta,eta,theta,gam,pHome,THome(i),Tbar(i));
    [si,fval,flag]=fzerochad(fwage,[.5 .7],[1.2 1.05],5,0);
    if flag==-1; % fzerochad did not work, just minimize instead of a zero
        fwage2=@(ss) abs(fwage(ss));
        [si1,fval1]=fminbnd(fwage2,.1,.45);
        [si2,fval2]=fminbnd(fwage2,.45,.99);
        si=si2;
        if fval1<fval2 & fval2>200; si=si1; end;
    end;
    [err,wagefiti,wi,Pworki,phii,THomei]=fwage(si);
    s(i)=si; w(i)=wi; Pwork(i)=Pworki; phi(i)=phii; wagefit(i)=wagefiti; THome(i)=THomei;
    %if i==25 & Pworki>.19 & Pworki<.20; disp 'Professors'; keyboard; end;
    %if Pworki<.05; disp 'Pworki is low!'; keyboard; end;
end;

wm_tau=(1+wm_tauh)^eta/(1-wm_tauw);
wtilde=(w.*Tbar.*s.^phi.*(1-s).^((1-eta)/beta))./wm_tau; % 
mwm2=sum(wtilde(Mkt).^theta);
ptilde=wtilde.^theta/mwm2;
pfit=Pwork.*ptilde;
pHomeEst=1-sum(Pwork(Mkt).*ptilde(Mkt));

if isempty(thome);
    error = abs(1-sum(THome(isfinite(THome)))/66); % If estimating THome, target: average of THome = 1
else;
    error=abs(pHomeEst-pHome)*100; % Otherwise, match LFP
end;



function [error,wageimplied,w,Pwork,phi,THome]=solves(wm_tauw,wm_tauh,s,wagebar,p,mwm,wHome,lambda,beta,eta,theta,gam,pHome,THome,Tbar)
% See 2015-01-15-SolvingCohortModel notes. Fixing errors on 8/25 associated with tau~=1 for WM...

phi=(1-eta)/beta*s/(1-s); % Implied value phi from FOC for s
phiHome=phi^lambda;
if isnan(THome);
    PP=(Tbar*wHome*s^phiHome*(1-s)^((1-eta)/beta))^theta / ((1+wm_tauh)^(eta*theta)*mwm); 
    THome=((1/(1-pHome)-1)*1/PP)^(1/theta);
end;
PPP=(Tbar*THome*wHome*s^phiHome*(1-s)^((1-eta)/beta))^theta / ((1+wm_tauh)^(eta*theta)*mwm);
Pwork=1/(1+PPP);
wageimplied=gam*eta^(eta/(1-eta))*(mwm/Pwork)^(1/(theta*(1-eta)))*(1-s)^(-1/beta)*1/Tbar;

wm_tau=(1+wm_tauh)^eta/(1-wm_tauw);
w=(p*mwm/Pwork)^(1/theta) * wm_tau / (Tbar*s^phi*(1-s)^((1-eta)/beta));
%error=abs(wagebar-wageimplied);
error=wageimplied-wagebar;


function error=e_solves_THfarm(THfarm,wm_tauw,wm_tauh,sFarm,wagebarFarm,wHome,phiFarm,lambda,beta,eta,theta,gam,pHome,Tbar);

phiHome=phiFarm^lambda;
term1=( (Tbar*wagebarFarm*(1-sFarm)^(1/beta))/(gam*eta^(eta/(1-eta))) )^(theta*(1-eta));
term2=((Tbar*THfarm*wHome*sFarm^phiHome*(1-sFarm)^((1-eta)/beta))^theta)/(1+wm_tauh)^(eta*theta);
mwm=term1-term2;
PPP=(Tbar*THfarm*wHome*sFarm^phiHome*(1-sFarm)^((1-eta)/beta))^theta / ((1+wm_tauh)^(eta*theta)*mwm);
Pwork=1/(1+PPP);
error=abs(Pwork-(1-pHome));