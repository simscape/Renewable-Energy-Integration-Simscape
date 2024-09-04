%% This file plots the THD for the simulation
% Copyright 2022 - 2023 The MathWorks, Inc.
figure;
tsI.data=simlog2.get('ITHD').Values.Data;
tsI.time=simlog2.get('ITHD').Values.Time;
tsV.data=simlog2.get('VTHD').Values.Data;
tsV.time=simlog2.get('VTHD').Values.Time;
maxITHD=max(tsI.data(10e3:end)); % start THD calculation from 1 sec
maxVTHD=max(tsV.data(10e3:end)); % start THD calculation from 1 sec
hb=bar([5,maxITHD;8,maxVTHD]);
xticks={'Current THD','Voltage THD'};
DesignTest={'IEEE Recommended Maximum THD','Maximum THD for Simulated Model'};
ylabel('% THD');
xticklabels(xticks);
hLg=legend(DesignTest,'Location','northwest');
%% 
% Copyright 2022 The MathWorks Inc