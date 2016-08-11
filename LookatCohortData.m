% LookatCohortData.m
%
%   Feb 2014: 1st try
%   Jan 2015: Change wage gap so it is *occupation*-specific as well
%             (since we now have "z" preference shocks).
%
% After running ReadCohortData
%  Makes some plots to check that things look okay

% 1990 bw cohort 5 architects missing, whereas small #s in 1970 and 1980!

lname='LookatCohortData';
pname1=[lname '1_' CaseName '.ps'];
pname2=[lname '2_' CaseName '.ps'];
pname3=[lname '3_' CaseName '.ps'];
if exist(pname1); delete(pname1); end;
if exist(pname2); delete(pname2); end;
if exist(pname3); delete(pname3); end;

Occs=[1 8 12 16 23];

% CohortConcordance: c=CohortConcordance(1,2) returns Young in Year1 = cohort 6
CohortConcordance=flipud([
2010 1 2 3
2000 2 3 4
1990 3 4 5
1980 4 5 6 
1970 5 6 7 
1960 6 7 8
]);

% YearConcordance: yr=YearConcordance(6,2) 
%    returns Year in which Cohort 6 is young = Year 1 (1960)
YearConcordance=[
2010 6 % 1 
2000 5 % 2 
1990 4 % 3 
1980 3 % 4  
1970 2 % 5  
1960 1 % 6 
];

clrs='kbrgkbrg';
syms='oxoxoxox';

definecolors;
clrs2=[myred; myblue; mygreen; mypurp; myred; myblue; mygreen; mypurp];

% Aggregate Earnings (for weighting)
AggIncomeData=NumPeople.*Earnings;
AggIncomeData_igt=squeeze(nansum(AggIncomeData,3));
AggIncomeData_it=squeeze(nansum(AggIncomeData_igt,2));
earningsweights=div(AggIncomeData_it,nansum(AggIncomeData_it,1));
earningsweights_avg=mean(earningsweights')';
AggIncomeData_gt=squeeze(nansum(AggIncomeData_igt,1));
earningsweights_gt=div(AggIncomeData_gt,nansum(AggIncomeData_gt,1));
earningsweights_g=mean(earningsweights_gt')';

AggIncomeDataYoung=zeros(Nyears,1);
NumYoung=zeros(Nyears,1);
NumPeoplet=squeeze(nansum(nansum(nansum(NumPeople,3))));
for t=1:Nyears;
    AggIncomeDataYoung(t)=nansum(nansum(AggIncomeData(:,:,7-t,t)));
    NumYoung(t)=nansum(nansum(NumPeople(:,:,7-t,t)));
end;
disp 'Earnings of Young: Per total population and Per person';
cshow(' ',[Decades AggIncomeDataYoung./NumPeoplet AggIncomeDataYoung./NumYoung NumYoung./NumPeoplet*100],'%8.0f %12.0f %12.0f %12.1f','Year PerTotalPop PerYoung Young/Pop');

for i=1:length(Occs);
    for g=1:4; % Groups
        tle=[ShortNames{Occs(i)} ': ' GroupNames{g}];

        % Now plot all cohorts over time for iSec
        sfigure(1); figsetup; hold on;
        for c=1:8;
            % Find the years for a given cohort
            yrs=Decades(any(CohortConcordance'==c)); 
            [tf yy]=ismember(yrs,Decades);
            plot(yrs,squeeze(p(Occs(i),g,c,yy)),syms(c),'Color',clrs2(g,:)); %,cat(2,clrs(c),syms(c)));
            plot(yrs,squeeze(p(Occs(i),g,c,yy)),cat(2,clrs(c),'-'));
        end;
        title(tle);
        chadfig2('Year','p(.)',1,0);
        makefigwide;
        print('-dpsc','-append',pname1);
    end;
end;


% Relative propensity
relp=zeros(size(p));
for g=1:Ngroups;
    relp(:,g,:,:)=p(:,g,:,:)./p(:,1,:,:);
end;



for i=1:length(Occs);
    for g=1:4; % Groups
        tle=[ShortNames{Occs(i)} ': ' GroupNames{g}];

        % Now plot all cohorts over time for iSec
        sfigure(1); figsetup; hold on;
        for c=1:8;
            % Find the years for a given cohort
            yrs=Decades(any(CohortConcordance'==c)); 
            [tf yy]=ismember(yrs,Decades);
            plot(yrs,squeeze(relp(Occs(i),g,c,yy)),cat(2,clrs(c),syms(c)));
            plot(yrs,squeeze(relp(Occs(i),g,c,yy)),cat(2,clrs(c),'-'));
        end;
        chadfig2('Year','Rel. propensity, p(.)/p(wm)',1,0);
        makefigwide;
        title(tle);
        print('-dpsc','-append',pname2);
    end;
end;


% Wage Gap
%   Graph of earnings-weighted average for each group

wagegap=zeros(size(p));
for g=1:Ngroups;
    %    wagegap(:,g,:,:)=Wage(:,g,:,:)./Wage(:,WM,:,:);
    wagegap(:,g,:,:)=Earnings(:,g,:,:)./Earnings(:,WM,:,:);
    for c=1:Ncohorts;
        wagegap_gct(g,c,:)=nansum(mult(squeeze(wagegap(:,g,c,:)),earningsweights_avg));
    end;
end;


% Graph
GroupCodes={'WM','WW','BM','BW'};
for g=2:4; % Groups
    tle=GroupNames{g};

    % Now plot all cohorts over time
    sfigure(1); figsetup; hold on;
    for c=1:8;
        % Find the years for a given cohort
        yrs=Decades(any(CohortConcordance'==c)); 
        [tf yy]=ismember(yrs,Decades);

        plot(yrs,log(squeeze(wagegap_gct(g,c,yy))),syms(c),'Color',clrs2(c,:)); %,cat(2,clrs(c),syms(c)));
        plot(yrs,log(squeeze(wagegap_gct(g,c,yy))),'-','Color',clrs2(c,:)); 
    end;
    %ax=axis; ax(4)=0; axis(ax);
    if g==2;
        vals=(-1:.2:0)';
        relabelaxis(vals, num2str(vals));
    end;
    vals=(1960:10:2010)';
    relabelaxis(vals, num2str(vals),'x');
    chadfig2('Year','Log Wage Gap',1,0);
    makefigwide;
    title(tle,'FontName','Helvetica','FontSize',14);
    print('-dpng',['WageGap' GroupCodes{g}]);
end;

WageBar=Earnings;
Wage_controls=Wage;
WageNominal_controls=WageNominal;
clear Wage WageNominal % To avoid confusion; Wage_control is a regression residual


% tauhat -- wage gap by Occupation/group/cohort/year...
%   
%   relp = tauhat^(-theta) * [wage(g)/wage(wm)]^(-theta(1-eta))
%
%   tauhat = relp^(-1/theta) * [wage(g)/wage(wm)]^(-(1-eta))



% tauhat=zeros(size(p));
% for i=1:Noccs;
%     tauhat(i,:,:,:)=squeeze(relp(i,:,:,:)).^(-1/theta) .* wagegap.^(-(1-eta));
% end;

disp ' '; disp ' ';
disp 'Note Well: These tauhat plots ignore the Tbar ratio...';
tauhat=relp.^(-1/theta) .* wagegap.^(-(1-eta));

for i=1:length(Occs);
    for g=1:4; % Groups
        tle=[ShortNames{Occs(i)} ': ' GroupNames{g}];

        % Now plot all cohorts over time for iSec
        sfigure(1); figsetup; hold on;
        for c=1:8;
            % Find the years for a given cohort
            yrs=Decades(any(CohortConcordance'==c)); 
            [tf yy]=ismember(yrs,Decades);
            plot(yrs,squeeze(tauhat(Occs(i),g,c,yy)),cat(2,clrs(c),syms(c)));
            plot(yrs,squeeze(tauhat(Occs(i),g,c,yy)),cat(2,clrs(c),'-'));
        end;
        title(tle);
        chadfig2('Year','tauhat',1,0);
        makefigwide;
        print('-dpsc','-append',pname3);
    end;
end;

% Finally, create key graphs for the paper: key occupations, young tauhat for WW and BM
% First, extract the young tauhat
onames={'CompositeTauOccWM','CompositeTauOccWW','CompositeTauOccBM','CompositeTauOccBW'};
if ~exist('WideFigures'); WideFigures=1; end;
if ~exist('HighQualityFigures'); HighQualityFigures=0; end;
for t=1:Nyears;
    ct=7-t;
    tauhat_y(:,:,t)=squeeze(tauhat(:,:,ct,t));
end;


% Copying code from EstimateTauZ2 to fix missing tauhat_y for use in NoBrawny case
% (where we use tauhat_y to infer T(i,g) to eliminate frictions)

    % Fix missing values in a systematic way
    disp ' '; disp '===========================================================';
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




occExe=1+1;
occDoc=7+1;
occTea=11+1;
occLaw=15+1;
occSal=21+1;
occSec=22+1;
occFoo=36+1;
occCst=47+1;
myoccs=[occDoc occLaw occSec occCst occTea];
definecolors


% Doctors Lawyer Home Secretaries
%ytle='{\bf Barrier measure, $$\hat\tau$$}';
%ytle='Composite barrier, \tau';
ytle='Composite barrier';
for g=2:Ngroups;
  sfigure(g); figsetup;
  plot(Decades,vector(tauhat_y(occDoc,g,:)),'Color',myblue); %
  plot(Decades,vector(tauhat_y(occLaw,g,:)),'Color',mygreen); %
  plot(Decades,vector(tauhat_y(occSec,g,:)),'Color',mypurp); %
  plot(Decades,vector(tauhat_y(occCst,g,:)),'Color',myorng); %
  plot(Decades,vector(tauhat_y(occTea,g,:)),'Color',myred); %

  disp(GroupNames{g})
  cshow(ShortNames(myoccs),squeeze(tauhat_y(myoccs,g,:)),'%8.3f','1960 1970 1980 1990 2000 2010');

  %  if g==2; 
  %  set(gca,'YTick',[0 1 2 3 4 5]);
  %  set(gca,'YTickLabel',strmat('0 1 2 3 4 5'));
  %end;
  vals=(1960:10:2010)';
  relabelaxis(vals, num2str(vals),'x');
  chadfig2('Year',ytle,1,0);
  if WideFigures; makefigwide; end;
%  title(tle{g});
  if HighQualityFigures; 
    putstr('Doctors'); %,myblue);
    putstr('Lawyers'); %,mygreen);
    putstr('Secretaries'); %,mypurp);
    putstr('Construction'); %,myorng);
    putstr('Teachers'); %,myred);
    wait; 
  end;  % For adjusting years...
  print('-dpng',[onames{g} '_' CaseName]);
end;




    
    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot mean and var of composite tau
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
definecolors
meannames='MeanTauHat';
varnames='VarTauHat';
relpnames='StdlnRelP';
gapnames='StdWageGap';
Mkt=2:Noccs;


for t=1:Nyears;
  meantau(t,:)=nansum(mult(tauhat_y_cleaned(:,:,t),earningsweights_avg));
  meanlogtau(t,:)=nansum(mult(log(tauhat_y_cleaned(:,:,t)),earningsweights_avg));
  diff=chadminus(log(tauhat_y_cleaned(:,:,t)),meanlogtau(t,:));
  varlogtau(t,:)=nansum(mult(diff.^2,earningsweights_avg));
  
  % std of log(relp)
  lnrelp_young(:,:,t)=log(relp(:,:,7-t,t));
  lnrelp_young(isinf(lnrelp_young))=NaN;
  lnrelp_young(isnan(lnrelp_young))=log(0.001); %min(nanmin(lnrelp_young(:,:,t)));
  meanrelp=nansum(mult(lnrelp_young(:,:,t),earningsweights_avg));
  diff=chadminus(lnrelp_young(:,:,t),meanrelp);
  std_relp_young(t,:)=sqrt(nansum(mult(diff.^2,earningsweights_avg)));  
  
  % std of gap := log(wage ratio)
  wage_young(:,:,t)=Earnings(:,:,7-t,t);
  gap(:,:,t)=log(div(wage_young(:,:,t),wage_young(:,WM,t)));
  gap(isinf(gap))=NaN;
  missinggap=isnan(gap(:,:,t)); missinggap(1,:)=0;
  meangap=nansum(mult(gap(:,:,t),earningsweights_avg));
  gap(missinggap(:,WW),WW,t)=meangap(:,WW); %nanmean(gap(~missinggap(:,WW),WW,t));
  gap(missinggap(:,BM),BM,t)=meangap(:,BM); %nanmean(gap(~missinggap(:,BM),BM,t));
  gap(missinggap(:,BW),BW,t)=meangap(:,BW); %nanmean(gap(~missinggap(:,BW),BW,t));
  diff=chadminus(gap(:,:,t),meangap);
  std_wagegap(t,:)=sqrt(nansum(mult(diff.^2,earningsweights_avg)));
end;


sfigure(1); figsetup;
%plot(Decades,meantau(:,1),'b-'); hold on;
plot(Decades,meantau(:,WW),'Color',myblue); hold on;
plot(Decades,meantau(:,BM),'Color',mygreen);
plot(Decades,meantau(:,BW),'Color',mypurp);
vals=(1960:10:2010)';
relabelaxis(vals, num2str(vals),'x');
chadfig2('Year','Mean (weighted) across occupations',1,0);
if WideFigures; makefigwide; end;
if 1; %HighQualityFigures;
  text(1964.5,4.0,'White women'); %,'Color',myblue);
  text(1971,2.1,'Black men'); %,'Color',mygreen);
  text(1972,5.5,'Black women'); %,'Color',mypurp);
end;
print('-dpng',[meannames '_' CaseName]);
title('Mean of Composite TauHat');
print('-dpsc','-append',pname3);


sfigure(2); figsetup;
%plot(Decades,meantau(:,1),'b-'); hold on;
plot(Decades,varlogtau(:,WW),'Color',myblue); hold on;
plot(Decades,varlogtau(:,BM),'Color',mygreen);
plot(Decades,varlogtau(:,BW),'Color',mypurp);
vals=(1960:10:2010)';
relabelaxis(vals, num2str(vals),'x');
chadfig2('Year','Variance (weighted) of log',1,0);
if WideFigures; makefigwide; end;
if 1; % HighQualityFigures;
  text(1976,.55,'White women'); %,'Color',myblue);
  text(1978,.17,'Black men'); %,'Color',mygreen);
  text(1985,.70,'Black women'); %,'Color',mypurp);
end;
print('-dpng',[varnames '_' CaseName]);
title('Variance of log tauhat');
print('-dpsc','-append',pname3);


% Now we make the figures that Erik wants at the start of the paper

% stdev of relative propensities
sfigure(3); figsetup;
greygrid(Decades,(0.5:.5:2));
plot(Decades,std_relp_young(:,WW),'Color',myblue); hold on;
plot(Decades,std_relp_young(:,BM),'Color',mygreen); 
plot(Decades,std_relp_young(:,BW),'Color',mypurp); 
vals=(0:.5:2.5)';
relabelaxis(vals,num2str(vals));
vals=(1960:10:2010)';
relabelaxis(vals, num2str(vals),'x');
chadfig2('Year','Standard deviation',1,0);
if WideFigures; makefigwide; end;
if 1; %HighQualityFigures;
  text(1996,1.35,'White women'); %,'Color',myblue);
  text(1980,0.75,'Black men'); %,'Color',mygreen);
  text(1967,2.3,'Black women'); %,'Color',mypurp);
end;
print('-dpng',[relpnames '_' CaseName]);
tle='Stdev of log(relp) across occupations';
title(tle);
print('-dpsc','-append',pname3);
disp ' '; disp(tle);
cshow(' ',[Decades std_relp_young],'%6.0f %8.3f','Year WM WW BM BW');

% stdev of Wage Gaps
sfigure(4); figsetup;
greygrid(Decades,(0.1:.1:.4));
plot(Decades,std_wagegap(:,WW),'Color',myblue); hold on;
plot(Decades,std_wagegap(:,BM),'Color',mygreen); 
plot(Decades,std_wagegap(:,BW),'Color',mypurp); 
vals=(0:.1:.5)';
relabelaxis(vals,num2str(vals));
vals=(1960:10:2010)';
relabelaxis(vals, num2str(vals),'x');
chadfig2('Year','Standard deviation',1,0);
if WideFigures; makefigwide; end;
if 1; %HighQualityFigures;
  text(1990,.17,'White women'); %,'Color',myblue);
  text(1968,.15,'Black men'); %,'Color',mygreen);
  text(1978,.26,'Black women'); %,'Color',mypurp);
end;
print('-dpng',[gapnames '_' CaseName]);
tle='Stdev of log(Wage Gap) across occupations';
title(tle);
print('-dpsc','-append',pname3);
disp ' '; disp(tle);
cshow(' ',[Decades std_wagegap],'%6.0f %8.3f','Year WM WW BM BW');

   
    
% Note, I'm clearing tauhat in case we change theta, eta...
clear data*
clear tauhat tauhat_y tauhat_y_cleaned c Cohort i decindx fmt fname g group occnum tf tle total xNumPeople year yrs yy
save(['CohortData_' CaseName]);