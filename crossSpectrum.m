
%%
%first run handPlotting_highF_GHFS_vsGAS_HIGHFREQ2_FFT_LOWEND
% handPlotting_highF_GHFS_vsGAS_HIGHFREQ2_FFT_LOWEND
%to load data properly
fileC=[1,4];

ctr=0;
for m=1:2
    n=fileC(m);
%     wind=4*4096;
%     window=blackmanharris(wind);
%     noverlap=wind/2;
%     nfft=4*4096;
    wind=1024;
    wind2=wind*8;
    window=blackmanharris(wind);
    window2=blackmanharris(wind2);
    noverlap=wind/2;
    noverlap2=wind2/2;
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
        [Pxy{ctr},fres{ctr}]=cpsd(y{pairing{n}(1)}(1:endLoc(n)),y{pairing{n}(2)}(1:endLoc(n)),window,noverlap,nfft,fs);
        [Pxy2{ctr},fres2{ctr}]=cpsd(y{pairing{n}(1)}(1:endLoc(n)),y{pairing{n}(2)}(1:endLoc(n)),window2,noverlap2,nfft*8,fs);
%         [Pw{ctr},fw{ctr}]=pwelch(y{pairing{n}(1)}(1:endLoc(n)),window,noverlap,nfft,fs);

    end
end

    %% plot
    limHigh=-80;
    limLow=-190;
    h=figure;
     h.Position=[380   158   1260   620];
        
    % subplot(3,1,1)
    ctr=0;
    sCtr=1;
    for m=1:numel(fileC)
        
        s(sCtr)=subplot(2,2,sCtr);
        hold on 
        box on
        grid on
        for n=1:numel(y)
            ctr=ctr+1;
            p1(ctr)=plot(fres{ctr},pow2db(abs(Pxy{ctr})),'-');
            p1(ctr).Color=colorstring{n};
            p1(ctr).LineWidth=1.5;
    %         p2(n)=plot(fw{n},pow2db(abs(Pw{n})),'-');
    %         p2(n).Color=colorstring{2};
    %         p3(n)=plot(fres1{n},pow2db(abs(P1{n})),'-');
    %         p3(n).Color=colorstring{3};
        end
        
%          s(m).YScale='log';
%         switch m
%             case 1
%                 legend({'cond/cond','cond/plug','cond/plug'},'FontWeight','bold')
% %                 ylim([-125 -80])
%             case 2
%                 legend({'cond/mix','cond/plug','mix/plug'},'FontWeight','bold')
% %                 ylim([-125 -90])
%         end 
        ylabel('Cross power spectral density [dB]','FontWeight','bold')
        xlabel('Frequency [Hz]','FontWeight','bold')
        ylim([-120 -50])
        xlim([0 2000])
        sCtr=sCtr+1;
        ctr=0;
        
        s(sCtr)=subplot(2,2,sCtr);
        
         hold on 
        box on
        grid on
        for n=1:numel(y)
            ctr=ctr+1;
            p2(ctr)=plot(fres2{ctr},pow2db(abs(Pxy2{ctr})),'-');
            p2(ctr).Color=colorstring{n};
            p2(ctr).LineWidth=1.5;
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
        ylim([-120 -50])
        xlim([0 200])
        sCtr=sCtr+1;

    end
   
    s(1).Position=[0.0800    0.6    0.5347    0.3412];
    s(2).Position=[0.6703    0.6    0.2347    0.3412];
    s(3).Position=[0.0800    0.19    0.5347    0.3412];
    s(4).Position=[0.6703    0.19    0.2347    0.3412];
%     s(3).XLabel.String='f [Hz]';
%     s(3).XLabel.FontWeight='bold';
%     s(4).XLabel.String='f [Hz]';
%     s(4).XLabel.FontWeight='bold';



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
