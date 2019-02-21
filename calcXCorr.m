function h=calcXCorr(yData1,yData2,maxlag,sampleRate)

    [acor,lag] = xcorr(yData1,yData2,'coeff');

    %calculate lag
    [~,I] = max(abs(acor));
    lagDiff = lag(I);                     %lag in data points
%     timeDiff = lagDiff/sampleRate;     %lag in seconds
    period=1/sampleRate;
    xDat1=period:period:numel(yData1)*period;
    xDat2=period:period:numel(yData2)*period;
    %plot in separate figure
    h=figure;
    %%
    subplot(3,1,1)
    title('Cross-correlation between s1 and s2')
    hold on
    plot(lag./sampleRate,acor)
    %%
    subplot(3,1,2)
    hold on
    yyaxis left
    plot(xDat1,yData1,'-')
    plot(xDat2,yData2,'r-')
    %%
    subplot(3,1,3)
    hold on
    yyaxis left
    title(num2str(lagDiff))
    plot(xDat1,yData1,'-')
    plot(xDat2+lagDiff/sampleRate,yData2,'r-')
        
end