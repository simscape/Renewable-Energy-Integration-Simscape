function plotEigLBode(w,eigL,scan)
figure('Name', 'Bode Plot of Eigenvalues of L(j\omega)', 'NumberTitle', 'off');
ax1 = subplot(2,1,1);
semilogx(w/(2*pi), 20*log10(abs(eigL)),'LineWidth', 1);
hold on;
yline(0, '--r', '0 dB', 'LabelVerticalAlignment', 'top');
grid on;
hold on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([scan.f(1) scan.f(end)]);
title('Magnitude of Eigenvalue of L(j\omega)');
legend(arrayfun(@(i) sprintf('\\lambda_%d', i), 1:2, 'UniformOutput', false), 'Location', 'best');
ax2 = subplot(2,1,2);
semilogx(w/(2*pi), (angle(eigL))*(180/pi),'LineWidth', 1);
hold on;
yline(-180, '--r', '-180^o', 'LabelVerticalAlignment', 'top');
yline(180, '--r', '180^o', 'LabelVerticalAlignment', 'bottom');
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (deg)');
xlim([scan.f(1) scan.f(end)]);
title('Phase of Eigenvalue of L(j\omega)');
linkaxes([ax1, ax2], 'x');
end