Fs=100;

% x1=GHFS(6).GHFS2.var(1:23000);
x1=MP(6).MP1.var(1:23000);
[f1, P1]=plotFFT(x1,Fs);
% x2=GHFS(6).GHFS2.var(24000:25500);
x2=MP(6).MP1.var(24000:25500);
[f2, P2]=plotFFT(x2,Fs);
% x3=GHFS(6).GHFS2.var(27000:end);
x3=MP(6).MP1.var(27000:end);
[f3, P3]=plotFFT(x3,Fs);

 figure
 hold on
    plot(f1,P1) 
    plot(f2,P2) 
    plot(f3,P3) 
    %title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    temp=xlim;
    ylim([0 0.004])
    xlim(temp);