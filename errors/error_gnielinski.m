function finalError=error_gnielinski(varargin)
    
   
    %% get values of parameters and associated errors
    params=varargin(1:end);
    
    for n=1:numel(params)/2
        vals(n)=params{2*n-1};
        errs(n)=params{2*n};  
    end
    
     
     %% create input matrix
     for n=1:numel(vals)
        matrVars(n,:)=vals;
     end
     
     for n=1:numel(errs)
         matrErrs(n,n)=errs(n);
     end

     %now all inputs have applied appropriate errors separately
     matrInput=matrVars+matrErrs;
     %first line becomes undisturped output
     matrInput=[vals;matrInput];
     
     
     %% prepare commands
     for n=1:numel(vals)+1
         command{n}='htc_gnielinski(';
         for q=1:numel(vals)
             if q==1
                command{n}=[command{n},num2str(matrInput(n,q))];
             else
                 command{n}=[command{n},',',num2str(matrInput(n,q))];
             end
         end
         command{n}=[command{n},')'];
         
     end
     
     %% calculate outputs
     for n=1:numel(vals)+1
        matrOut(n)=eval(command{n});
     end
     
     base=matrOut(1);
     matrOut(1)=[];
     
     
     %% calculated finite difference with respect to each variable
     for n=1:numel(vals)
         derivErrs(n)=abs(base-matrOut(n));
     end
     
     %% sum final error
     finalError=sqrt(sum(derivErrs.^2));
end