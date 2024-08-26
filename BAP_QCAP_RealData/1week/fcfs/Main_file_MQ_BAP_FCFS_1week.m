close all
clear 
clc
AAAA = 'limassolMarch2019_4week.xlsx';  % calling the excell file for one week data
DataTable = readtable(AAAA,'Range','A1:M29');    %% reading the table from excell file 
%DataTable = readtable(AAAA,'Range','A1:M69');    %% FOR 2 WEEKS
%DataTable = readtable(AAAA,'Range','A1:M139');    %% reading the table from excell file 

costs = 'costs.xlsx';  % calling the cost file
costs = readtable(costs,'Range','A1:Z2'); 

HP=[20 25 25 25 25]; % HP is a average handling productivity of cranes installed at the Limassol Port [EUROGATE TERMINAL]
PBQ_name=DataTable.berthingQuay'; % preffered berthing quay
Load=DataTable.NRT'; %Load in tons
LoS=DataTable.vessellength'; % length of ship
LoS=LoS+10; % added 10 meters extra because of safety distance
PBQ_name=DataTable.berthingQuay'; % preffered berthing quay
% total quay 6.. 1. Container/ Ro-Ro Quay   2. East Quay    3. West Quay
% 4. Container Quay     5. North Quay   6. East south quay (but not in the current data)

% LENGTH of Quays
% The below 2 quays belong to Eurogate terminal.. length in meters
Length_C_roro_Quay=450; Length_Container_Quay=800;
% the below three quays belong to Dpworld terminal and they all have continuous berthing layout
Length_East_Quay=480; Length_West_Quay=770; % 450 and 320 
Length_North_Quay=430;
LoW=[Length_C_roro_Quay Length_Container_Quay Length_East_Quay Length_West_Quay Length_North_Quay];
[AT_30min, dep_30min, pTime]=dataModifiy(DataTable); % calling the function that calculates time values in 30-min time unit
%dep_30min=[47 64 76 223 236 89 80 84 140 177 176 144 166 232 229 236 284 243 270 285 271 275 279 316 311 295 325 327]; %this is new departure that is generated based on assigned cranes and their producticvity
data.AT=AT_30min; data.dep=dep_30min+2; data.pTime=pTime; data.LoS=LoS; data.PBQ_name=PBQ_name; data.Load=Load;
populationSize=100; noOfGeneration=100;
[PBQ ABQ PBP]=PBP_PBQ_function(LoS, PBQ_name, data.AT, LoW); % random population generation
% for 1 WEEK
%PBP=[240 1526 1814 1301 2044 138 1021 2553 31 520 1399 1764 162 2292 2690 1463 96 2818 575 269 1765 2628 1843 1457 635 1949 2136 2507];
% for 2 WEEKS
%PBP=[178 1571 2253 1289 1887 169 456 2504 121 642 1391 1966 197 2083 2720 1440 35 2736 875 252 2022 2768 2062 1552 935 2274 2044 2714 32 578 2323 106 2599 1785 764 2339 162 1799 1942 2738 2268 1375 208 2259 1829 1342 2010 2515 188 522 2111 893 253 2393 1265 2772 2061 2706 226 1440 2260 782 1342 2538 114 2553 2178 1411];
% for 4 WEEKS
PBP = importdata('C:\Users\sheraz.aslam\Dropbox\00. Combined BAP and QCAP Journal\0. MATLAB code new 2 containers\4. four weeks with ABQ and QCAP_2CT\PBP.txt');

data.PBQ=PBQ; data.ABQ=ABQ; data.PBP=PBP;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               CALCULATING number of CONTAINERS per VESSEL 
[Total_containers]=container_calculation_2CT(PBQ_name,Load);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAXIMUM and MINIMUM CRANES calculation
[max_cranes]=max_cranes_calculation(Load,Total_containers);
data.max_cranes=max_cranes; % adding max cranes in data structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           OPTIMAL PROCESSING TIME CALCULATION
[Optimal_processing_time PBP possible_cranes_productivity cranes_numbers]=optimal_time_calculation_2CT(Load, max_cranes,HP,pTime,PBQ, PBP, LoS, LoW,PBQ_name,Total_containers);
%writematrix(Optimal_processing_time, "C:\Users\Sheraz\Downloads\Optimal_processing_time.txt"); 
% possible_cranes shows productivity of cranes. if crane 5 is used it will
% be 25. and if 4 and 5 are used, it will be 50 productivity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%% ALGO 4  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FCFS CODE HERE  %%%%%%%%%%%%%%%%%%%%%%%%%
algo=4; % this is First come first serve algorithm
tic
[BT_FCFS BP_FCFS BQ_FCFS] = FCFS(data, LoW, costs, Optimal_processing_time, possible_cranes_productivity, Load, Total_containers, cranes_numbers);
Time_FCFS=toc;
[x1]=mainplot(BT_FCFS, BP_FCFS, data.pTime, data.LoS, algo); % plot





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%writematrix(data.PBP, "D:\0.Research_work\0.processing work\00.Multi-quay BAP Journal\1. Journal MATLAB CODE\3. one month with ABQ\PBP.txt");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Storing results in tex files                            %

 writematrix(BT_FCFS, "C:\Users\sheraz.aslam\Dropbox\00. Combined BAP and QCAP Journal\0. MATLAB code new 2 containers\z.plots_2CT\fcfs4_results\BT_FCFS.txt"); 
 writematrix(BP_FCFS, "C:\Users\sheraz.aslam\Dropbox\00. Combined BAP and QCAP Journal\0. MATLAB code new 2 containers\z.plots_2CT\fcfs4_results\BP_FCFS.txt");
 writematrix(BQ_FCFS, "C:\Users\sheraz.aslam\Dropbox\00. Combined BAP and QCAP Journal\0. MATLAB code new 2 containers\z.plots_2CT\fcfs4_results\BQ_FCFS.txt");
 writematrix(Time_FCFS, "C:\Users\sheraz.aslam\Dropbox\00. Combined BAP and QCAP Journal\0. MATLAB code new 2 containers\z.plots_2CT\fcfs4_results\Time_FCFS.txt");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
