function [f,P1]=calcFFT(X,Fs)

    % X=fr3(1:50000);
    L=numel(X);
    n = 2*2^nextpow2(L);
    % Fs=100;
%     Y = fft(hanning(length(X)).*X,n);
    Y = fft(X,n);
    %Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
    L=n;
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
%     P1 = Y.*conj(Y)/L;
%     P1=P1(1:0.5*numel(P1)+1y);
    P1(2:end-1) = 2*P1(2:end-1);
    %Define the frequency domain f and plot the single-sided amplitude spectrum P1. The amplitudes are not exactly at 0.7 and 1, as expected, because of the added noise. On average, longer signals produce better frequency approximations.

    f = Fs*(0:(L/2))/L;

end