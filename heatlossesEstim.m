f1='press';
f2='N2_molefraction';
f3='mflow';

for n=1:numel(steam)
    x(n)=steam(n).(f1).value;
    y(n)=NC(n).(f2).value;
    z(n)=steam(n).(f3).value;
end
filtr=find(isnan(z));
x(filtr)=[];
y(filtr)=[];
z(filtr)=[];
% y=y-min(y);
% filtr2=find(y<0);
% x(filtr2)=[];
% y(filtr2)=[];
% z(filtr2)=[];

filtr2=find(y<0.12);

figure
scatter(x(filtr2),z(filtr2),40,y(filtr2),'Filled','o')
xlabel(f1)
ylabel(f3)
grid on
% 
% figure
% hold on
% h=plot3(x,y,z,'.');
% h2=plot3(x(1:8),y(1:8),z(1:8),'o');
% h.MarkerSize=12;
% h2.MarkerSize=6;
% xlabel(f1)
% ylabel(f2)
% zlabel(f3)
% grid on
% 
% figure
% fitresult = fit([x',y'],z','poly22');
% hh = plot( fitresult, [x', y'], z' );
% argX=45-atand(x./y);
% % argX(argX<0)=argX(argX<0)+00;
% xx=(sqrt(x.^2+y.^2)).*sind(argX);
% figure
% plot(xx,z,'.')

% ang=-48;
% rotmat=[cosd(ang),-sind(ang);-sind(ang),cosd(ang)];
% % for n=1:numel(x)
% for n=1:numel(x)
%     temp=[x(n),y(n)]*rotmat;
%     xBis(n)=temp(1);
%     yBis(n)=temp(2);
% end
% 
% % nn=5
% % vec1=[x(nn),y(nn)];
% % vec2=[xBis(nn),yBis(nn)];
% % figure
% % hold on
% % plot([0,vec1(1)],[0,vec1(2)])
% % plot([0,vec1(1)],[0,vec1(2)],'.')
% % plot([0,vec2(1)],[0,vec2(2)])
% % plot([0,vec2(1)],[0,vec2(2)],'.')
% 
%  aa=figure;
%  
% %  subplot(2,1,1)
%  h=plot(xBis,z,'.');
%  h.MarkerSize=12;
%  title(num2str(ang));
% %  xlim([0 2000])
% %  subplot(2,1,2)
% % %  figure
% %  h=plot(yBis,z,'.');
% %  h.MarkerSize=12;
% %  aa.Position=[280   200   860   720];