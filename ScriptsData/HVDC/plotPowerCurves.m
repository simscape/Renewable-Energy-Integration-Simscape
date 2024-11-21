figure;
plot(turbineRPMv,power2/1e6)
plot(turbineRPMv,power2/1e6),grid on;
xlabel('Turbine RPM'),ylabel('Power (MW)')
title('Wind Turbine Power Curves')

[maxPower,maxPowerRPM] = max(power2'/1e6);

hold on,plot(maxPowerRPM,maxPower,'r','LineWidth',2,'Marker','+')
labels=num2str([5:11].','wind:  %d m/sec');
legend(labels,'location','best');