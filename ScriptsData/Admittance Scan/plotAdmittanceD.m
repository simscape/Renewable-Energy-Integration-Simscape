function plotAdmittanceD(sysDD,sysDQ,f)
h1=bodeplot(sysDD,sysDQ,{f(1)*2*pi,f(end)*2*pi}); % Bode plot
setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
legend('Y_DD','Y_DQ','Location','best');
title('D axis Admittances');
figure;
subplot(2,2,1)
nichols(sysDD)
ngrid
title('DD axis Admittance Nichols Chart'); % Nichols Chart for YDD
subplot(2,2,2)
nichols(sysDQ)
title('DQ axis Admittance Nichols Chart'); % Nichols Chart for YDQ
ngrid
subplot(2,2,3)
pzplot(sysDD)
title('DD axis Poles and Zeros'); % Eigen plot for YDD
subplot(2,2,4)
pzplot(sysDQ)
title('DQ axis Poles and Zeros'); % Eigen plot for YDD
end