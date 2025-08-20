function plotAdmittanceDCd(sysDCd,f)
h1=bodeplot(sysDCd,{f(1)*2*pi,f(end)*2*pi}); % Bode plot
setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
legend('Y_{dDC}','Location','best');
title('DC Transfer Admittances on D axis Disturbance');
figure;
subplot(2,1,1)
nichols(sysDCd)
ngrid
title('Admittance Nichols Chart'); % Nichols Chart for YDD
subplot(2,1,2)
pzplot(sysDCd)
title('Poles and Zeros'); % Eigen plot for YDD
end