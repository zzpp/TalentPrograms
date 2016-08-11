definecolors;

clrs2=[myred; myblue; mygreen; mypurp; myred; myblue; mygreen; mypurp];
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
    figure(1); figsetup; hold on;
    for c=1:8;
        % Find the years for a given cohort
        yrs=Decades(any(CohortConcordance'==c)); 
        [tf yy]=ismember(yrs,Decades);

        plot(yrs,log(squeeze(wagegap_gct(g,c,yy))),syms(c),'Color',clrs2(c,:)); %,cat(2,clrs(c),syms(c)));
        plot(yrs,log(squeeze(wagegap_gct(g,c,yy))),'-','Color',clrs2(c,:)); 
    end;
    ax=axis; ax(4)=0; axis(ax);
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

