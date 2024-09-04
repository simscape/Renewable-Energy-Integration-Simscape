function WindFarmGFMControlplotCurvepower(simlog,n,Tsim)
% Plots the real and reactive powers for the simulation
% Copyright 2023 The MathWorks, Inc.
% Plot results
ax1=subplot(2,1,1);
plot(simlog.get('PTotal').Values.Time(1:end), 10^-6*squeeze(simlog.get('PTotal').Values.Data(1:end)),'-', 'LineWidth', 1.5,'Color','#0072BD')
hold on;
plot(simlog.get('P_GFM').Values.Time(1:end), 10^-6*squeeze(simlog.get('QTotal').Values.Data(1:end)),'-', 'LineWidth', 1.5,'Color','#D95319')
grid on
xlabel('Time (sec)')
ylabel('MW')
legend('P Total','Q Total')
xlim([0.6 Tsim])
title('Total Power Output')
ax2=subplot(2,1,2);
plot(simlog.get('QTotal').Values.Time(1:end), 10^-6*squeeze(simlog.get('P_GFM').Values.Data(1:end)),'-', 'LineWidth', 1.5,'Color','#0072BD');
hold on;
plot(simlog.get('Q_GFM').Values.Time(1:end), 10^-6*squeeze(simlog.get('Q_GFM').Values.Data(1:end)),'-', 'LineWidth', 1.5,'Color','#D95319');
grid on
xlabel('Time (sec)')
ylabel('MVAR')
legend('P GFM Wind','Q GFM Wind')
xlim([0.6 Tsim])
title('GFM Power Output')
linkaxes([ax1,ax2],'x');
switch n
    case 3
      x='Temporary Fault';
    case 5
      x='Tripping of Wind Generator';     
    case  2
      x='Sudden Load Change';
    case 1
      x='Sudden Change in Wind Power';
    case 4
      x='Grid Outage';
    case 6
    x='Steady Operation';
    otherwise
        x='';
end
sgtitle(strcat(x))
end