% Determinant Plot for Scalar Check
% Frequency response of L (2x2xN)
function computeDet(L1,w)
Ljw = freqresp(L1, w);  % size: 2x2xN

% Compute det(I + L(jw)) manually at each frequency
detL = zeros(1, length(w));



% Plot the determinant trajectory
figure;
plot(real(detL), imag(detL), 'b', 'LineWidth', 1.5); hold on;
plot(0, 0, 'rx', 'MarkerSize', 5, 'LineWidth', 2);

% Find the point closest to (0, 0)
distances = abs(detL); % Distance from (0, 0) = |det(I + L(jω))|
[min_dist, idx] = min(distances); % Find minimum distance and its index
closest_freq = w(idx) / (2*pi); % Convert to Hz
closest_point = detL(idx); % Value of det(I + L(jω)) at closest point

% Plot marker and add label for the closest point
plot(real(closest_point), imag(closest_point), 'o', ...
     'MarkerSize', 6, 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'none');
text(real(closest_point), imag(closest_point), ...
     ['  ', sprintf('%.1f Hz', closest_freq, min_dist)], ...
     'Color', 'g', 'FontSize', 8);

xlabel('Re'); ylabel('Im'); grid on; axis equal;
title('Nyquist Plot of det(I + L(j\omega)) (Freqresp Method)');
end