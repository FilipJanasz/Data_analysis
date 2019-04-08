clc
clear name feedRate avgFeedRate
h=figure;
hold on

for n=2:numel(steam)
    feedRate{n-1}=movmean(steam(n).contInj.NCfeed(10:end-10),10);
    avgFeedRate(1,n-1)=min(feedRate{n-1});
    avgFeedRate(2,n-1)=mean(feedRate{n-1});
    avgFeedRate(3,n-1)=max(feedRate{n-1});
    
    plot(feedRate{n-1})
    name{n-1}=file(n).name;
end

legend(name,'interpreter','none')

avgFeedRate