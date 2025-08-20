function plotAdmittanceDCq(sysDCq,f)
h1=bodeplot(sysDCq,{f(1)*2*pi,f(end)*2*pi}); % Bode plot
setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
legend('Y_{qDC}','Location','best');
title('DC Transfer Admittances on Q axis Disturbance');
figure;
subplot(2,1,1)
nichols(sysDCq)
ngrid
title('Admittance Nichols Chart'); % Nichols Chart for YDD
subplot(2,1,2)
pzplot(sysDCq)
title('Poles and Zeros'); % Eigen plot for YDD
end