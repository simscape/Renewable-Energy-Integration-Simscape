function plotAdmittanceDQdc(sysDC,sysQDC,f)
h1=bodeplot(sysDC,sysQDC,{f(1)*2*pi,f(end)*2*pi});
setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
legend('Y_Ddc','Y_Qdc','Location','best');
title('D and Q axis Transfer Admittances on DC bus disturbance');
figure;
subplot(2,2,1)
nichols(sysDC) % Nichols Chart for YQQ
ngrid
title('D to dc Transfer Admittance Nichols Chart');
subplot(2,2,2)
nichols(sysQDC) % Nichols Chart for YQD
title('Q to dc Admittance Nichols Chart');
ngrid
subplot(2,2,3)
pzplot(sysDC) % Eigen plot for YQQ
title('D dc axis Poles and Zeros');
subplot(2,2,4)
pzplot(sysQDC) % Eigen plot for YQD
title('Q dc axis Poles and Zeros');
end