% ShowParameters.m
%
%  Show the key parameters for the Talent project

mu=1/theta*1/(1-eta);
gam=gamma(1-mu);
if FiftyFiftyTauHat;
    AlphaSplitTauW1960=1/2;
end;
disp ' ';
disp '=============================================================';
disp(['KEY PARAMETER VALUES:    CaseName = ' CaseName]);;
fprintf('             theta =%8.4f\n',theta);
fprintf('               eta =%8.4f\n',eta);
fprintf('      theta*(1-eta)=%8.4f\n',theta*(1-eta));
fprintf('                mu =%8.4f\n',mu);
fprintf('             sigma =%8.4f\n',sigma);
fprintf('      LFPMinFactor =%8.4f\n',LFPMinFactor);
fprintf('     ConstrainTauH =%8.4f\n',ConstrainTauH);
if exist('AlphaSplitTauW1960');
    fprintf('AlphaSplitTauW1960 =%8.4f\n',AlphaSplitTauW1960);
end;
fprintf('         phi(Farm) = '); fprintf('%7.4f',phiFarm); disp ' ';
%fprintf(['       WhatToChain = ' WhatToChain '\n']);
if WeightPigMiddle~=1/2;
    fprintf('   WeightPigMiddle =%8.4f\n',WeightPigMiddle);
end;
if FiftyFiftyTauHat;
    fprintf('FiftyFiftyTauHat = 1 -- robust 50/50 split of tauhat\n');
end;
if IgnoreBrawnyOccupations;
    fprintf('IgnoreBrawnyOccupations = 1 -- choosing T(i,g) to zero out tauw/h there\n');
end;
if SameExperience==0;
    fprintf('    HomeExperience =%6.2f %6.2f %6.2f\n',HomeExperience);
    fprintf('SameExperience = 0 -- all occs have different returns to experience\n');
end;
if AlphaFixedSplit>0;
    fprintf('   AlphaFixedSplit =%8.4f\n',AlphaFixedSplit);
end;
if NoFrictions2010;
    fprintf('NoFrictions2010 = 1 -- choosing T(i,g,2010) s.t. set tauw(2010)=tauh(2010)=0\n');
end;
if WageGapAdjustmentFactor~=1;
    fprintf('WageGapAdjustmentFactor =%8.4f\n',WageGapAdjustmentFactor);
    if WageGapAdjustmentFactor==0;
        disp('  (i.e. using WM wages for all groups, so no wage gaps');
    end;
end;
if isequal(CaseName,'TauWWisZero');
    disp ' '; 
    disp '********************************************************';
    disp 'NOTE WELL: WW and WM are *swtiched* in everything that follows';
    disp '   in order to check robustness to assuming tau(WW)=0 as our';
    disp '   normalization';
    disp '********************************************************';
    disp ' '; 
end;

disp '=============================================================';
disp ' ';
