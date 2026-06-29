% Statespace model of the system
function participationMatrix(ssY,zeta)
[A,B,C,D] = dssdata(ssY);

% Eigenvalues and right eigenvectors
[V, Lambda] = eig(A);  % V: eigenvectors, Lambda: diag matrix of poles
modes = diag(Lambda);  % Eigenvalues = poles

% Left eigenvectors
W = inv(V);  % Or use W = V' if system is symmetric

% Participation matrix
P = abs(W .* V');  % Each element: |left_i * right_j| — contribution of state j to mode i

% Normalize rows
P = P ./ max(P, [], 2);
criticalIdx = find(zeta < 0.1);   % Threshold for low-damping modes

% Extract participation rows for critical modes
CriticalParticipation = P(criticalIdx, :);

% Plot as a heatmap
figure('Name', 'Participation Factors of Critical Modes', 'NumberTitle', 'off');
imagesc(CriticalParticipation);
colormap(gray);            
colorbar;
xlabel('State Index');
ylabel('Critical Mode Index');
title('Participation Factors (Low Damping Modes Only)');
end