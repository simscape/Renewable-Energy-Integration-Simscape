function plotAdmittanceDC(sysDC,f)
h1=bodeplot(sysDC,{f(1)*2*pi,f(end)*2*pi}); % Bode plot
setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
legend('Y_DC','Location','best');
title('DC Admittances');
figure;
subplot(2,1,1)
nichols(sysDC)
ngrid
title('Admittance Nichols Chart'); % Nichols Chart for YDD
subplot(2,1,2)
pzplot(sysDC)
title('Poles and Zeros'); % Eigen plot for YDD
end