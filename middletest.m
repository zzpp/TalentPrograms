% FUNCTIONS ---------------------------------------------

function ssr=middletest(alpha1,eta,theta,WeightPig,WeightWage);

    % Returns the SSR for the deviation of our 2 moments from their model values
    % pig(t+j) and wagegrowth(t+j)
    [mpig,mwagegrowth]=pgmoments_alpha(alpha1,eta,theta); %pgmoments_alpha(alpha1,tauhat1,pig_y,Tghome,Tig,wHome,s,s_y,phiHome,w,phi,pig,mg,eta,beta,theta,growthden,ptilde0,THOME);
    e1  = WeightPig*(0-mpig);                 % Note: WeightPig is either 0 or 1 at this stage
    e2  = WeightWage*(0-mwagegrowth);  %       WeightWage is either 0 or 1
    e=[e1 e2]';
    ssr=e'*e;

function [mpig,mwagegrowth,Pwork]=pgmoments_alpha(alpha1,eta,theta);

    tauw=1-2.5^(-alpha1);

    % Returns the models values of pig(Cohort,t) and wagegrowth
    % pig -- mpig 1x1 contains the moments to match to pig(c,t)
    %pstuff=THOME*Tghome*wHome*s^phiHome / ((1-tauw)*Tig*w*s^phi);
    pstuff=1/ (1-tauw);
    mpig=1/(1+pstuff^theta);

    % wagebar(c,t) -- assumes wage growthden already passed
    %Pwork=1-mpig.*pstuff.^theta;
    Pwork=mpig;
    mu=1/theta*1/(1-eta);
    growthnum=Pwork^(-mu)*(1-tauw);
    mwagegrowth=growthnum/1;
