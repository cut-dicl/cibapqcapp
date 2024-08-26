function [x1]=mainplot(BT, BP, pTime, LoS, algo)

% 
%Plot1                  % places of ships (Solution by GA) 
figure
for i=1:length(BT)
x1=BT(i);
x2=BT(i)+pTime(i);
y1=BP(i)+LoS(i);
y2=BP(i);
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
plot(x, y, 'r-', 'LineWidth', 1);
txt=[int2str(i)];
text((x1+x2)/2,(y1+y2)/2,txt)
hold on;
%xlim([0, 336*2]); %336 for one week
xlabel('Time (30-min interval)');
ylabel('Wharf length = 800m');
if algo==1; title ('Berth allocation by PSO');
elseif algo==2; title ('Berth allocation by GA');
elseif algo==4; title ('Berth allocation by FCFS');
elseif algo==3; title ('Berth allocation by CSA'); end;
box on;
grid on;
end
set(gca,'YTick',[0 450 1250 1730 2500 2930],'YTickLabel',...
     {'0', '450','800','480','770','430'});
hold off;