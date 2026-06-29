function generalizedNyquistPlotwithCrossing(sys, w)
% Generalized Nyquist plot with:
%  - Eigenvalue tracking across frequency steps
%  - Interpolated unit circle crossings
%  - Phase margin annotations
%  - Symmetric frequency sweep (to close loop)
%  - Marker at point closest to critical point -1
%  - Encirclement count of -1
%  - Detailed crossing table with sequence classification
%  - Highlighted minimum phase margin crossing

% Step 1: Frequency vector setup
if nargin < 2
    w_pos = logspace(-1, 3, 1000);  % Positive frequencies
    w = [-fliplr(w_pos), w_pos];    % Full contour: negative + positive
end

nFreq = length(w);

% Step 2: Vectorized frequency response (avoid per-frequency freqresp calls)
Ljw = freqresp(sys, w);  % n x n x nFreq
nEig = size(Ljw, 1);

% Step 3: Compute eigenvalues with tracking to prevent swapping
eigL = zeros(nEig, nFreq);
eigL(:,1) = eig(Ljw(:,:,1));

for k = 2:nFreq
    eigCurr = eig(Ljw(:,:,k));
    eigL(:,k) = trackEigenvalues(eigL(:,k-1), eigCurr);
end

% Step 4: Initialize plot
figure;
hold on; grid on; axis equal;
title('Generalized Nyquist Plot with Stability Markers');
xlabel('Re'); ylabel('Im');

% Unit circle
theta = linspace(0, 2*pi, 500);
plot(cos(theta), sin(theta), 'k--', 'LineWidth', 1.2);

% Plot eigenvalue trajectories
cmap = parula(nFreq);
for i = 1:nEig
    scatter(real(eigL(i,:)), imag(eigL(i,:)), 6, 1:nFreq, 'filled');
end

% Step 5: Detect unit circle crossings with interpolation
% Columns: [Re, Im, w, PM, eigIndex]
crossings = zeros(0, 5);
magEig = abs(eigL);

for i = 1:nEig
    magDiff = magEig(i,:) - 1;
    for k = 1:(nFreq-1)
        if magDiff(k) * magDiff(k+1) < 0
            % Linear interpolation for exact crossing
            frac = abs(magDiff(k)) / (abs(magDiff(k)) + abs(magDiff(k+1)));
            w_cross = w(k) + frac * (w(k+1) - w(k));
            eig_cross = eigL(i,k) + frac * (eigL(i,k+1) - eigL(i,k));

            % Phase margin: angular distance from negative real axis
            angleDeg = rad2deg(angle(eig_cross));
            pm = 180 - abs(angleDeg);

            % Mark crossing (default red, will highlight min PM later)
            plot(real(eig_cross), imag(eig_cross), 'ro', 'MarkerSize', 6, 'LineWidth', 1.5);
            text(real(eig_cross) + 0.02, imag(eig_cross), ...
                sprintf('\\omega = %.2f rad/s\nPM = %.1f°', w_cross, pm), ...
                'FontSize', 8, 'Color', 'r');

            crossings(end+1,:) = [real(eig_cross), imag(eig_cross), w_cross, pm, i]; %#ok<AGROW>
        end
    end
end

% Step 6: Find closest point to -1 for each eigenvalue
closestPoint = [];
for i = 1:nEig
    distances = abs(eigL(i,:) + 1);
    [minDist, idx] = min(distances);
    if isempty(closestPoint) || minDist < closestPoint(1)
        closestPoint = [minDist, real(eigL(i,idx)), imag(eigL(i,idx)), w(idx)];
    end
end

% Step 7: Display results
displayCrossingReport(crossings, closestPoint);

% Highlight min PM crossing on plot
if ~isempty(crossings)
    [~, minIdx] = min(crossings(:,4));
    mc = crossings(minIdx,:);
    plot(mc(1), mc(2), 'gp', 'MarkerSize', 14, 'LineWidth', 2.5, 'MarkerFaceColor', 'g');
    text(mc(1) + 0.04, mc(2) - 0.06, ...
        sprintf('MIN PM = %.1f°\n%.2f Hz', mc(4), mc(3)/(2*pi)), ...
        'FontSize', 9, 'Color', [0 0.5 0], 'FontWeight', 'bold');
end

% Mark closest point to -1
if ~isempty(closestPoint)
    plot(closestPoint(2), closestPoint(3), 'md', 'MarkerSize', 8, 'LineWidth', 2);
    text(closestPoint(2) + 0.02, closestPoint(3), ...
        sprintf('Closest to -1\n\\omega = %.2f rad/s', closestPoint(4)), ...
        'Color', 'm', 'FontSize', 8);
end

% Step 8: Encirclement count of -1
crit_pt = -1 + 0j;
totalEncirclements = 0;
fprintf('\n');
for i = 1:nEig
    angleRel = unwrap(angle(eigL(i,:) - crit_pt));
    deltaAngle = angleRel(end) - angleRel(1);
    N_i = round(deltaAngle / (4*pi));
    fprintf('  Encirclements by eigenvalue lambda_%d: %d\n', i, N_i);
    totalEncirclements = totalEncirclements + N_i;
end
fprintf('  Total encirclements of -1: %d\n', totalEncirclements);

if totalEncirclements == 0
    fprintf('  >> STABLE (no encirclements)\n');
else
    fprintf('  >> WARNING: %d net encirclement(s) — check open-loop RHP poles\n', totalEncirclements);
end

% Step 9: Colorbar (use absolute frequency for labels)
colormap(parula);
w_abs = abs(w);
cb = colorbar;
cb.Label.String = 'Frequency (rad/s)';
cb.Ticks = linspace(0, 1, 5);
cb.TickLabels = arrayfun(@(f) sprintf('%.1f', f), ...
    logspace(log10(min(w_abs)), log10(max(w_abs)), 5), 'UniformOutput', false);

end

%% ---- Display Helper ----
function displayCrossingReport(crossings, closestPoint)

    divider = repmat('=', 1, 82);
    subline = repmat('-', 1, 82);
    header  = sprintf('  %-4s  %-11s  %-8s  %-22s  %-8s', ...
        'Eig', '|f| (Hz)', 'PM (deg)', 'Eigenvalue', 'Sequence');

    if isempty(crossings)
        fprintf('\n%s\n  No unit circle crossings detected.\n%s\n', divider, divider);
        return
    end

    % Split into positive and negative sequence
    posIdx = crossings(:,3) >= 0;
    negIdx = crossings(:,3) <  0;
    posC = crossings(posIdx,:);
    negC = crossings(negIdx,:);

    % Sort each group by ascending |frequency|
    if ~isempty(posC)
        [~, ord] = sort(abs(posC(:,3)));
        posC = posC(ord,:);
    end
    if ~isempty(negC)
        [~, ord] = sort(abs(negC(:,3)));
        negC = negC(ord,:);
    end

    % Find overall minimum PM
    [minPM, minIdx] = min(crossings(:,4));
    minCross = crossings(minIdx,:);

    % ---- Print Report ----
    fprintf('\n%s\n', divider);
    fprintf('  GENERALIZED NYQUIST — UNIT CIRCLE CROSSING REPORT\n');
    fprintf('%s\n', divider);

    % Positive-sequence table
    fprintf('\n  POSITIVE-SEQUENCE CROSSINGS (w >= 0)         Count: %d\n', size(posC,1));
    fprintf('  %s\n', subline(1:end-2));
    fprintf('%s\n', header);
    fprintf('  %s\n', subline(1:end-2));
    for i = 1:size(posC,1)
        marker = '';
        if posC(i,4) == minPM, marker = ' << MIN PM'; end
        fprintf('  l_%d   %9.3f   %7.2f   (%+7.3f %+7.3fj)   +ve seq%s\n', ...
            posC(i,5), posC(i,3)/(2*pi), posC(i,4), posC(i,1), posC(i,2), marker);
    end

    % Negative-sequence table
    fprintf('\n  NEGATIVE-SEQUENCE CROSSINGS (w < 0)          Count: %d\n', size(negC,1));
    fprintf('  %s\n', subline(1:end-2));
    fprintf('%s\n', header);
    fprintf('  %s\n', subline(1:end-2));
    for i = 1:size(negC,1)
        marker = '';
        if negC(i,4) == minPM, marker = ' << MIN PM'; end
        fprintf('  l_%d   %9.3f   %7.2f   (%+7.3f %+7.3fj)   -ve seq%s\n', ...
            negC(i,5), abs(negC(i,3))/(2*pi), negC(i,4), negC(i,1), negC(i,2), marker);
    end

    % ---- Summary ----
    fprintf('\n%s\n', divider);
    fprintf('  SUMMARY\n');
    fprintf('  %s\n', subline(1:end-2));

    % Closest point to -1
    if ~isempty(closestPoint)
        fprintf('  Closest to -1+0j : (%+.3f %+.3fj) at %.3f Hz  |  distance = %.4f\n', ...
            closestPoint(2), closestPoint(3), closestPoint(4)/(2*pi), closestPoint(1));
    end

    % Minimum PM
    if minCross(3) >= 0
        seqStr = '+ve seq';
    else
        seqStr = '-ve seq';
    end
    fprintf('  Min phase margin : %.2f deg at %.3f Hz [%s, l_%d]\n', ...
        minPM, abs(minCross(3))/(2*pi), seqStr, minCross(5));

    % Risk assessment
    if minPM < 15
        fprintf('  Risk             : *** CRITICAL — PM < 15 deg, near instability ***\n');
    elseif minPM < 30
        fprintf('  Risk             : ** MARGINAL — PM < 30 deg, insufficient damping **\n');
    elseif minPM < 45
        fprintf('  Risk             : * MODERATE — PM < 45 deg, adequate but limited *\n');
    else
        fprintf('  Risk             : OK — PM >= 45 deg, well-damped\n');
    end

    fprintf('%s\n', divider);
end

%% ---- Eigenvalue Tracker ----
function eigTracked = trackEigenvalues(prevEig, currEig)
% Match current eigenvalues to previous ones by minimum distance
    n = length(prevEig);
    used = false(n, 1);
    eigTracked = zeros(n, 1);

    for i = 1:n
        dists = abs(currEig - prevEig(i));
        dists(used) = inf;
        [~, idx] = min(dists);
        eigTracked(i) = currEig(idx);
        used(idx) = true;
    end
end
