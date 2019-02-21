f1='press';
f2='NC_molefraction';
f3='mflow';

clear x y z temp range goodX legendString
for n=1:numel(steam)
    x(n)=steam(n).(f1).value;
    y(n)=NC(n).(f2).value;
    z(n)=steam(n).(f3).value;
end
filtr=find(isnan(z));
x(filtr)=[];
y(filtr)=[];
z(filtr)=[];
% figure
% plot3(x,y,z,'b.')
% hold on
temp=[x',y',z'];
temp=sortrows(temp,2);
x=temp(:,1);
y=temp(:,2);
z=temp(:,3);
% figure
% scatter(x,z,40,y,'Filled','o')


% plot3(x,y,z,'ro')
% y=y-min(y);
% filtr2=find(y<0);
% x(filtr2)=[];
% y(filtr2)=[];
% z(filtr2)=[];

width=0.008;
% figure
% hold on
m=1;
for n=1:numel(x)
    curr=y(n);
    if n>1
        if ~(curr==previous)
            lower=find(y>=(curr-width));
            upper=find(y<=(curr+width));
            range{n}=intersect(lower,upper);

            if numel(range{n})>2
                figure
        %         figure
                goodX{m}=x(range{n});
                goodY{m}=z(range{n});
%                 issorted(goodY{m})
                temp2=[goodX{m},goodY{m}];
                temp2=sortrows(temp2);
                goodX{m}=temp2(:,1);
                goodY{m}=temp2(:,2);
                h=plot(goodX{m},goodY{m},'.-');
                h.LineWidth=1.5;
                h.MarkerSize=12;
                legendString{m}=num2str(curr);
                m=m+1;  
                grid on
                legend(num2str(curr),'Location','eastoutside');
            end
        end
    end
    previous=curr;
end
% 
% yRnd=round(y,2);
% yUn=unique(yRnd);
% 
% figure
% hold on
% m=1;
% for n=1:numel(yUn)
%     currInd=find(yRnd==yUn(n));
%     if numel(currInd)>2
%                 goodX{m}=x(currInd);
%                 goodY{m}=z(currInd);
% %                 issorted(goodY{m})
%                 temp2=[goodX{m},goodY{m}];
%                 temp2=sortrows(temp2);
%                 goodX{m}=temp2(:,1);
%                 goodY{m}=temp2(:,2);
%                 h=plot(goodX{m},goodY{m},'.-');
%         h.LineWidth=1.5;
%         h.MarkerSize=12;
%         legendString{m}=num2str(yUn(n));
%         m=m+1;
%     end
% end
% grid on
% legend(legendString,'Location','eastoutside');