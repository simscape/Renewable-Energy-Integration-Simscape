% Generalized Nyquist Plot: Eigenvalue Analysis
% Frequency range
function eigL = generalizedNyquistPlot(L1,w)
% Evaluate L(jw)
Ljw = freqresp(L1, w); % Complex array

% Preallocate
eigL = zeros(2, length(w));

% Loop over each frequency point
for k = 1:length(w)
    eigL(:,k) = eig(Ljw(:,:,k)); % Compute eigenvalues
end

% Plot all eigenvalues on the same Nyquist plot
figure("Name","GNYQUIST"); hold on;
colors = lines(2); % Color vector for plots

for i = 1:2
    plot(real(eigL(i,:)), imag(eigL(i,:)), 'Color', colors(i,:), 'LineWidth', 1.4); % Plotting eigenvalues 
end

% Mark -1 point
plot(-1, 0, 'r+', 'MarkerSize', 4, 'LineWidth', 2);

% Add unit circle
theta = linspace(0, 2*pi, 100); % Angle for unit circle
unit_circle_x = cos(theta); % x-coordinates of unit circle
unit_circle_y = sin(theta); % y-coordinates of unit circle
plot(unit_circle_x, unit_circle_y, 'k--', 'LineWidth', 1, 'DisplayName', 'Unit Circle'); % Plot unit circle as dashed black line

title('Generalized Nyquist Plot: Eigenvalues of L(jω)');
xlabel('Re'); ylabel('Im'); grid on; axis equal;

% Compute magnitudes of eigenvalues
mag_eigL = abs(eigL); % 2 x length(w) matrix: magnitudes of eigenvalues λ₁ and λ₂

% Find exact intersections with the unit circle using interpolation
crossing_freqs = cell(1, 2); % Store intersection frequencies for each eigenvalue
crossing_points = cell(1, 2); % Store intersection points (complex values) for each eigenvalue
for i = 1:2
    mag_diff = mag_eigL(i,:) - 1; % Difference from unit circle (|λ_i| - 1)
    crossing_freq = []; % Frequencies at crossings
    crossing_point = []; % Eigenvalue at crossings
    
    % Detect crossings by sign changes in (|λ_i| - 1)
    for k = 1:(length(w)-1)
        if (mag_diff(k) * mag_diff(k+1) < 0) % Sign change indicates a crossing
            % Linear interpolation to find the exact frequency of intersection
            fraction = abs(mag_diff(k)) / (abs(mag_diff(k)) + abs(mag_diff(k+1)));
            w_interp = w(k) + fraction * (w(k+1) - w(k)); % Interpolated frequency (rad/s)
            f_interp = w_interp / (2*pi); % Convert to Hz
            
            % Interpolate the eigenvalue at the crossing point
            eig_interp = eigL(i,k) + fraction * (eigL(i,k+1) - eigL(i,k));
            
            % Store the crossing frequency and point
            crossing_freq = [crossing_freq, f_interp];
            crossing_point = [crossing_point, eig_interp];
        end
    end
    
    crossing_freqs{i} = crossing_freq;
    crossing_points{i} = crossing_point;
end

% Plot markers and add frequency labels at exact intersection points
marker_styles = {'x', 'o'}; % Different marker styles for λ₁ and λ₂
marker_colors = ['b', 'r']; % Different colors for λ₁ and λ₂

for i = 1:2
    freqs = crossing_freqs{i};
    points = crossing_points{i};
    for k = 1:length(freqs)
        % Plot marker at intersection point
        plot(real(points(k)), imag(points(k)), marker_styles{i}, ...
             'MarkerSize', 4, 'MarkerEdgeColor', marker_colors(i), 'MarkerFaceColor', 'none');
        % Add frequency label
        text(real(points(k)), imag(points(k)), ['  ', sprintf('%.1f Hz', freqs(k))], ...
             'Color', marker_colors(i), 'FontSize', 8);
    end
end

% Find the point closest to -1 + 0j for each eigenvalue
closest_freqs = zeros(1, 2); % Frequencies of closest points
closest_points = zeros(1, 2, 'like', 1i); % Closest points (complex values)
closest_distances = zeros(1, 2); % Distances to -1 + 0j
for i = 1:2
    % Compute distances from -1 + 0j
    distances = abs(eigL(i,:) - (-1 + 0j));
    [min_dist, idx] = min(distances); % Find minimum distance and its index
    
    % Store the closest point, frequency, and distance
    closest_freqs(i) = w(idx) / (2*pi); % Convert to Hz
    closest_points(i) = eigL(i,idx);
    closest_distances(i) = min_dist;
end

% Plot markers and add labels for the closest points
closest_markers = {'s', 'd'}; % Square for λ₁, diamond for λ₂
for i = 1:2
    % Plot marker at closest point
    plot(real(closest_points(i)), imag(closest_points(i)), closest_markers{i}, ...
         'MarkerSize', 6, 'MarkerEdgeColor', marker_colors(i), 'MarkerFaceColor', 'none');
    % Add label with frequency and distance
    text(real(closest_points(i)), imag(closest_points(i)), ...
         ['  ', sprintf('%.1f Hz, d=%.3f', closest_freqs(i), closest_distances(i))], ...
         'Color', marker_colors(i), 'FontSize', 8);
end

% Add legend
legend({'λ₁', 'λ₂', '-1 point', 'Unit Circle'}, 'Location', 'bestoutside');

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