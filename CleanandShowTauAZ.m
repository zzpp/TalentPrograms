% CleanandShowTauAZ  
%
% After running EstimateTauZ2.m to get the TauH, TauW, Z etc
% this program cleans the data up and shows/plots it.
%
% Also does the following:
%
%  - shows output w*H in each occupation and labor earnings (1-tauw)*w*H.
%  - computes GDP and growth rates
%  - computes revenue from TauW and TauH
%
% Also recovers the A(i,t) from the wages, Hit, and production function.
% Specifically, from the labor demand FOC from firms:
%
%    A(i,t) = [ w(i,t)^sigma H(i,t) / Y(t) ]^(1/(sigma-1))
%
% Creates the "TalentData" data set used in later programs.

clear; global CaseName;
diarychad('CleanandShowTauAZ',CaseName)

% Load data
load(['CohortData_' CaseName '.mat']);
load(['EstimateTauZ2Data_' CaseName '.mat']); % TauW TauH TauHat Z TgHome. All NxGxNcohorts except TauW is NxGxT
%HighQualityFigures=1
ShowParameters;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 0: Show Tau's, Z's, and TgHome by group
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fnamegraphs=['CleanandShowTauAZ_TauGraphs_' CaseName '.ps'];
if exist(fnamegraphs); delete(fnamegraphs); end;
tle='1960 1970 1980 1990 2000 2010';

% % Chang fix for checking tax revenues
% p(isnan(p))=0;
% TauW(isnan(TauW))=ValueforTauW_NaN;
% TauH(isnan(TauH))=ValueforTauH_NaN;
% Z(isnan(Z))=0;
% TgHome(isnan(TgHome))=0;
% WageBar(isnan(WageBar))=0;

% disp('Zeroing out missing Taus for revenue calculations...')

for g=1:Ngroups;

    disp ' '; disp ' '; 
    disp '--------------------------------------------------------------------------------------------------';
    disp(['                          >>>>> ' GroupNames{g} ' <<<<<'])
    disp '--------------------------------------------------------------------------------------------------';
  
    disp ' ';
    disp '--------------';
    disp '    TauHat      ';
    disp '--------------';
    tt=squeeze(tauhat(:,g,:));
    cshow(ShortNames,tt,'%8.3f',tle)
    disp ' ';
    cshow('Mean          ',meannan((tt)),'%8.3f','','nonee',1);
    cshow('Std Dev       ',nanstd((tt)),'%8.3f','','nonee',1);
    cshow('Mean(weighted)',nansum(earningsweights.*tt),'%8.3f','','nonee',1);
    cshow('Std Dev(wghtd)',stdw(tt,earningsweights,'omitnan'),'%8.3f','','nonee',1);


    disp ' ';
    disp '--------------';
    disp '    TauW      ';
    disp '--------------';
    TW=squeeze(TauW(:,g,:));
    cshow(ShortNames,TW,'%8.3f',tle)
    disp ' ';
    cshow('Mean          ',meannan((TW)),'%8.3f','','nonee',1);
    cshow('Std Dev       ',nanstd((TW)),'%8.3f','','nonee',1);
    cshow('Mean(weighted)',nansum(earningsweights.*TW),'%8.3f','','nonee',1);
    cshow('Std Dev(wghtd)',stdw(TW,earningsweights,'omitnan'),'%8.3f','','nonee',1);


    disp ' ';
    disp '--------------';
    disp '    TauH      ';
    disp '--------------';
    TH=squeeze(TauH(:,g,:));
    ctle=num2str((1940:10:2010),'%5.0f');
    TH_t=(flipud(TH'))';
    cshow(ShortNames,TH_t,'%8.3f',ctle)
    disp ' ';
    cshow('Mean          ',meannan((TH_t)),'%8.3f','','nonee',1);
    cshow('Std Dev       ',nanstd((TH_t)),'%8.3f','','nonee',1);
    cshow('Mean(weighted)',[NaN NaN nansum(earningsweights.*TH_t(:,3:8))],'%8.3f','','nonee',1);
    cshow('Std Dev(wghtd)',[NaN NaN stdw(TH_t(:,3:8),earningsweights,'omitnan')],'%8.3f','','nonee',1);
    
    disp ' ';
    disp '--------------------';
    disp '    1/(1-TauW)      ';
    disp '--------------------';
    cshow(ShortNames,1./(1-TW),'%8.3f',tle)
    disp ' ';
    cshow('Mean          ',meannan((1./(1-TW))),'%8.3f','','nonee',1);
    cshow('Std Dev       ',nanstd((1./(1-TW))),'%8.3f','','nonee',1);
    cshow('Mean(weighted)',nansum(earningsweights.*(1./(1-TW))),'%8.3f','','nonee',1);
    cshow('Std Dev(wghtd)',stdw(1./(1-TW),earningsweights,'omitnan'),'%8.3f','','nonee',1);
    
    eta
    
    disp ' ';
    disp '----------------------';
    disp '    (1+tauh)^eta      ';
    disp '----------------------';
    cshow(ShortNames,(1+TH_t).^eta,'%8.3f',ctle)
    disp ' ';
    cshow('Mean          ',meannan(((1+TH_t).^eta)),'%8.3f','','nonee',1);
    cshow('Std Dev       ',nanstd(((1+TH_t).^eta)),'%8.3f','','nonee',1);
    cshow('Mean(weighted)',[NaN NaN nansum(earningsweights.*(1+TH_t(:,3:8)).^eta)],'%8.3f','','nonee',1);
    cshow('Std Dev(wghtd)',[NaN NaN stdw((1+TH_t(:,3:8)).^eta,earningsweights,'omitnan')],'%8.3f','','nonee',1);
    
    disp ' ';
    disp '--------------------------------------------------';
    disp '    z -- preference shock by Cohort of birth      ';
    disp '--------------------------------------------------';
    ZZ=squeeze(Z(:,g,:));
    z_t=(flipud(ZZ'))';
    cshow(ShortNames,z_t,'%8.3f',ctle);
    disp ' ';
    cshow('Mean          ',meannan((z_t)),'%8.3f','','nonee',1);
    cshow('Std Dev       ',nanstd((z_t)),'%8.3f','','nonee',1);
    cshow('Mean(weighted)',[NaN NaN nansum(earningsweights.*z_t(:,3:8))],'%8.3f','','nonee',1);
    cshow('Std Dev(wghtd)',[NaN NaN stdw(z_t(:,3:8),earningsweights,'omitnan')],'%8.3f','','nonee',1);
    if nanmax(vector(z_t))==10; disp 'z=10 somewhere. stopping...'; keyboard; end;
    
    disp ' ';
    disp '--------------------------------------------------';
    disp '    TgHome -- Home Productivity by Cohort of birth';
    disp '--------------------------------------------------';
    TT=squeeze(TgHome(:,g,:));
    tghome_t=flipud(TT')'; % Put so 1940 cohort is first not last for plotting
    cshow(ShortNames,tghome_t,'%8.3f',ctle);
    disp ' ';
    cshow('Mean          ',meannan((tghome_t)),'%8.3f','','nonee',1);
    cshow('Std Dev       ',nanstd((tghome_t)),'%8.3f','','nonee',1);
    cshow('Mean(weighted)',[NaN NaN nansum(earningsweights.*tghome_t(:,3:8))],'%8.3f','','nonee',1);
    cshow('Std Dev(wghtd)',[NaN NaN stdw(tghome_t(:,3:8),earningsweights,'omitnan')],'%8.3f','','nonee',1);
   
    disp ' ';
    disp '--------------------------------------------------';
    disp '    TgHomeHat -- Home Productivity by Cohort of birth, relative to WM';
    disp '--------------------------------------------------';
    TT=squeeze(TgHome(:,g,:)./TgHome(:,WM,:));
    tghome_t=flipud(TT')'; % Put so 1940 cohort is first not last for plotting
    cshow(ShortNames,tghome_t,'%8.3f',ctle);
    disp ' ';
    cshow('Mean          ',meannan((tghome_t)),'%8.3f','','nonee',1);
    cshow('Std Dev       ',nanstd((tghome_t)),'%8.3f','','nonee',1);
    cshow('Mean(weighted)',[NaN NaN nansum(earningsweights.*tghome_t(:,3:8))],'%8.3f','','nonee',1);
    cshow('Std Dev(wghtd)',[NaN NaN stdw(tghome_t(:,3:8),earningsweights,'omitnan')],'%8.3f','','nonee',1);
   
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Show tauw, tauh and z by occupation
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    definecolors; LW=4;
    Occs=[8 11 12 16 23];
    yrs=(1960:10:2010)';
    chrts=(1940:10:2010)';
    for i=1:length(Occs);
        o=Occs(i);
        sfigure(1); figsetup;
        plot(yrs,(1./(1-TW(o,:))),'Color',myblue,'LineWidth',LW);
        plot(chrts,(1+TH_t(o,:)).^eta,'Color',mygreen,'LineWidth',LW);
        plot(chrts,z_t(o,:),'Color',myred,'LineWidth',LW);
        plot(chrts,tghome_t(o,:),'Color',mypurp,'LineWidth',LW);
        title([char(ShortNames(o)) ': ' char(GroupNames(g))]);
        legend('1/1-TauW','(1+TauH)^{eta}','z','TgHomeHat')
        print('-dpsc','-append',fnamegraphs);
    end;
end;





% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 1: Get Average Quality of workers
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AvgQuality_Estimate=AvgQuality;

% AvgQuality=zeros(Noccs,Ngroups,Ncohorts,Nyears);
% for g=1:Ngroups;
%     for c=1:Ncohorts;
%         % Note: This AvgQuality implicitly includes the Texperience term from our model...
%         % That is, it is Texp*E[he|work]
%         AvgQuality(:,g,c,:)=squeeze(WageBar(:,g,c,:))./squeeze((1-TauW(:,g,:)))./w;
%     end;
% end;
% AvgQuality(isnan(AvgQuality))=0; % Replace NaNs with zeros (bc TauW=1 when noone in Forest)
% AvgQuality(isinf(AvgQuality))=0; % Replace Infss with zeros (bc TauW=1 when noone in Forest)


% for i=2:Noccs;
%     for g=1:Ngroups;
%         if any(any(AvgQuality(i,g,:,:)~=AvgQuality_Estimate(i,g,:,:)));
%             disp([ShortNames{i} ' ' GroupNames{g}]);
%             squeeze(AvgQuality(i,g,:,:))
%             squeeze(AvgQuality_Estimate(i,g,:,:))
%         end;
%     end;
    
% end;


% Take a look at some of the AvgQuality results
Occs=[1 8 12 16 23];
clrs='kbrgkbrg';
syms='oxoxoxox';
fnamegraphs2=['CleanandShowTauAZ_AvgQuality_' CaseName '.ps'];
if exist(fnamegraphs2); delete(fnamegraphs2); end;

for i=1:length(Occs);
    for g=1:4; % Groups
        tle=['AvgQuality -- ' ShortNames{Occs(i)} ': ' GroupNames{g}];

        % Now plot all cohorts over time for iSec
        sfigure(1); figsetup; 
        for c=1:Ncohorts;
            % Find the years for a given cohort
            yrs=Decades(any(CohortConcordance'==c)); 
            [tf yy]=ismember(yrs,Decades);
            plot(yrs,squeeze(AvgQuality(Occs(i),g,c,yy)),cat(2,clrs(c),syms(c)),'LineWidth',LW);
            plot(yrs,squeeze(AvgQuality(Occs(i),g,c,yy)),cat(2,clrs(c),'-'),'LineWidth',LW);
        end;
        title(tle);
        chadfig2('Year','E[T*h*epsilon|work]',1,0);
        makefigwide;
        print('-dpsc','-append',fnamegraphs2);
    end;
end;

% Additional plots for quality *relative to* WM
for i=1:length(Occs);
    for g=2:4; % Groups
        tle=['AvgQuality rel to WM -- ' ShortNames{Occs(i)} ': ' GroupNames{g}];

        % Now plot all cohorts over time for iSec
        sfigure(1); figsetup; 
        for c=1:Ncohorts;
            % Find the years for a given cohort
            yrs=Decades(any(CohortConcordance'==c)); 
            [tf yy]=ismember(yrs,Decades);
            relqual=squeeze(AvgQuality(Occs(i),g,c,yy))./squeeze(AvgQuality(Occs(i),WM,c,yy));
            plot(yrs,relqual,cat(2,clrs(c),syms(c)),'LineWidth',LW);
            plot(yrs,relqual,cat(2,clrs(c),'-'),'LineWidth',LW);
        end;
        title(tle);
        %chadfig2('Year','E[T*h*epsilon|work]: Group g / WM',1,0);
        chadfig2('Year','Group g / WM',1,0);
        makefigwide;
        print('-dpsc','-append',fnamegraphs2);
    end;
end;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 2: Show H(i,t) (adding up across cohorts and groups)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp ' '; disp ' ';
disp 'H(i,t) --- Total human capital in each occupation';
tle='1960 1970 1980 1990 2000 2010';
cshow(OccupationNames,Hit,'%8.4f',tle);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3: Compute GDP and useful stuff...
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Labor Income
disp ' '; disp 'Labor income ignoring taxes: w(i,t)*H(i,t)';
LaborIncome=w.*Hit;
cshow(ShortNames,LaborIncome,'%8.0f',tle);
disp '---------------------------------------------------------------';
cshow('TOTAL         ',sum(LaborIncome),'%8.0f',[],[],'nonee');

disp ' '; disp 'Total labor income received by workers: (1-TauW)*w(i,t)*H(i,t)';
for g=1:Ngroups;
    LaborIncomeReceived(:,g,:)=squeeze(1-TauW(:,g,:)).*w.*squeeze(Higt(:,g,:));
end;
LaborIncomeReceived=squeeze(sum(LaborIncomeReceived,2));
cshow(ShortNames,LaborIncomeReceived,'%8.0f',tle);
disp '---------------------------------------------------------------';
cshow('TOTAL         ',nansum(LaborIncomeReceived),'%8.0f',[],[],'nonee');


% GDP 
Y=sum(w.*Hit);

cshow(' ',[Decades Y'],'%6.0f %8.0f','Year GDP');
GDP=Y';

disp ' ';
disp 'Average growth rates of GDP';
disp '---------------------------';
g=[log(Y(2:end)./Y(1:(end-1)))]'./(Decades(2:end)-Decades(1:(end-1)));
gAll=log(Y(end)/Y(1))/(2008-1960);
yr0=Decades; yr0(end)=1960; yrT=[Decades(2:end); 2008];
cshow(' ',[yr0 yrT [g; gAll]],'%6.0f %5.0f %9.4f');


% GDPYoung -- add up only young in each year ==> sum over groups (dimension 2)
for t=1:Nyears
    Hyoung(:,t)=sum(squeeze(H(:,:,7-t,t)),2);
end;
GDPYoung=sum(w.*Hyoung);
disp ' '; disp 'GDP of only Young Cohorts...';
cshow(' ',[Decades GDPYoung'],'%6.0f %8.0f','Year GDPYoung');

disp ' ';
disp 'Average growth rates of GDPYoung';
disp '---------------------------';
YY=GDPYoung;
g=[log(YY(2:end)./YY(1:(end-1)))]'./(Decades(2:end)-Decades(1:(end-1)));
gAll=log(YY(end)/YY(1))/(2008-1960);
yr0=Decades; yr0(end)=1960; yrT=[Decades(2:end); 2008];
cshow(' ',[yr0 yrT [g; gAll]],'%6.0f %5.0f %9.4f');

disp ' ';
disp 'HYoung(i,t) --- Total human capital in each occupation of Young Cohort';
tle='1960 1970 1980 1990 2000 2010';
cshow(OccupationNames,Hyoung,'%8.4f',tle);
HYoungData=Hyoung;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3.5: Compute Tax Revenues 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ABSOLUTE tax rates first
TauWabs=zeros(Noccs,Ngroups,Nyears)*NaN;
TauHabs=zeros(Noccs,Ngroups,Ncohorts)*NaN;
tauwWM=squeeze(TauW(2,1,:)); % common across occs
tauhWM=squeeze(TauH(2,1,:));

for t=1:Nyears;
    c=7-t; % Cohort
    TauWabs(:,:,t) = 1 - (1-TauW(:,:,t))*(1-tauwWM(t)); 
    %  (1+TauH(:,:,t))^eta = (1+TauHabs_t)^eta /(1+tauhWM)^eta 
    TauHabs(:,:,c) = (1+TauH(:,:,c)) * (1+tauhWM(c)) - 1;
end;

% REVENUE from the wage tax
RevenueTauW_G=zeros(Noccs,Ngroups,Nyears); % for each group
RevenueTauW=zeros(Noccs,Nyears);
for g=1:Ngroups;
    RevenueTauW_G(:,g,:)=squeeze(TauWabs(:,g,:).*Higt(:,g,:)).*w;
    RevenueTauW=RevenueTauW+squeeze(RevenueTauW_G(:,g,:));
end;
disp ' '; disp 'Tax Revenue from TauWabs by occupation and year, summed over groups'; disp ' ';
cshow(OccupationNames,RevenueTauW,'%8.0f');
disp '-----------------------------------------------------------------------------------------';
cshow('Total Revenue TauW                        ',nansum(RevenueTauW),'%8.0f');
cshow('TauW  Revenue Share of GDP                ',nansum(RevenueTauW)./GDP','%8.4f');

%if any(abs(nansum(RevenueTauW))>0.1); disp ' '; disp '********************************'; disp 'Tax Revenue (tauw) not zero!'; disp '*******************************'; disp ' '; end;


% REVENUE from tauh -- only the young cohort pays this tax
% %%% ALTERNATIVE 
disp ' '; disp ' ';
disp 'This is an alternative way of adding up TauH revenue that should give the same answer...';
disp 'Updated for Lifetime Income LI done.';
WageBarYoung=zeros(Noccs,Ngroups,Nyears);
TYoung=zeros(Noccs,Ngroups,Nyears);
pYoung=zeros(Noccs,Ngroups,Nyears);
qYoung=zeros(Ngroups,Nyears);
for t=1:Nyears;
    cYoung=CohortConcordance(t,2);
    WageBarYoung(:,:,t)=squeeze(WageBar(:,:,cYoung,t));
    TYoung(:,:,t)=squeeze(TExperience(:,:,cYoung,t));
    pYoung(:,:,t)=squeeze(p(:,:,cYoung,t));
    qYoung(:,t)=squeeze(q(:,cYoung,t));
end;
YoungCohorts=CohortConcordance(:,2); % [6 5 4 3 2 1]
RevenueTauH=zeros(Noccs,Nyears);
for g=1:Ngroups; % LI correction: multiply by Tbar/T
    tauh=squeeze(TauHabs(:,g,YoungCohorts));
    gRevenue=eta*tauh./(1+tauh).*squeeze(pYoung(:,g,:).*WageBarYoung(:,g,:)./TYoung(:,g,:));
    RevenueTauH=RevenueTauH+mult(gRevenue.*squeeze(Tbar(:,g,:)),qYoung(g,:));
end;
disp ' '; disp 'Tax Revenue from TauHabs by occupation and year, summed over groups'; disp ' ';
cshow(OccupationNames,RevenueTauH,'%8.0f');
disp '-----------------------------------------------------------------------------------------';
cshow('Total Revenue TauH                          ',nansum(RevenueTauH),'%8.0f');
cshow('TauH  Revenue Share of GDP                ',nansum(RevenueTauH)./GDP','%8.4f');

%if any(abs(nansum(RevenueTauH))>.1); disp ' '; disp '*******************************'; disp 'Tax Revenue (tauh) not zero!'; disp '*******************************'; disp ' '; end;


% REVENUE from tauh -- only the young cohort pays this tax
%   Revenue = sum(i,g) eta*tauh(c)/(1+tauh(c))*(1-tauw(c))*wi(c)*Hig(c,c)
Hyoung=zeros(Noccs,Ngroups,Nyears);
for t=1:Nyears;
    cYoung=CohortConcordance(t,2);
    Hyoung(:,:,t)=squeeze(H(:,:,cYoung,t));
end;
YoungCohorts=CohortConcordance(:,2); % [6 5 4 3 2 1]
RevenueTauH_G=zeros(Noccs,Ngroups,Nyears); % for each group
RevenueTauH=zeros(Noccs,Nyears);
for g=1:Ngroups;
    tauh=squeeze(TauHabs(:,g,YoungCohorts));
    RevenueTauH_G(:,g,:)=eta*tauh./(1+tauh).*(1-squeeze(TauWabs(:,g,:))).*w.*squeeze(Hyoung(:,g,:)./TYoung(:,g,:));
    RevenueTauH=RevenueTauH+squeeze(RevenueTauH_G(:,g,:).*Tbar(:,g,:));
end;
disp ' '; disp 'Tax Revenue from TauHabs by occupation and year, summed over groups'; disp ' ';
cshow(OccupationNames,RevenueTauH,'%8.0f');
disp '-----------------------------------------------------------------------------------------';
cshow('Total Revenue TauH                        ',nansum(RevenueTauH),'%8.0f');
cshow('TauH  Revenue Share of GDP                ',nansum(RevenueTauH)./GDP','%8.4f');

%if any(abs(nansum(RevenueTauH))>.1); disp ' '; disp '*******************************'; disp 'Tax Revenue (tauh) not zero!'; disp '*******************************'; disp ' '; end;

disp ' ';
RevenueTotal=nansum(RevenueTauW+RevenueTauH);
cshow('Total Revenue TauW+TauH                   ',RevenueTotal,'%8.0f');
cshow('Total Revenue Share of GDP                ',RevenueTotal./GDP','%8.4f');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 4: Get A(i,t) from basic formula
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num=w.^sigma.*Hit;
A=(div(num,Y)).^(1/(sigma-1));
A(1,:)=0; % Home sector -- to avoid infinity when rho<0
disp ' '; disp ' ';
disp 'A(i,t) -- Productivity in each occupation';
tle='1960 1970 1980 1990 2000 2010';
cshow(OccupationNames,A,'%8.0f',tle);

% Compare to GDP:=sum(w.*Hit) computed earlier
rho=1-1/sigma
YY=sum((A.*Hit).^rho).^(1/rho);
if any(abs(YY-GDP'))>1; disp 'Total labor income and GDP are different??? Stopping...'; keyboard; end;





% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 5: Labor Supply Elasticities
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp ' ';
disp '---------------------------------------------------------';
disp 'The extensive margin LS elasticity in our model equals'
disp ' ';
disp '      theta*(1-LFP)/LFP = theta*p(Home)/(1-p(Home))';
disp ' ';
disp '---------------------------------------------------------';
pHome=squeeze(p(1,:,:,:));
fprintf('Benchmark value for theta = %6.4f, so that theta*(1-eta) = %6.4f\n',[theta theta*(1-eta)]);
ElasticityofLS=theta*pHome./(1-pHome);
for g=1:Ngroups;
    for t=1:Nyears;
        c=7-t;
        ElasticityofLSymo(g,t,:)=squeeze(ElasticityofLS(g,[c c+1 c+2],t));
    end;
    disp ' ';
    disp(sprintf(['Labor supply elasticities for ' GroupNames{g} ' by Year and Cohort']));
    cshow(' ',[Decades squeeze(ElasticityofLSymo(g,:,:))],'%6.0f %8.2f','Year Young Middle Old');
end;




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 6: Plot mean and var of tauh, tauw, Z
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
definecolors
meannames={'MeanTauZ_WM','MeanTauZ_WW','MeanTauZ_BM','MeanTauZ_BW'};
varnames={'VarTauZ_WM','VarTauZ_WW','VarTauZ_BM','VarTauZ_BW'};

for t=1:Nyears;
  meantauw(t,:)=nansum(mult(1./(1-TauW(:,:,t)),earningsweights(:,t)));
  meanlogtauw(t,:)=nansum(mult(log(1./(1-TauW(:,:,t))),earningsweights(:,t)));
  diff=chadminus(log(1./(1-TauW(:,:,t))),meanlogtauw(t,:));
  varlogtauw(t,:)=nansum(mult(diff.^2,earningsweights(:,t)));

  ct=7-t;
  TH=(1+TauH(:,:,ct)).^eta;
  meantauh(t,:)=nansum(mult(TH,earningsweights(:,t)));
  meanlogtauh(t,:)=nansum(mult(log(TH),earningsweights(:,t)));
  diff=chadminus(log(TH),meanlogtauh(t,:));
  varlogtauh(t,:)=nansum(mult(diff.^2,earningsweights(:,t)));

  zz=Z(:,:,ct);
  meanz(t,:)=nansum(mult(zz,earningsweights(:,t)));
  meanlogz(t,:)=nansum(mult(log(zz),earningsweights(:,t)));
  diff=chadminus(log(zz),meanlogz(t,:));
  varlogz(t,:)=nansum(mult(diff.^2,earningsweights(:,t)));
end;


for g=2:Ngroups;

sfigure(1); figsetup;
%plot(Decades,meantau(:,1),'b-'); hold on;
plot(Decades,meantauw(:,g),'Color',myblue,'LineWidth',LW); hold on;
plot(Decades,meantauh(:,g),'Color',mygreen,'LineWidth',LW);
plot(Decades,meanz(:,g),'Color',mypurp,'LineWidth',LW);
vals=(1960:10:2010)';
relabelaxis(vals, num2str(vals),'x');
chadfig2('Year','Mean (weighted) across occupations',1,0);
if WideFigures; makefigwide; end;
if HighQualityFigures;
  text(1961.2,1.5,'1/(1-\tau_w)'); %,'Color',myblue);
  text(1968,1.5,'(1+\tau_h)^\eta'); %,'Color',mygreen);
  text(1970,1.05,'Z'); %,'Color',mypurp);
  wait;
end;
print('-dpng',[meannames{g} '_' CaseName]);
title(GroupNames{g});
print('-dpsc','-append',fnamegraphs);


sfigure(2); figsetup;
%plot(Decades,meantau(:,1),'b-'); hold on;
plot(Decades,varlogtauw(:,g),'Color',myblue,'LineWidth',LW); hold on;
plot(Decades,varlogtauh(:,g),'Color',mygreen,'LineWidth',LW);
plot(Decades,varlogz(:,g),'Color',mypurp,'LineWidth',LW);
vals=(1960:10:2010)';
relabelaxis(vals, num2str(vals),'x');
chadfig2('Year','Variance (weighted) of log',1,0);
if WideFigures; makefigwide; end;
if HighQualityFigures;
  text(1980,.04,'1/(1-\tau_w)'); %,'Color',myblue);
  text(1975,.04,'(1+\tau_h)^\eta'); %,'Color',mygreen);
  text(1975,.02,'Z'); %,'Color',mypurp);
  wait;
end;
print('-dpng',[varnames{g} '_' CaseName]);
title(GroupNames{g});
print('-dpsc','-append',fnamegraphs);


end % Loop over groups for mean/variance graphs


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LFP and GDP per worker in the data
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ywkr = GDP per worker = Y / LFP
%   LFP  = Aggregate LFP rate = Fraction of total population that is working


LFPData=zeros(Nyears,1);
for t=1:Nyears;
    % First, we add up across YMO
    Pwork_gc=squeeze(sum(p(2:Noccs,:,:,t)));  % Ngroups x Ncohorts
    Pwork_g=zeros(Ngroups,1);
    NumPeople_g=zeros(Ngroups,1);
    c=7-t;
    for ymo=0:2;
        Pwork_g    =Pwork_g+Pwork_gc(:,c+ymo).*q(:,c+ymo,t);
        NumPeople_g=NumPeople_g+q(:,c+ymo,t);
    end;
    LFPData(t)=sum(Pwork_g);
end;
GDPwkr=GDP./LFPData; % GDP per worker = GDP per person * Persons/Wkrs

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WAGE GAP and Consumption (mkt)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WageGapData (Ngroups x Nyears) = WageBar(g)/WageBar(WM) net of taxes
%   Average across occupations
%   HModelAllt (Noccs x Ngroups x YMO) but HModelAllt already includes q
%     HAll_i(:,ymo+1)=(q(:,c,t)'.*pig_t.*texp_t.*AvgQuality)';
%   q (Ngroups x Ncohorts x Nyears)
%   pmodelt (Noccs x Ngroups x YMO)  
%
% Market Consumption: Updated 6/9/16. See Chad-TalentNotes.pdf (page 2c)
%     c* = 1/3*(1-eta)*LifetimeIncome = cYoung
%     e*(1+tauh) = eta*LifetimeIncome

ConsumpYoungData=zeros(Nyears,1);
EduGrossofTax=zeros(Nyears,1);
EduNetofTax=zeros(Nyears,1);
EarningsData=zeros(Nyears,1);
for t=1:Nyears;
    c=7-t; co=c+2;
    TotalEarnings_ig = mult(squeeze(1-TauW(:,:,t)).*sum(HAllData(:,:,c:co,t),3),w(:,t));  % Noccs x Ngroups
    EarningsYoung_ig = mult(squeeze(1-TauW(:,:,t)).*HAllData(:,:,c,t),w(:,t));  % Noccs x Ngroups
    EarningsMiddle_ig= mult(squeeze(1-TauW(:,:,t)).*HAllData(:,:,c+1,t),w(:,t));  % Noccs x Ngroups
    EarningsOld_ig   = mult(squeeze(1-TauW(:,:,t)).*HAllData(:,:,c+2,t),w(:,t));  % Noccs x Ngroups
    
    LIYoung_ig=Tbar(:,:,t)./TExperience(:,:,c,t).*EarningsYoung_ig; % Noccs x Ngroups
    cY_ig=1/3*(1-eta)*LIYoung_ig;
    NumYoungt=sum(q(:,7-t,t));
    ConsumpYoungData(t)=sum(sum(cY_ig))/NumYoungt;  % Per young person
    EduGrossofTax(t)=eta*sum(sum(LIYoung_ig));
    EduNetofTax(t)  =eta*sum(sum(LIYoung_ig./(1+TauH(:,:,c)))); % Recall TauH is cohort-based!
    
    %EduRepayment_ig  = (1-1/3*(1-eta)*Tbar(:,:,t)./TExperience(:,:,c,t)).*EarningsYoung_ig; % Noccs x Ngroups
    %cY=EarningsYoung_ig -(1+TauH(:,:,t)).*EduRepayment_ig;
    %cM=EarningsMiddle_ig-(1+TauH(:,:,t)).*EduRepayment_ig;
    %cO=EarningsOld_ig   -(1+TauH(:,:,t)).*EduRepayment_ig;
    %ConsumptionMktData(t) = nansum(nansum(cY+cM+cO));

    lfp_gc=squeeze(sum(p(2:Noccs,:,c:co,t)));
    NumWorkers_g = sum(q(:,c:co,t).*lfp_gc,2)';  % 1xG
    WageBar_g  = sum(TotalEarnings_ig)./NumWorkers_g; %1xG
    WageGapData(:,t)=WageBar_g/WageBar_g(1);
    EarningsData(t)=sum(sum(TotalEarnings_ig));
end;
disp ' ';
disp 'Wage Gaps';
cshow(' ',[Decades WageGapData'],'%6.0f %9.3f','Year WM WW BM BW');

disp ' ';
disp 'GDP per person, per worker, Aggregate LFP, Earnings per person, Consumption per person (mkt)';
disp '   and Education Spending share of GDP';
EduShareData=EduGrossofTax./GDP - nansum(RevenueTauH)'./GDP;
cshow(' ',[Decades GDP GDPwkr LFPData EarningsData ConsumpYoungData EduShareData],'%6.0f %11.0f %11.0f %11.3f %11.0f %11.0f %11.3f','Year GDP GDPwkr LFP Earnings ConsYoung EduShare');

disp 'NOTE: This only includes the education spending from the market sector participants,';
disp '      not from the people who stay at home.';
Edu2 = EduNetofTax./GDP
disp ' ';


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPLIT of tauhat into TauW and TauH (young)
%   - For comparison with our 1960 assumption
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AlphaSplitYoung=-log(1-TauW)./log(tauhat_y);  % Noccs x Ngroups x Nyears
disp ' ';
disp 'AlphaSplitYoung for WW:';
cshow(ShortNames,squeeze(AlphaSplitYoung(:,2,:)),'%8.3f','1960 1970 1980 1990 2000 2010');
for g=2:Ngroups;
    meansplit(g,:)=squeeze(nansum(mult(squeeze(AlphaSplitYoung(:,g,:)),earningsweights_avg)));
    stdsplit(g,:) =squeeze(std(squeeze(AlphaSplitYoung(:,g,:)),earningsweights_avg,'omitnan'));
end;
nonWMweights=earningsweights_g./sum(earningsweights_g(2:Ngroups));
nonWMweights(WM)=NaN;
meansplit_avg=sum(mult(meansplit(2:Ngroups,:),nonWMweights(2:Ngroups)));
stdsplit_avg=sum(mult(stdsplit(2:Ngroups,:),nonWMweights(2:Ngroups)));
disp ' ';
disp '============================================';
disp 'SPLIT of tauhat into TauW and TauH (young), earnings weighted'
disp ' - For comparison with our 1960 assumption'
disp '============================================';
cshow(GroupNames,meansplit,'%10.3f','1960 1970 1980 1990 2000 2010')
disp '-----------------------------------------------------------------------';
cshow('///Mean/// ',meansplit_avg,'%10.3f',[],[],1);
fprintf('  And the mean for all years is %10.3f\n',mean(meansplit_avg));;
fprintf('The mean for yearsafter 1960 is %10.3f\n',mean(meansplit_avg(2:end)));

cshow(GroupNames,stdsplit,'%10.3f','1960 1970 1980 1990 2000 2010')
disp '-----------------------------------------------------------------------';
cshow('/// Std/// ',stdsplit_avg,'%10.3f',[],[],1);
fprintf('  And the std for all years is %10.3f\n',mean(stdsplit_avg));;
fprintf('The std for yearsafter 1960 is %10.3f\n',mean(stdsplit_avg(2:end)));


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 7: Clean up and save
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now, clean up data for going forward.
% In particular, reload and fix the missing Tau's to 0.99 etc....


HAllData=H;
save(['CleanandShowTauAZ_' CaseName],'A','GDP','GDPwkr','LFPData','WageGapData','ConsumpYoungData','AlphaSplitYoung','GDPYoung','LaborIncomeReceived','H','HAllData','Higt','Hit','HYoungData');

% Load data
clear; global CaseName;
load(['CohortData_' CaseName '.mat']);
clear DecadeNames;
%load wphis_final  % Chang's estimate of w and phi (and s) -- all NxT matrices. %% Unnecessary -- saved in EstimateTauZ2Data_casename
load(['EstimateTauZ2Data_' CaseName '.mat']); % TauW TauH TauHat Z TgHome. All NxGxNcohorts except TauW is NxGxT
load(['CleanandShowTauAZ_' CaseName '.mat']);



% Set up the following variables that are useful in solving later
TauW_Orig=TauW;
TauW_C=zeros(Noccs,Ngroups,Ncohorts);
for g=1:Ngroups;
    TauW_C(:,g,1:6)=flipud(squeeze(TauW(:,g,:))')';
end;
phi_C=zeros(Noccs,Ncohorts)*NaN;
phi_C(:,1:6)=flipud(phi')'; % For cohorts

pData=p;
wData=w;
wH_T=wData(1,:);   % This is a technology parameter, not an equilibrium object
HData=Hit;

% Incorporate thome_shifter into TigYMO(1,:) home entry so that solveeqm.m can see it!
TigYMO(1,:,:)=Thome_shifter;


save(['TalentData_' CaseName '.mat']);

diary off;



