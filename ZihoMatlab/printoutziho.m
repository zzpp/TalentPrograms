function printoutziho(file_name,erase_old, varargin)
%ex)printoutziho('THOME.xlsx',1, THOME)

if erase_old==1
    delete(file_name)
end

nvars = length(varargin);

for i=1:nvars
    clear bigvar
    if ndims(varargin{i})<3
        if ~isempty(varargin{i})
        xlswrite(file_name,varargin{i},inputname(i+2)) %print varargin{i} to ith sheet
        end
    elseif ndims(varargin{i})==3
        bigvar=varargin{i};
        [n1,n2,n3]=size(bigvar);
        for j=1:n1
            if ~isempty(varargin{i})
            xlswrite(file_name,squeeze(bigvar(j,:,:)),  inputname(i+2)   ,['A',num2str(n2*(j-1)+j)])
            end
        end
    elseif ndims(varargin{i})==4
    disp('dimension of 4 is already too large. Check if you can reduce the dimension')
        bigvar=varargin{i};
        [n1,n2,n3,n4]=size(bigvar);
        l=0;
        for j=1:n1
            for k=1:n2
                l=l+1;
                if ~isempty(varargin{i})
                xlswrite(file_name,squeeze(bigvar(j,k,:,:)),  inputname(i+2)  ,['A',num2str(n3*(l-1)+l)])
                end
            end
        end
    else
        disp('Too many dimensions')
        keyboard
    end
end
