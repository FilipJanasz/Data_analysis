function [fitRes, gof] = curveFit(xData,yData,fitType)

    % Fit model to data.
    [fitRes, gof] = fit( xData', yData', fitType );

    