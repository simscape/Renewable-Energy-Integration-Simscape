function generalizedNyquistPlotwithCrossing(sys, w)
% Generalized Nyquist plot with:
%  - True unit circle crossings
%  - Phase margin annotations
%  - Symmetric frequency sweep (to close loop)
%  - Marker at point closest to critical point -1

% Step 1: Frequency vector setup
if nargin < 2
    w_pos = logspace(-1, 3, 1000);  % Positive frequencies
    w = [-fliplr(w_pos), w_pos];    % Full contour: negative + positive
end

% Step 2: Initialize plot
figure;
hold on; grid on; axis equal;
title('Generalized Nyquist Plot with Stability Markers');
xlabel('Re'); ylabel('Im');

% Unit circle
theta = linspace(0, 2*pi, 500);
plot(cos(theta), sin(theta), 'k--', 'LineWidth', 1.2);

cmap = parula(length(w));
crossings = [];   % [Re, Im, ω, PM]
closestPoint = []; % [distance, Re, Im, ω]

prevAbsEig = [];

% Step 3: Loop over frequencies
for k = 1:length(w)
    % Frequency response of L(jw)
    Lw = squeeze(freqresp(sys, w(k)));
    eigvals = eig(Lw);
    absEig = abs(eigvals);

    % Detect true crossings
    if ~isempty(prevAbsEig)
        for i = 1:length(eigvals)
            if i <= length(prevAbsEig)
                crossed = (prevAbsEig(i) < 1 && absEig(i) >= 1) || ...
                    (prevAbsEig(i) > 1 && absEig(i) <= 1);
                if crossed
                    % Phase margin relative to -1
                    angleDeg = rad2deg(angle(eigvals(i)));
                    pm = 180 + angleDeg;

                    % Mark crossing
                    plot(real(eigvals(i)), imag(eigvals(i)), 'ro', 'MarkerSize', 6, 'LineWidth', 1.5);
                    text(real(eigvals(i)) + 0.02, imag(eigvals(i)), ...
                        sprintf('\\omega = %.2f rad/s\nPM = %.1f°', w(k), pm), ...
                        'FontSize', 8, 'Color', 'r');
                    crossings(end+1,:) = [real(eigvals(i)), imag(eigvals(i)), w(k), pm];
                end
            end
        end
    end

    % Check distance to critical point (-1 + j0)
    for i = 1:length(eigvals)
        dist = abs(eigvals(i) + 1);  % Distance to -1
        if isempty(closestPoint) || dist < closestPoint(1)
            closestPoint = [dist, real(eigvals(i)), imag(eigvals(i)), w(k)];
        end
    end

    % Plot eigenvalue trajectory
    plot(real(eigvals), imag(eigvals), '.', 'Color', cmap(min(k,length(cmap)), :), 'MarkerSize', 6);
    prevAbsEig = absEig;
end

% Step 4: Display results
if ~isempty(crossings)
    disp('Unit circle crossings detected at:');
    for i = 1:size(crossings,1)
        fprintf('  - ω = %.3f Hz | Eigenvalue = (%.3f + %.3fj) | PM = %.2f°\n', ...
            crossings(i,3)/(2*pi), crossings(i,1), crossings(i,2), crossings(i,4));
    end
else
    disp('No true unit circle crossings detected.');
end

% Mark closest point to -1
if ~isempty(closestPoint)
    plot(closestPoint(2), closestPoint(3), 'md', 'MarkerSize', 8, 'LineWidth', 2); % magenta diamond
    text(closestPoint(2) + 0.02, closestPoint(3), ...
        sprintf('Closest to -1\n\\omega = %.2f rad/s', closestPoint(4)), ...
        'Color', 'm', 'FontSize', 8);
    fprintf('Closest point to -1 found at ω = %.3f Hz | Eigenvalue = (%.3f + %.3fj)\n', ...
        closestPoint(4)/(2*pi), closestPoint(2), closestPoint(3));
end

% Colorbar for frequency
colormap(cmap);
colorbar('Ticks', linspace(0,1,5), ...
    'TickLabels', arrayfun(@(f) sprintf('%.1f', f), ...
    logspace(log10(abs(w(1))), log10(abs(w(end))), 5), 'UniformOutput', false));
end
