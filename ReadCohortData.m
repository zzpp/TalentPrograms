% ReadCohortData  1/29/14
%
% Reads the cohort data assembled by Erik in occupation_file_chad*.csv
% (see the .xls file for more details).
%
%  Jan 2015: Change wage gap so it is *occupation*-specific as well
%             (since we now have "z" preference shocks).
%
%  2/26/15 -- Read Erik's new spreadsheet that fixes the 1980 data.
%             Currently ignoring any 1950 data.
%
%  12/29/15 -- Calls LookatCohortData.m

if ~exist('CaseName');
    CaseName=input('What would you like to call the Case Name? ','s');
end;
diarychad('ReadCohortData',CaseName);
ShowParameters;

%Year,Group,Cohort,Occupation Number,Weighted Total People in Occ,Avg Occ Income,Education,Wage
%2010,10,1,0,7610209.5,,12.7,
%2010,10,1,1,1965792.0,54377.4,15.0,

%fname='occupation_file_chad-2015-06-16.csv';
fname='occupation_file_chad-2016-07-18-final.csv';

fmt='%f %f %f %f %f %f %f %f';
[year,group,cohort,occnum,dataNumPeople,dataEarnings,dataEducation,dataWage]=textread(fname,...
   fmt,'headerlines',1,'delimiter',',','emptyvalue',NaN);
occnum=occnum+1;  % So Home=1 rather than Home=0

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize key variables
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nrecords=length(dataNumPeople);
Noccs=67
Ngroups=4  % wm ww bm bw
Ncohorts=8
Decades=[1960 1970 1980 1990 2000 2010]';
Nyears=length(Decades);

NumPeople=zeros(Noccs,Ngroups,Ncohorts,Nyears);
Education=NumPeople;
EarningsNominal=NumPeople;
WageNominal=NumPeople;
Earnings=NumPeople;
Wage=NumPeople;

disp 'Putting earnings / wage in $2009 constant using PCE Deflator';
% See PCEDeflatorNIPA.txt from https://research.stlouisfed.org/fred2/series/DPCERD3A086NBEA
pce=[
   17.535   % 1960-01-01
   22.311   % 1970-01-01
   43.959   % 1980-01-01
   67.440   % 1990-01-01
   83.131   % 2000-01-01
  101.653   % 2010-01-01
]';


% Totals across all groups (provided by Erik in the .xls file)
AllNumPeople=zeros(Noccs,Ncohorts,Nyears);
AllEducation=AllNumPeople;
AllEarnings=AllNumPeople;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reshape into the multidimensional matrices
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:Nrecords;
    if group(i)==10; % All
        AllNumPeople(occnum(i),cohort(i),find(Decades==year(i)))=dataNumPeople(i);
        AllEarnings(occnum(i),cohort(i),find(Decades==year(i)))=dataEarnings(i);
        AllEducation(occnum(i),cohort(i),find(Decades==year(i)))=dataEducation(i);
    else; % One of our 4 key groups
        if year(i)>1950; % Ignore the 1950 data for now...
            decindx=find(Decades==year(i)); % e.g. decindx=2 for year=1970
            NumPeople(occnum(i),group(i),cohort(i),decindx)=dataNumPeople(i);
            EarningsNominal(occnum(i),group(i),cohort(i),decindx)=dataEarnings(i);
            Earnings(occnum(i),group(i),cohort(i),decindx)=dataEarnings(i)/pce(decindx)*pce(Nyears);
            Education(occnum(i),group(i),cohort(i),decindx)=dataEducation(i);
            WageNominal(occnum(i),group(i),cohort(i),decindx)=dataWage(i);
            Wage(occnum(i),group(i),cohort(i),decindx)=dataWage(i)/pce(decindx)*pce(Nyears);
        end;        
    end;
end;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute p == fraction of WW in Cohort 3 in 2000 who are lawyers
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p=zeros(size(NumPeople));
% Treat "NaN as 0 for purposes of computing p
xNumPeople=NumPeople;
xNumPeople(isnan(xNumPeople))=0;
total=sum(xNumPeople,1); % Add across occupations
for i=1:Noccs;
    p(i,:,:,:)=xNumPeople(i,:,:,:)./total;
end;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute q(g,c,t) == fraction of Population who are WW in Cohort 3 in 2000 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xNumPeople_t=sum(squeeze(sum(sum(xNumPeople)))); % 1xT vector date t "populations"
xNumPeople_gct=squeeze(sum(xNumPeople));         % Sum over occupations
q=zeros(Ngroups,Ncohorts,Nyears)*NaN;
for t=1:Nyears;
    q(:,:,t)=squeeze(xNumPeople_gct(:,:,t))/xNumPeople_t(t);
end;


Names67Occupations; % load the names and "brawny" occupation index.


% Adjust Earnings if WageGapAdjustmentFactor=1/2 or Zero.
%  That is, Earnings = (1-WageGapAdjustmentFactor)*Earnings(WM) + WageGapAdjustmentFactor*Earnings(g)
%   Zero ==> Earnings = WM earnings, so no wage gap.
%   1/2  ==>  equally-weighted average of own and WM earnings.
for g=1:Ngroups;
    Earnings(:,g,:,:)=(1-WageGapAdjustmentFactor)*Earnings(:,WM,:,:) + WageGapAdjustmentFactor*Earnings(:,g,:,:);
    Wage(:,g,:,:)=(1-WageGapAdjustmentFactor)*Wage(:,WM,:,:) + WageGapAdjustmentFactor*Wage(:,g,:,:);
end;

% Now call LookatCohortData to create some graphs
% and save the data for estimation.

LookatCohortData

diary off;
