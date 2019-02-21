
%%
fileC=[1,4];

ctr=0;
for m=1:2
    n=fileC(m);
%     wind=4*4096;
%     window=blackmanharris(wind);
%     noverlap=wind/2;
%     nfft=4*4096;
    wind=1024;
    window=blackmanharris(wind);
    noverlap=wind/2;
    nfft=2018;
    fs=10000;

    pairing{1}=[1,2];
    pairing{2}=[1,3];
    pairing{3}=[2,3];
    y{1}=yDat1{n}';
    y{2}=yDat1{n+1}';
    y{3}=yDat1{n+2}';

    num1=numel(y{1});
    num2=numel(y{2});
    num3=numel(y{3});

    if num1>num2
        endLoc(1)=num2;
    else
        endLoc(1)=num1;
    end

    if num1>num3
        endLoc(2)=num3;
    else
        endLoc(2)=num1;
    end

    if num2>num3
        endLoc(3)=num3;
    else
        endLoc(3)=num2;
    end

    %% getdata
    for n=1:numel(y)
        ctr=ctr+1;
        [Pxy{ctr},f{ctr}]=cpsd(y{pairing{n}(1)}(1:endLoc(n)),y{pairing{n}(2)}(1:endLoc(n)),window,noverlap,nfft,fs);
        [Pw{ctr},fw{ctr}]=pwelch(y{pairing{n}(1)}(1:endLoc(n)),window,noverlap,nfft,fs);

    end
end

    %% plot
    limHigh=-80;
    limLow=-190;
    h=figure;
     h.Position=[380   158   1260   620];
        
    % subplot(3,1,1)
    ctr=0;
    for m=1:numel(fileC)
        s(m)=subplot(2,1,m);
        hold on 
        box on
        grid on
        for n=1:numel(y)
            ctr=ctr+1;
            p1(ctr)=plot(f{ctr},pow2db(abs(Pxy{ctr})),'-');
            p1(ctr).Color=colorstring{n};
            p1(ctr).LineWidth=1.5;
    %         p2(n)=plot(fw{n},pow2db(abs(Pw{n})),'-');
    %         p2(n).Color=colorstring{2};
    %         p3(n)=plot(fres1{n},pow2db(abs(P1{n})),'-');
    %         p3(n).Color=colorstring{3};
        end
        
%          s(m).YScale='log';
        switch m
            case 1
                legend({'cond/cond','cond/plug','cond/plug'},'FontWeight','bold')
%                 ylim([-125 -80])
            case 2
                legend({'cond/mix','cond/plug','mix/plug'},'FontWeight','bold')
%                 ylim([-125 -90])
        end 
        ylabel('Cross power spectral density [dB]','FontWeight','bold')
        xlabel('Frequency [Hz]','FontWeight','bold')
        ylim([-120 -70])
%         xlim([4000 4500])
    end
   

print('D:\Data_analysis\HFvsNCgasHIGH_FREQ2_CROSS','-dmeta')
% [pks,frqs] = findpeaks(abs(P1),fres);
disp('Fertig')

% n=1
% p(n)=plot(f{n},abs(pow2db(abs(Pxy{1}))-pow2db(abs(Pxy{2}))),'-');
% p(n).Color=colorstring{n};
% n=2
% p(n)=plot(f{n},abs(pow2db(abs(Pxy{1}))-pow2db(abs(Pxy{3}))),'-');
% p(n).Color=colorstring{n};
% n=3
% p(n)=plot(f{n},abs(pow2db(abs(Pxy{2}))-pow2db(abs(Pxy{3}))),'-');
% p(n).Color=colorstring{n};
