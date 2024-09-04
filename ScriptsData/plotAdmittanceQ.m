function plotAdmittanceQ(sysQQ,sysQD,f)
h1=bodeplot(sysQQ,sysQD,{f(1)*2*pi,f(end)*2*pi});
setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
legend('Y_QQ','Y_QD','Location','best');
title('Q axis Admittances');
figure;
subplot(2,2,1)
nichols(sysQQ) % Nichols Chart for YQQ
ngrid
title('QQ axis Admittance Nichols Chart');
subplot(2,2,2)
nichols(sysQD) % Nichols Chart for YQD
title('QD axis Admittance Nichols Chart');
ngrid
subplot(2,2,3)
pzplot(sysQQ) % Eigen plot for YQQ
title('QQ axis Poles and Zeros');
subplot(2,2,4)
pzplot(sysQD) % Eigen plot for YQD
title('QD axis Poles and Zeros');
end