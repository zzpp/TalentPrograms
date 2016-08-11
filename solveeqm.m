function [w,H,wtilde,HModelAll,pmodel,Pwork]=solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar); 

% function [w,H,wtilde,HModelAll,pmodel,Pwork]=solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar);    7/2/15
%
% Given a guess for x=[mgtilde Y] 5x1 and a year t (e.g. 1=1960), 
% solve for w(i) in year t
%
% Returns w,H ==> Noccs x 1   and wtilde ==> Noccs x Ngroups
%    and HModelAll, pmodel, Pwork ==> Noccs x Ngroups x YMO


global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData HAllData 
global TauW_C phi_C mgtilde_C w_C StopHere % For keeping track of history in solution

mgtilde_t=x(1:4);
Y_t=x(5);

% Update the History variables with our candidate answers
ct=7-t; % ct := The "cohort" entry (1..8) corresponding to Year t
mgtilde_C(:,ct)=mgtilde_t;
w=zeros(Noccs,1);
H=zeros(Noccs,1);
wtilde=zeros(Noccs,Ngroups);
HModelAll=zeros(Noccs,Ngroups,3); %Noccs x Ngroups x YMO
pmodel=zeros(Noccs,Ngroups,3); %Noccs x Ngroups x YMO
Pwork=zeros(Noccs,Ngroups,3); %Noccs x Ngroups x YMO
w0=[5000 10000]; fzerofactor=[2 1.4]; NumTries=1000;
if theta>3;
    w0=[2000 4000]; fzerofactor=[2 1.4]; NumTries=1000;
end;

 % i=2
 % e_HSupplyDemand(3850)
 % e_HSupplyDemand(w0(1))
 % e_HSupplyDemand(w0(2))
 % wi=fzerochad(@e_HSupplyDemand,w0,fzerofactor,NumTries,1)
 % % for i=2:Noccs;
 % %     i
 % %     e_HSupplyDemand(3850)
 % % end;
 % keyboard
 % abc
 
for i=2:Noccs; % Excluding occ=1 Home
    fSupplyDemand=@(w) e_HSupplyDemand(w);
    %if i==25; disp 'i=25 stopping'; keyboard; end;
    wi=fzerochad(fSupplyDemand,w0,fzerofactor,NumTries);
    %wi=fzerochad(@e_HSupplyDemand,w0,fzerofactor,NumTries);
    [resid,Hi,wtildei,HAlli,pmodeli,Pworki]=e_HSupplyDemand(wi);
    w(i)=wi;
    H(i)=Hi;
    wtilde(i,:)=wtildei;
    pmodel(i,:,:)=pmodeli; 
    HModelAll(i,:,:)=HAlli;
    Pwork(i,:,:)=Pworki;
    %if i==23 && StopHere==1;
    %    StopHere=2;
    %    fSupplyDemand(wi);
    %end;
    w0=[.7*wi 1.4*wi];
end;
pmodel(1,:,:)=1-sum(pmodel(2:Noccs,:,:)); % fill in Home for LFP

% ----------------------------------
% NESTED FUNCTIONS (inherit variables)
% ----------------------------------

    function [resid,Hdemand,wtilde_i,HAll_i,pmodel_i,Pwork_i]=e_HSupplyDemand(wi);  % Nested function -- can see the other variables in play.
    
        Hdemand=A(i,t).^(sigma-1)./wi^sigma*Y_t;
        Hsupply=0;
        w_C(i,ct)=wi; % Update with candidate
        wH_t=wH_T(t); % Technology parameter for home production: "wage" per unit talent
                
        % Hsupply requires more work. Also, special treatment for 1960 and 1970 because of 1940/50 cohorts
        % We take the basic data as given for 1950/1940 cohorts and only adjust LF participation bc of TauW
        
        for ymo=0:2; % Loop over Y/M/O cohorts in year t. All groups at same time as 1x4 vectors
            c=CohortConcordance(t,2+ymo); % Cohort index for YMO in year t
            % Pull out the relevant parameters -- date t
            phi_t=phi(i,t);
            tauw_t=TauW(i,:,t);
            
            if c==8; % 1940 cohort ==> use previous term1 from 1950
                % For PworkYoung, Chang assumes *same* for all occs and equals LFP rate for young 
                PW_estimate=sum(squeeze(pData(2:Noccs,:,6,t+2))); % t+2 means we compare O to O
                pig_data=squeeze(pData(i,:,c,t));
                ptilde_c=pig_data./PW_estimate;
                
                % Adjust participation for any change in tauw relative to data (e.g. for counterfactual)
                tauw_orig=TauW_Orig(i,:,t);
                %pwnum_pwden=(1./PW_estimate-1)./ptilde_c;
                PW_t=1./(1+(1./PW_estimate-1).*((1-tauw_orig)./(1-tauw_t)).^theta); % missing theta fixed 7/22 % Confirmed 2/9/16 goodnotes.
                pig_t=ptilde_c.*PW_t;
                
                % % E[h*e|Work] = term1(c)*term2(t)
                % % Use "term1" from *previous* loop ==> c==6, 1960 Young
                % term2=s_c^phi_t*(1./pig_t).^mu;  % mu:=1/theta*1/(1-eta)
                % AvgQuality=term1.*term2;                
                % AvgQuality(isinf(AvgQuality))=0; % For pig=0

                HAll_i(:,1+ymo)=HAllData(i,:,c,t).*PW_t./PW_estimate; % Adjust for new tauw % Error fixed 2/9/16!

            elseif c==7; % 1950 cohort ==> use previous term1 from 1960
                % For PworkYoung, Chang assumes *same* for all occs and equals LFP rate for young
                PW_estimate=sum(squeeze(pData(2:Noccs,:,6,t+1))); % t+1 means we compare M to M
                pig_data=squeeze(pData(i,:,c,t));
                ptilde_c=pig_data./PW_estimate;
                
                % Adjust participation for any change in tauw relative to data (e.g. for counterfactual)
                tauw_orig=TauW_Orig(i,:,t);
                %pwnum_pwden=(1./PW_estimate-1)./ptilde_c;
                %PW_t=1./(1+ptilde_c.*pwnum_pwden.*((1-tauw_orig)./(1-tauw_t)).^theta); % missing theta fixed 7/22
                PW_t=1./(1+(1./PW_estimate-1).*((1-tauw_orig)./(1-tauw_t)).^theta);  % Confirmed 2/9/16 goodnotes.
                pig_t=ptilde_c.*PW_t;
                
                % % E[h*e|Work] = term1(c)*term2(t)
                % % Use "term1" from *previous* loop ==> c==6, 1960 Young
                % term2=s_c^phi_t*(1./pig_t).^mu;  % mu:=1/theta*1/(1-eta)
                % AvgQuality=term1.*term2;                
                % AvgQuality(isinf(AvgQuality))=0; % For pig=0

                HAll_i(:,1+ymo)=HAllData(i,:,c,t).*PW_t./PW_estimate; % Adjust for new tauw % Error fixed 2/9/16!
                
            else; % No more special cases: c={6,5,4,3,2,1}
                
                % When young ==> cohort c
                phi_c=phi_C(i,c);  % NxC cohort version of phi 
                s_c=1/(1+(1-eta)/beta/phi_c);
                tauh_c=TauH(i,:,c);
                tauw_c=TauW_C(i,:,c); 
                z_c=Z(i,:,c);
                THOME=TgHome(1,:,c); % THOME is the value that varies over time; cohort based.
                thome_ct=THOME.*TgHome(i,:,c)*TigYMO(1,t-ymo,1+ymo); % TigYMO(1,:,:) contains the thome_shifter adjustment for home experience. % t-ymo = year born
                
                tau_c=(1+tauh_c).^eta./(1-tauw_c);
                w_c=w_C(i,c);   % w_C should be NxC = Nx8
                mgtilde_c=mgtilde_C(:,c)';

                % Exogenous experience 
                texp_c=squeeze(TExperience(i,:,c,t-ymo));
                texp_t=squeeze(TExperience(i,:,c,t));
                tbar_c=Tbar(i,:,t-ymo);
                % OLD: wtilde_c=texp_c.^(1/theta)*w_c*s_c^phi_c.*((1-s_c).*z_c).^((1-eta)/beta)./tau_c;                
                wtilde_c=tbar_c*w_c*s_c^phi_c.*((1-s_c).*z_c).^((1-eta)/beta)./tau_c;                
                mg_c=mgtilde_c.^(1/mu); %IMPORTANT: mgtilde := mg^(1/theta*1/(1-eta)), so mg=mgtilde^(1/mu)
                ptilde_c=wtilde_c.^theta ./ mg_c;

                pwnum=thome_ct*wH_t;
                pwden=texp_t.*(1-tauw_t)*wi;
                PW_t=1./(1+ptilde_c.*(pwnum./pwden).^theta);
                pig_t=ptilde_c.*PW_t;
                
                % E[h*e|Work] = term1(c)*term2(t)
                term1=gam*(eta*s_c^phi_c*tbar_c*w_c.*(1-tauw_c)./(1+tauh_c)).^(eta/(1-eta));
                term2=s_c^phi_t*(1./pig_t).^mu;  % mu:=1/theta*1/(1-eta)
                AvgQuality=term1.*term2;
                HAll_i(:,ymo+1)=(q(:,c,t)'.*pig_t.*texp_t.*AvgQuality)';
            end;
                
            % Hsupply
            pmodel_i(:,ymo+1)=pig_t'; % G x YMO
            Pwork_i(:,1+ymo)=PW_t; 
            Hsupply=Hsupply+sum(HAll_i(:,ymo+1));
            %Hsupply=Hsupply+sum(q(:,c,t)'.*pig_t.*texp_t.*AvgQuality);
            if ymo==0; 
                wtilde_i=wtilde_c;
                %Hyoung_i=Hsupply;
            end;
            
            if ~isreal(Hsupply*Hdemand);
                disp 'imaginary Hsupply or Hdemand. stopping in solveeqm function'
                keyboard
            end;
            %if StopHere==2;
            %    disp 'Stopping bc of StopHere...'; keyboard;
            %end;
            
        end; % sum over cohorts c
        resid=Hsupply-Hdemand;
        
        
    end; % Function e_HSupplyDemand
    
    % % Code for endogenous experience adjustment. Shutting off 1/20/16
    % function [resid,pig_t,texp_t,PW_t]=pt_and_texpt(PworkGuess,ptilde_c,pY,tigymo,lfpratioWM,texp_c,thome_ct,wH_t,tauw_t,wi,theta);
    %             WM=1;
    %             lfpY=pY./ptilde_c; % This is PworkYoung from earlier in time, since p=ptilde*Pwork
    %             lfp=PworkGuess;
    %             adjfactor=lfpY./lfp /lfpratioWM;
    %             adjfactor=min(adjfactor,1);
    %             %adjfactor=.5*(1+adjfactor); % Correct it up towards 1 -- better fit for eqm?
    %             texp_t=texp_c.*(1+(tigymo-1).*adjfactor);
                
    %             % PW and p
    %             pwnum=thome_ct*wH_t;
    %             pwden=texp_t.*(1-tauw_t)*wi;
    %             PW_t=1./(1+ptilde_c.*(pwnum./pwden).^theta);
    %             pig_t=ptilde_c.*PW_t;
    %             resid=PW_t-PworkGuess;
    %             if ~isreal(PW_t) | ~isreal(pig_t); disp 'Imaginary stuff in pt_and_texpt...'; keyboard; end;
    %         end; % function pt_and_texpt
     
    % Main function w=solveeqm(x,t)  -- nested functions require that main function have "end" 
end