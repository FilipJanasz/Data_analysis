%% |polyplot| documentation 
% This function plots a polynomial fit to scattered _x,y_ data. This function
% can be used to easily add a linear trend line or other polynomial fit
% to a data plot. 
% 
%
%% Syntax
%
%  polyplot(x,y)
%  polyplot(x,y,n)
%  polyplot(...,'LineProperty',LineValue,...)
%  polyplot(...,'error')
%  polyplot(...,'error','ErrorLineProperty',ErrorLineValue)
%  [h,p,delta] = polyplot(...)
% 
%% Description 
% 
% |polyplot(x,y)| places a least-squares linear trend line through 
% scattered _x,y_ data. 
%
% |polyplot(x,y,n)| specifies the degree |n| of the polynomial fit to 
% the _x,y_ data. Default |n| is |1|. 
%
% |polyplot(...,'LineProperty',LineValue,...)| formats linestyle
% using |LineSpec| property name-value pairs (e.g., |'linewidth',3|). 
% 
% |polyplot(...,'error')| includes lines corresponding to approximately
% +/- 1 standard deviation of errors |delta|.  At least 50% of data should 
% lie within the bounds of error lines. 
%
% |polyplot(...,'error','ErrorLineProperty',ErrorLineValue)| formats error
% lines with line property name-value pairs. All arguments occurring after
% |'error'| are assumed to be error line property specifications. 
%
% |[h,p,delta] = polyplot(...)| returns handle(s) |h| of plotted line(s),
% coefficients |p| of polynomial fit _p(x),_ and error estimate |delta|, which is
% the standard deviation of error in predicting a future observation at x
% by p(x). Assuming independent, normal, constant-variance errors, y +/- |delta| 
% contains at least 50% of the predictions of future observations at x.

%% Examples 
% Given some data: 

x = 1:100; 
y = 12 - 0.01*x.^2 + 3*x + sind(x) + 30*rand(size(x)); 

%% 
% Plot the data and add a simple linear trend line: 

plot(x,y,'bo')
hold on
polyplot(x,y); 

legend('data','linear fit','location','southeast')
%% 
% Instead of a linear trend, make it a cubic fit:

figure
plot(x,y,'bo')
hold on

polyplot(x,y,3);
legend('data','cubic fit','location','southeast')

%% 
% A fat, red 7th-order polynomial fit: 

figure
plot(x,y,'bo')
hold on
polyplot(x,y,7,'r','linewidth',4);
legend('data','7^{th} order fit','location','southeast')

%% 
% Same as above, but with +/- 1 standard deviation of error lines: 

figure
plot(x,y,'bo')
hold on
polyplot(x,y,7,'r','linewidth',4,'error');
legend('data','7^{th} order fit','\pm1\sigma','location','southeast')


%% 
% Heavy black dotted quadratic fit with thin dashed magenta error lines:

figure
plot(x,y,'bo')
hold on
polyplot(x,y,2,'k:','linewidth',5,'error','m--','linewidth',.3)
legend('data','quadratic fit','\pm1\sigma','location','southeast')

%% Author Info
% The |polyplot| function and supporting documentation were created by
% <http://www.chadagreene.com Chad A. Greene> of the University of Texas 
% at Austin's <http://www.ig.utexas.edu/research/cryosphere/ Institute for
% Geophysics (UTIG)>. January 2015. 