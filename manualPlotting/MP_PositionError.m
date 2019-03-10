clc
file=5;
x=0.1:0.1:numel(MP(file).Pos.var)/10;
figure; plot(x,-MP(file).Pos.var)
hold on
plot(x,-MP(file).Pos.var,'.')
xlabel('Time [s]')
ylabel('Position [mm]')
xlim([355 400])