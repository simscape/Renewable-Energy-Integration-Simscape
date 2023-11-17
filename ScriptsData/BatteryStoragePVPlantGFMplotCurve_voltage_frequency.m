function BatteryStoragePVPlantGFMplotCurve_voltage_frequency(simlog,n,SimulationTime)
% Plots the current, voltages, and frequency of the simulation
% Copyright 2022 - 2023 The MathWorks, Inc. 
ax1=subplot(2,2,1);
v=simlog.get('Vmag_pcc').Values.Data(1:end);
aboveLine = (v>1.1 | v<0.9);
% Create 2 copies of v
bottomLine = v;
topLine = v;
% Set the values you don't want to get drawn to nan
bottomLine(aboveLine) = NaN;
topLine(~aboveLine) = NaN;
grid on
xlabel('Time (sec)');
ylabel('V(PU)');
xlim([0.6 SimulationTime])
hold on;
plot(simlog.get('Vmag_pcc').Values.Time(1:end),bottomLine,simlog.get('Vmag_pcc').Values.Time(1:end),topLine,'LineWidth',1.5);
plot(simlog.get('Vmag_pcc').Values.Time(1:end),1.1*ones(size(simlog.get('Vmag_pcc').Values.Time(1:end))),'--g');
plot(simlog.get('Vmag_pcc').Values.Time(1:end),0.9*ones(size(simlog.get('Vmag_pcc').Values.Time(1:end))),'--g');
Vd=find(v(3e3:end)>1.1 | v(3e3:end)<0.9);
if(length(Vd)>0)
     lgd=legend('V_{mag}','V_{out of limit}','V_{limits}',Location='southeast'); 
else
    lgd=legend('V_{mag}','','V_{limits}',Location='southeast');
end
lgd.NumColumns = 1;
hold off;
title('Voltage Magnitude at POI');
ax2=subplot(2,2,2);
f=simlog.get('F_pcc').Values.Data(1:end);
aboveLine = (f>61.2 | f<58.8);
% Create 2 copies of f
bottomLine = f;
topLine = f;
% Set the values you don't want to get drawn to nan
bottomLine(aboveLine) = NaN;
topLine(~aboveLine) = NaN;
grid on
xlabel('Time (sec)');
ylabel('F(Hz)');
xlim([0.6 3.5])
hold on;
plot(simlog.get('F_pcc').Values.Time(1:end),bottomLine,simlog.get('F_pcc').Values.Time(1:end),topLine,'LineWidth',1.5);
plot(simlog.get('F_pcc').Values.Time(1:end),61.2*ones(size(simlog.get('F_pcc').Values.Time(1:end))),'--g');
plot(simlog.get('F_pcc').Values.Time(1:end),58.8*ones(size(simlog.get('F_pcc').Values.Time(1:end))),'--g');
fd=find(f(3e3:end)>1.1 | f(3e3:end)<0.9);
if(length(Vd)>0)
    lgd=legend('F','F_{out of limit}','F_{limits}',Location='northeast'); 
else
    lgd=legend('F','','F_{limits}',Location='northeast');
end
lgd.NumColumns = 1;
hold off;
title('Frequency at POI');
xlim([0.6 SimulationTime])
ax3=subplot(2,2,3);
plot(simlog.get('Vabc_pcc').Values.Time(1:end), simlog.get('Vabc_pcc').Values.Data,'-', 'LineWidth', 1);
grid on
xlabel('Time (sec)');
ylabel('V(PU)');
xlim([0.6 SimulationTime])
title('Voltages at POI');
ax4=subplot(2,2,4);
plot(simlog.get('Iabc_bat').Values.Time(1:end), simlog.get('Iabc_bat').Values.Data,'-', 'LineWidth', 1);
grid on
xlabel('Time (sec)');
ylabel('I(PU)');
xlim([0.6 SimulationTime])
title('BESS Inverter Currents');
linkaxes([ax1,ax2,ax3,ax4],'x');
switch n
    case 4
      x=' Temporary Fault';
    case 5
      x=' Permanent Fault';     
    case  2
      x=' Sudden Load Change';
    case 1
      x=' Sudden Change in PV power';
    case 3
      x=' Grid Outage';
    case 6
    x=' Steady Operation';
    otherwise
        x='';
end
sgtitle(strcat(x))
end