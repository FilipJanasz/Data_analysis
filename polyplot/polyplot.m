function [h,p,delta] = polyplot(x,y,varargin) 
% polyplot plots a polynomial fit to scattered x,y data. This function
% can be used to easily add a linear trend line or other polynomial 
% fit to a data plot. 
% 
%
%% Syntax
%
% polyplot(x,y)
% polyplot(x,y,n)
% polyplot(...,'LineProperty',LineValue,...)
% polyplot(...,'error')
% polyplot(...,'error','ErrorLineProperty',ErrorLineValue)
% [h,p,delta] = polyplot(...)
% 
%% Description 
% 
% polyplot(x,y) places a least-squares linear trend line through 
% scattered x,y data. 
%
% polyplot(x,y,n) specifies the degree n of the polynomial fit to 
% the x,y data. Default n is 1. 
%
% polyplot(...,'LineProperty',LineValue,...) formats linestyle
% using LineSpec property name-value pairs ('e.g., 'linewidth',3). 
% 
% polyplot(...,'error') includes lines corresponding to approximately
% +/- 1 standard deviation of errors delta.  At least 50% of data should 
% lie within the bounds of error lines. 
%
% polyplot(...,'error','ErrorLineProperty',ErrorLineValue) formats error
% lines with line property name-value pairs. All arguments occurring after
% 'error' are assumed to be error line property specifications. 
%
% [h,p,delta] = polyplot(...) returns handle(s) h of plotted line(s),
% coefficients p of polynomial fit p(x), and error estimate delta, which is
% the standard deviation of error in predicting a future observation at x
% by p(x). Assuming independent, normal, constant-variance errors, y +/- delta 
% contains at least 50% of the predictions of future observations at x.
% 
%
%% Examples 
% Given this data: 
% 
%     x = 1:100; 
%     y = 12 - 0.01*x.^2 + 3*x + sind(x) + 30*rand(size(x)); 
%     plot(x,y,'bo')
%     hold on
% 
% Plot a linear trend line: 
% 
%     polyplot(x,y);
% 
% Plot a cubic fit line: 
% 
%     polyplot(x,y,3) 
% 
% Plot a fat, red, 7th-order polynomial fit: 
% 
%     polyplot(x,y,7,'r','linewidth',4);
% 
% Plot a quadratic fit line with error bounds: 
% 
%     polyplot(x,y,2,'error') 
%     
% Plot a heavy black, dotted cubic fit line with thin dashed magenta error bounds:
% 
%     polyplot(x,y,3,'k:','linewidth',5,'error','m--','linewidth',.3)
% 
%% Author Info
% 
% This function was written by Chad A. Greene of the University of Texas
% Institute for Geophysics (UTIG) in Austin, Texas, January 2015. 
% http://www.chadagreene.com
% 
% See also plot, polyfit, polyval, and LineSpec. 

assert(numel(x)==numel(y),'Number of elements in x must equal number of elements in y.') 

% Columnate inputs to ensure polyfit will work: 
x = x(:); 
y = y(:); 

% Set defaults: 
n = 1; 
xfit = [min(x) max(x)]; 
ploterror = false; 

% Parse optional inputs: 
if nargin>2
    if isscalar(varargin{1}) 
        % assume it's the order of the fit
        n = varargin{1}; 
        assert(mod(n,1)==0,'Polynomial degree n must be an integer.')
        assert(n>=0,'Polynomial degree n cannot be negative.')
        varargin(1)=[]; 
        xfit = linspace(min(x),max(x),1024); 
    end
    
    tmp = strncmpi(varargin,'err',3); 
    if any(tmp)
        ploterror = true; 
        ern = find(tmp); % index of 'error' occurrence in varargin
        lv = length(varargin);
        if lv>=ern % everything after 'error' is a preference for error line style 
            errorprefs = varargin(ern+1:lv); 
            if ern>1
                varargin = varargin(1:ern-1); 
            else
                varargin = []; 
            end
        end
    end
end

% Make like Richard Simmons and get fit: 
[p,S,mu] = polyfit(x,y,n);
[yfit,delta] = polyval(p,xfit,S,mu);

% Plot fit line: 
h = plot(xfit,yfit,varargin{:}); 

% Plot fit +/- 1 standard deviation of error: 
if ploterror
    h(2) = plot(xfit,yfit+delta,errorprefs{:}); 
    h(3) = plot(xfit,yfit-delta,errorprefs{:}); 
end

% Clean up: 
if nargout==0
    clear h; 
end