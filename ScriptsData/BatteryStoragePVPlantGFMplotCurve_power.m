function BatteryStoragePVPlantGFMplotCurve_power(simlog,n)
% Plots the real and reactive powers for the simulation
% Copyright 2022 - 2023 The MathWorks, Inc.
% Plot results
bx1=subplot(2,1,1)
plot(simlog.get('P_total').Values.Time(1:end), 10^-6*simlog.get('P_total').Values.Data(1:end),'-', 'LineWidth', 1.5,'Color','#0072BD')
hold on;
plot(simlog.get('P_bat').Values.Time(1:end), 10^-6*simlog.get('P_bat').Values.Data(1:end),'-', 'LineWidth', 1.5,'Color','#D95319')
plot(simlog.get('P_PV_park').Values.Time(1:end), 10^-6*simlog.get('P_PV_park').Values.Data(1:end),'-', 'LineWidth', 1.5,'Color','#EDB120')
grid on
xlabel('Time (sec)')
ylabel('MW')
legend('P Total','P Battery', 'P PV Plant')
xlim([0.6 3.5])
title('Real Power Output')
bx2=subplot(2,1,2)
plot(simlog.get('Q_total').Values.Time(1:end), 10^-6*simlog.get('Q_total').Values.Data(1:end),'-', 'LineWidth', 1.5,'Color','#0072BD');
hold on;
plot(simlog.get('Q_bat').Values.Time(1:end), 10^-6*simlog.get('Q_bat').Values.Data(1:end),'-', 'LineWidth', 1.5,'Color','#D95319');
plot(simlog.get('Q_PV_park').Values.Time(1:end), 10^-6*simlog.get('Q_PV_park').Values.Data(1:end),'-', 'LineWidth', 1.5,'Color','#EDB120')
grid on
xlabel('Time (sec)')
ylabel('MVAR')
legend('Q Total','Q Battery', 'Q PV Plant')
xlim([0.6 3.5])
title('Reactive Power Output')
linkaxes([bx1,bx2],'x');
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