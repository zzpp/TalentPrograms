% AdditionalFigures.m
%
%  Covariance between TauH and TauW for Chang
%  Benchmark levels from Chaining2
%  Blau-Kahn female LS elasticities 
%  Charles-Guryan discrimination


clear;
diarychad('AdditionalFigures');
definecolors;

load Chaining2_Benchmark;

% Covariance between TauH and TauW for Chang
clear stuff;
disp 'Statistics for TW := 1/(1-TauW) and TH := (1+TauH)^eta -- Unweighted'
for g=2:Ngroups;
    disp ' ';
    disp(GroupNames{g});
    for t=1:Nyears;
        tw=1./(1-TauW(2:Noccs,g,t));
        th=(1+TauH(2:Noccs,g,7-t)).^eta;
        CC=corrcoef([tw th]);
        CV=cov([tw th]);
        stuff(t,:)=[Decades(t) CV(1,1) CV(2,2) CV(1,2) CC(1,2)];
    end;
    cshow(' ',stuff,'%8.0f %12.3f','Year Var(TW) Var(TH) Cov(TW,TH) Corr(TW,TH)'); 
end;



%  Benchmark levels from Chaining2
disp ' '; disp ' ';
disp 'Benchmark levels from Chaining2';
Y_GDP=100*GDP/GDP(1);
Y_Base=100*YBaseline(:,1)/YBaseline(1,1);
Y_TWTH=100*[1; cumprod(Gr_geo_TWTH(:,1))];
Y_BothZ=100*[1; cumprod(Gr_geo_BothZ(:,1))];
Y_All4 =100*[1; cumprod(Gr_geo_All4(:,1))];

cshow(' ',[Decades Y_Base Y_TWTH Y_BothZ Y_All4],'%6.0f %8.1f','Year Baseline TWTH BothZ All4');

figure(1); figsetup; hold on;
plot(Decades,Y_GDP,'-','Color',myblue);
plot(Decades,Y_Base,'-','Color',mygreen);
plot(Decades,Y_TWTH,'-','Color',myred);
%plot(Decades,Y_BothZ,'-','Color',myred);
plot(Decades,Y_All4,'-','Color',mypurp);
vals=(1960:10:2010)';
relabelaxis(vals, num2str(vals),'x');
chadfig2('Year','GDP per person (1960=100)',1,0);
makefigwide;

text(1985,190,'Data');
text(1996,190,'Model');
text(1998,145,'\tau^h, \tau^w, \it{z}, \it{T_g}^{home}');
text(2004,118,'\tau^h and \tau^w');
print('-dpng','BenchmarkLevels');






abc

% Year	Cohort		Blau-Khan	Our Estimate
% 1980	y		0.76	3.13
% 	m		0.75	2.94
% 	o		1.06	3.58
% 1990	y		0.59	1.83
% 	m		0.61	1.74
% 	o		0.68	2.05
% 2000	y		0.33	1.75
% 	m		0.39	1.77
% 	o		0.45	1.64
% Labor supply elasticities for White Women by Year and Cohort
 
% Our results, from CleanandShowTauAZ_Benchmark.log    
%  Year   Young  Middle     Old
%------------------------------

data_hhjk=[
%  1960    6.00    4.30    3.51
%  1970    4.04    3.26    2.75
  1980    1.81    1.93    2.20
  1990    1.13    1.08    1.27
  2000    1.08    1.09    1.01
%  2010    0.95    1.01    0.97
    ];

data_bk=[
    1980 0.76  0.75  1.06
    1990 0.59  0.61  0.68
    2000 0.33  0.39  0.45
    ];

LSWW_hhjk=vector(data_hhjk(:,2:4));
LSWW_bk  =vector(data_bk(:,2:4));
names=strmat('1980y 1990y 2000y 1980m 1990m 2000m 1980o 1990o 2000o');

figure(1); figsetup;
plotnamesym2(LSWW_bk,LSWW_hhjk,names,10,[],.05,.1); %,1,1);
addolsline(LSWW_bk,LSWW_hhjk,myred,1);
chadfig2('Blau and Kahn elasticities','Model estimates',1,0);
print('-dpng','BlauKahn');
print('-dpsc','AdditionalFigures.ps');


%	Our Measure	Charles Guryan Measure	Weighting Variable
%statefip	weighted_mean_tau	CG_marginal_dis_measure	sample_size_black
data=[
1	1.544	-0.1701046	13701.91
2	1.19	-0.4979347	219.62
4	1.348	-0.6540824	1555.22
5	1.397	-0.4308558	4590.12
6	1.239	-0.6426146	35276.23
8	1.237	-0.6540824	2163.88
9	1.311	-0.5990469	4045.72
10	1.36	-0.4979347	1647.54
12	1.472	-0.5199246	25014.14
13	1.449	-0.363777	25406.71
15	NaN	NaN	211.26
16	NaN	NaN	49.66
17	1.368	-0.5661492	25259.96
18	1.179	-0.6232504	6332.98
19	1.234	-0.8139812	699.75
20	1.294	-0.6412269	2015.34
21	1.284	-0.6426146	3555.34
22	1.591	-0.3841126	17338.21
23	NaN	NaN	95.42
24	1.278	-0.5320681	19695.87
25	1.24	-0.6540824	4643.59
26	1.236	-0.5990469	17583.39
27	1.355	-0.794554	1452.42
28	1.678	-0.363777	11596.53
29	1.289	-0.6362928	7571.32
30	NaN	-0.8139812	33.17
31	1.432	NaN	761.15
32	1.325	NaN	1212.68
33	NaN	-0.66246	136.44
34	1.384	-0.5990469	16638.92
35	NaN	NaN	445.97
36	1.337	-0.5606396	44371.11
37	1.431	-0.3604226	21622.21
38	NaN	-0.66246	37.57
39	1.276	-0.6232504	16808.67
40	1.331	-0.5990469	3075.39
41	1.291	-0.8139812	763.86
42	1.291	-0.6232504	16574.65
44	1.321	-0.6540824	544.74
45	1.618	-0.363777	14584.93
46	NaN	-0.4979347	30.99
47	1.331	-0.5320681	10966.31
48	1.357	-0.5755357	30793.94
49	NaN	-0.66246	188.09
50	NaN	-0.5326762	35.5
51	1.44	-0.5320681	17680.62
53	1.215	-0.6426146	2248.91
54	1.199	-0.8139812	768.18
55	1.358	-0.8139812	3235.31
56	NaN	-0.66246	47.9
];
statenames=strmat('AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY');
statefip=data(:,1);
hhjk=data(:,2);
cg=data(:,3);
weights=data(:,4);


msize=sqrt(weights);
msize=msize/min(msize)*5;

figure(2); figsetup;
s=scatter(hhjk,cg,msize);
s.LineWidth = 0.6;
s.MarkerEdgeColor = 'b';
s.MarkerFaceColor = [0 0.5 0.5];
addolsline(hhjk,cg,myred,1,weights); 
addnames(hhjk,cg,statenames,10,[],.02,.02);
chadfig2('Composite barrier (pooled 1980/90)','Marginal discrimination measure',1,1)
print('-dpng','CharlesGuryan');
print('-dpsc','-append','AdditionalFigures.ps');

diary off;