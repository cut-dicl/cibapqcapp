function [Cost pos PBQ_changed data]= fitnessfuction(data,x,LoW, iteration,iii,PBQ_changed,pTime_new)
departure=data.dep; AT=data.AT; LoS=data.LoS; PBQ=data.PBQ; pTime=pTime_new; ABQ=data.ABQ; PBP=data.PBP;
penalty0=0; penalty1=0; penalty2=0; penalty3=0; penalty4=0; penalty5_PBQ=0; penalty_SET=0;
ShipNo_BQChange=[]; xx=0; Ship_search_space_jump=[]; sum_ships=[];y=0;m=0;
lengthOfwharf=LoW;
BT=x(1:length(AT)); % for picking first values from x as berthing times
BP=x(length(BT)+1:length(BT)*2);  % for picking values from x as berthing positions
BQ=x(length(BT)*2+1:end-length(BT));
NC=x(length(BT)*3+1:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       avoiding berth assignment before ETA after ETD                 %
% requested departure time
for i=1:length(AT) 
    if BT(i)<AT(i) || BT(i)>departure(i)
        penalty0=penalty0+100000;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%           WAITING TIME and COST
WaitingTime=abs(BT-AT); % calculating waiting time
WaitingCost=sum(WaitingTime)*10; % waiting cost based on 20euro per hour




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%         NEW OVERLAPING AREA             %%%%%%%%%%%%%%%%
        for a=1:length(AT)
            for b=1:length(AT)
                 if a~=b
                    if BP(a)+LoS(a)>sum(LoW(1:PBQ(a))) %LoW(PBQ(a))
                        penalty1=penalty1+10000; % wharf length cross penalty
                    end
                    
             if (BP(b)>= BP(a) && BP(b) <= BP(a)+LoS(a)) || (BP(a)>= BP(b) && BP(a) <= BP(b)+LoS(b)) % (2) berthing position j greater ho BP i s and BP(j) agr lesser ho BP(I)+LoS(i). it is used to avoid overlaping
                if (BT(a)<=BT(b) && BT(a)+pTime(a)>BT(b)) || (BT(b)<=BT(a) && BT(b)+pTime(b)>BT(a))...
                        || (BT(a)>=BT(b) && BT(a)<BT(b)+pTime(b)) || (BT(b)>=BT(a) && BT(b)<BT(a)+pTime(a))
                    penalty2=penalty2+5000; %overlapping penalty
                            if iteration>1000 && iteration<1150 && iii==1 % && iii %&& a+b~=sum_ships
                               if   any(a+b==sum_ships)==false
                                    y=y+1; m=m+1;
                                    Ship_search_space_jump(y)=b;
                                    y=y+1;
                                    Ship_search_space_jump(y)=a;
                                    sum_ships(m)=a+b;
                                end
                            end    
                    
                        if iteration>1150 && PBQ(b)~=ABQ(b) && iii ==1 % 
                           xx=xx+1;
                           ShipNo_BQChange(xx)=b;
                        end
                end
            end
                 end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%
 if Ship_search_space_jump >=1
             [BT BP_jumped BQ]=Jump_places_overlapig(Ship_search_space_jump, iii,pTime, AT, ABQ, BQ, LoS, PBP, PBQ, BT, BP,lengthOfwharf);
             pos=[BT BP_jumped BQ NC];
             pTimeall(iii+1,:)=pTime_new;
 end
%[x1]=mainplot(BT, BP, data.pTime, data.LoS, 2); % plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  New Area for adjusting overlapping issue and modifying BQ and PBQ to ABQ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if ShipNo_BQChange>=1
       if rem(length(ShipNo_BQChange),2)==0
           for i=1:length(ShipNo_BQChange)
            if rem(i,2)==0   
                if any(ShipNo_BQChange(i)==PBQ_changed)==false % || PBQ_changed ==[] %==false % any(ShipNo_BQChange(1)~=PBQ_changed(1))==true %ShipNo_BQChange~=1......any(1)~=1==true
                if any(ShipNo_BQChange(i-1)==PBQ_changed)==false    
                    % b=randi([1,2]);            %[minnn, Index]=min(LoS(ShipNo_BQChange(1)), LoS(ShipNo_BQChange(2)));
                    pp=[ShipNo_BQChange(i-1) ShipNo_BQChange(i)]; %% pp contains two overlaping ships and one of them needs to change its BQ
                    [min_pTime, b]=min(pTime(pp)); % finding max time and location
                    BP(pp(b))= randi([sum(lengthOfwharf(1:ABQ(pp(b))-1)), sum(lengthOfwharf(1:ABQ(pp(b))))-LoS(pp(b))]);
                    BQ(pp(b))=ABQ(pp(b));
                    PBQ(pp(b))=ABQ(pp(b));
                    PBP(pp(b))= randi([sum(lengthOfwharf(1:ABQ(pp(b))-1)), sum(lengthOfwharf(1:ABQ(pp(b))))-LoS(pp(b))]); %BP(ShipNo_BQChange(b));
                    % adding new bp and bq in the population
                    pos=[BT BP BQ NC];
                    PBQ_changed=[PBQ_changed pp(b)];
                end
                end
            end
           end
       end
      end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   safety entrance time (SET) || avoid multiple entrance in single time      %
for i=1:length(AT) 
    for j=1:length(AT) 
        if j~=i
        if BT(i)==BT(j)
        penalty_SET=penalty_SET+10000;
        end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Preferred berthing quay and position penalty
for i=1:length(AT) 
if BQ(i)==ABQ(i) && ABQ(i)~=3 && ABQ(i)~=2 && ABQ(i)~=1 % if proposed quay is ABQ, a fixed penalty is added... PBQ 1, 2, 3 have no ABQ
    pen=5000;
elseif  BQ(i)==PBQ(i) % if proposed quay id preferred quay penalty maybe 0 or defined based on preferred berthing position
    pen=(abs(BP(i)-PBP(i)))*2;
else % if proposed quay is neither preferred not ABQ, an infinite penalty is added
    pen=100000;
    BQ(i)=randi([min(PBQ(i),ABQ(i)), max(PBQ(i),ABQ(i))]);
end
penalty3=penalty3+pen;
end


%%%%%%%%%%%%%%%%%%%%%%%%%% HANDLING time and costs

HandlingTime=sum(pTime);
HandlingCost=HandlingTime*5; % we have assumed 10eur per hour handling cost and here unit is for 30min

  
%       this area of code is used for checking early or late departures
lateDeparture=zeros(1,length(departure));
earlyDeparture=zeros(1,length(departure));
for i=1:length(departure)
lateDeparture(i)= (BT(i)+pTime(i))-departure(i);
if lateDeparture(i)<0 ; earlyDeparture(i)=abs(lateDeparture(i));  lateDeparture(i)=0; end
end
totalLateTime=sum(lateDeparture);
totalLateCost=totalLateTime*20;% intitially we assumed 20euro penallty against each late hour (LAST PART of EQUATION 1)
totalEarly=sum(earlyDeparture);

totalCompletionTime=(totalLateTime+sum(pTime)+penalty2);

fitness=1/totalCompletionTime;
Cost=WaitingCost+HandlingCost+penalty0+penalty3+totalLateCost+penalty1+penalty2+penalty4+penalty_SET;
if Ship_search_space_jump >=1
pos=[BT BP_jumped BQ NC];
else
pos=[BT BP BQ NC];
end
data.ABQ=ABQ;
data.PBQ=PBQ;
data.PBP=PBP;