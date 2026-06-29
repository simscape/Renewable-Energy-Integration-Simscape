function bodeDeterminant(eigL, w,scan)
% Compute the scalar determinant of (I + L(jω))
% --- Eigenvalue product method
detL = prod(1 + eigL, 1);  % Row vector (1 x N)
f = w / (2*pi); % Frequency vector in Hz

% Magnitude and phase
mag = abs(detL);
phase_deg = angle(detL) * (180/pi);

% Plot
figure;
subplot(2,1,1);
semilogx(f, mag, 'b', 'LineWidth', 1.5); grid on;
ylabel('|det(I+L)|');
title('Plot of det(I + L(j\omega))');
xlim([scan.f(1) scan.f(end)]);
subplot(2,1,2);
semilogx(f, phase_deg, 'r', 'LineWidth', 1.5); grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (deg)');
xlim([scan.f(1) scan.f(end)]);
end