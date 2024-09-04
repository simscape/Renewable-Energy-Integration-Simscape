%% This function performs the FFT for an input signal during a disturbance
function fFTPower(Scan,out,Time)
Fs = Scan.samplingfrequency; % Sampling frequency                     
Pf=(out.get('S').Data((Time-0.1)*Fs:(Time+0.8)*Fs));% Extract apperent power S
P=(out.get('P').Data((Time-0.1)*Fs:(Time+0.8)*Fs));% Extract real power 
Q=(out.get('Q').Data((Time-0.1)*Fs:(Time+0.8)*Fs));% Extract reactive power
L = length(Pf); % Data size of S
F1 = fft(P/(L)); % FFT of P
F2 = fft(Q/(L)); % FFT of P
k=0:L/2; % Index for obtaining half of the spectrum
f=k*Fs/L; % Sampling frequencies
figure
subplot(1,3,2) % Plot FFT of Power
plot(f(2:1:round(1000*L/Fs)),abs(F1(2:1:round(1000*L/Fs)))/L/2)
xlabel('Hz');
ylabel('Mag');
title('FFT of Real Power');
grid on;
subplot(1,3,3) % Plot FFT of Power
plot(f(2:1:round(1000*L/Fs)),abs(F2(2:1:round(1000*L/Fs)))/L/2)
xlabel('Hz');
ylabel('Mag');
title('FFT of Reactive Power');
grid on;
subplot(1,3,1) % Plot Real Power
plot(out.get('S').Time((Time-0.1)*Fs:(Time+0.5)*Fs), 1e-6*squeeze(out.get('P').Data((Time-0.1)*Fs:(Time+0.5)*Fs)),'-', 'LineWidth', 1.5,'Color','#0072BD')
xlabel('Time (sec)');
ylabel('MVA');
title('Apperent Power');
grid on;
end