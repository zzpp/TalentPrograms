%zihoistopper
clear myvarszihoistopper

mycomplexvars=[];
myvarszihoistopper=who;

jzihoistopper=0;
for kzihoistopper=1:length(myvarszihoistopper)
    if isnumeric(eval(myvarszihoistopper{kzihoistopper})) && ~isreal(eval(myvarszihoistopper{kzihoistopper}))
        jzihoistopper=jzihoistopper+1;
       mycomplexvars{jzihoistopper}=myvarszihoistopper{kzihoistopper};
    end
end

if ~isempty(mycomplexvars)
    mycomplexvars
   keyboard 
end

clear kzihoistopper
clear jzihoistopper
