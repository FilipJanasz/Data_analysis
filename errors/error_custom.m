function finalError_rel=error_custom(varargin)
    
    
    %% get values of parameters and associated errors
    params=varargin(1:end);
    
    for n=1:numel(params)/2
        vals(n)=params{2*n-1};
        errs_abs(n)=params{2*n};  
        errs_rel(n)=errs_abs(n)/vals(n);
    end
    
     finalError_rel=sqrt(sum(errs_rel.^2));
     
end