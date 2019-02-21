clc

h=figure;
% h.Position0;
width = 8;     % Width in inches
height = 1;    % Height in inches
h.Position=([500 200 500+width*100, 200+height*100]);
% xDat=steam.TF9606.var
% y1st=1440;
% y1end=1640;
% y1st=2470;
% y1end=2940;
% filN=6;

y1st=2600;
y1end=3500;
filN=5;
smN=1;
% yFilt=smooth(y1Dat,100);
padNo=0;
% y14Filt=padarray(y1Dat,padNo,10,'both');
offset1=-0;
offset2=0;
y1Dat=MP(filN).MP1.var((y1st+offset1)*100:(y1end+offset1)*100);
% yFilt=lowpass(y1Dat,0.01,100);
yFilt=smooth(y1Dat,1000);
y2Dat=yFilt(padNo+1:end-padNo);
nX=50;
y2Dat=y2Dat(nX:end-nX);
y3Dat=steam(filN).TF9604.var(y1st:y1end);
y4Dat=MP(filN).Temp.var((y1st+offset2)*10:(y1end+offset2)*10);


colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

s1=subplot(1,2,1);
hold on

% l3=plot(y3Dat,'');
period=0.01;
% % period=1;
xDat=(period:period:numel(y1Dat)*period);
xDatFilt=xDat(nX:end-nX);

l1=plot(xDat,y1Dat,'');
l2=plot(xDatFilt,y2Dat,'');
xlim([0,xDat(end)]);
% ylim([0.45 0.82])

% l1.LineWidth=1.5;
l2.LineWidth=3;
% l3.LineWidth=1.5;

% l1.Color=colorstring{1};
l2.Color=colorstring{2};
% l3.Color=colorstring{3};
% ylim([1.2 1.5])
% xlim([0,900])
% xlabel('Time [s]')
ylabel('Film probe [V]')
xlabel('Time [s]')
% title('Mixing zone passage')
grid on
box on
% legend('MPraw','Filtered','Location','southeast')
s1.YLabel.FontWeight='bold';
s1.XLabel.FontWeight='bold';
% 


s2=subplot(1,2,2);
hold on
box on
Fs=100;

x1=MP(6).MP1.var(1:23000);
x1=detrend(x1,'constant');


x2=MP(6).MP1.var(24000:25500);
x2=detrend(x2,'constant');


x3=MP(6).MP1.var(27000:end);
x3=detrend(x3,'constant');
[f1, P1]=plotFFT(x2,Fs);
[f2, P2]=plotFFT(x1,Fs);
[f3, P3]=plotFFT(x3,Fs);

l4=plot(f1,P1);
l5=plot(f2,P2); 
l6=plot(f3,P3); 
%title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('Frequency [Hz]')
ylabel('Single-sided spectrum FFT')
temp=xlim;
ylim([0 0.1])
xlim([10^-3 50])
% xlim(temp);
s2.YScale='log';
s2.XScale='log';

grid on
% legend('N2','MIX','He')
s2.YLabel.FontWeight='bold';
s2.XLabel.FontWeight='bold';
legend('Mixing','Condensing zone','NC plug')
%% save

print(h,'MP_contINJ-FFT-N2_4_2','-dmeta')
disp('Fertig')