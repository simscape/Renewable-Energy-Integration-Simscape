% Generalized Nyquist Plot: Eigenvalue Analysis
% Frequency range
function eigL = encirclementNyquistPlot(L1,w)
% Evaluate L(jw)
Ljw = freqresp(L1, w); % Complex array

% Preallocate
eigL = zeros(2, length(w));

% Loop over each frequency point
for k = 1:length(w)
    eigL(:,k) = eig(Ljw(:,:,k)); % Compute eigenvalues
end

% Calculating encirclement of critical point
eig1 = eigL(1,:);  % First eigenvalue
eig2 = eigL(2,:);  % Second eigenvalue
% For each eigenvalue separately:
% Reference critical point
crit_pt = -1 + 0j;

% Angle relative to -1
angle_rel_eig1 = unwrap(angle(eig1 - crit_pt));
angle_rel_eig2 = unwrap(angle(eig2 - crit_pt));

% Total phase change (radians)
delta_angle1 = angle_rel_eig1(end) - angle_rel_eig1(1);
delta_angle2 = angle_rel_eig2(end) - angle_rel_eig2(1);

% Calculate encirclement
N1 = round(delta_angle1 / (4*pi));
N2 = round(delta_angle2 / (4*pi));

% Display
disp(['Encirclements by eigenvalue λ₁: ', num2str(N1)]);
disp(['Encirclements by eigenvalue λ₂: ', num2str(N2)]);
end