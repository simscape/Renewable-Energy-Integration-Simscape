classdef gridCodeComplianceChecker
%==========================================================================
% gridCodeComplianceChecker
% Copyright 2025 - 2026 The MathWorks, Inc.
%==========================================================================
% DESCRIPTION:
%   gridCodeComplianceChecker is a class-based framework for automated
%   verification of power system and renewable plant compliance with
%   selected grid code requirements. It evaluates measured signals at the
%   Point of Interconnection (POI) against voltage, frequency, harmonic,
%   fault ride-through, and reactive power capability limits defined by a
%   user-specified grid code structure.
%
%   The class is designed for post-processing of EMT or RMS simulation
%   results (e.g., Simscape, Simulink, PSCAD) as well as measured field data,
%   using either numeric arrays or MATLAB timeseries objects.
%
% SCOPE OF COMPLIANCE CHECKS:
%   - Steady-state voltage magnitude limits
%   - Steady-state frequency limits
%   - Harmonic distortion (THD and individual harmonics)
%   - Voltage ride-through (LVRT / OVRT) with active power recovery
%   - Frequency ride-through duration checks
%   - Active–reactive power (P–Q) capability compliance
%   - Reactive power–voltage (Q–V) capability compliance
%   - LVRT reactive current / power injection requirements
%
% INPUTS:
%   data      : Struct containing measured signals at the POI
%               Required fields:
%                 - Vmag  : Voltage magnitude (pu)
%                 - f     : Frequency (Hz)
%                 - Iabc  : Phase currents
%                 - Vabc  : Phase voltages
%                 - P     : Active power (pu)
%                 - Q     : Reactive power (pu)
%
%   gridCode  : Struct defining grid code limits and envelopes, including:
%                 - Voltage and frequency limits
%                 - Harmonic limits
%                 - LVRT / OVRT and frequency ride-through thresholds
%                 - Reactive power capability definitions
%
%   FNom      : Nominal system frequency (Hz)
%
% NAME-VALUE OPTIONS (Constructor):
%   'Fs'  : Sampling frequency (Hz) for numeric data
%   't1'  : Start time for analysis window (s)
%   't2'  : End time for analysis window (s)
%
% OUTPUTS:
%   results : Struct containing PASS/FAIL flags and metrics for each
%             compliance category, suitable for reporting and automation.
%
% DESIGN PHILOSOPHY:
%   - Focused on formal grid code compliance (pass/fail based on limits)
%   - Independent of specific standards (IEEE 2800, ENTSO-E, AEMO, CEA),
%     allowing use of representative or abstracted thresholds
%   - Compatible with DynamicSignalGenerator for reference-based testing
%   - Designed for batch testing, reporting, and regulatory documentation
%
% TYPICAL USAGE:
%   checker = gridCodeComplianceChecker(data, gridCode, 50, ...
%       "Fs", 1000, "t1", 1, "t2", 40);
%   checker = checker.checkVoltage() ...
%                     .checkFrequency() ...
%                     .checkVoltageRideThrough() ...
%                     .testPQCapability(reference);
%   checker.summaryTable();

    properties
        data       % Struct: Vmag, f, Iabc, Vabc, P, Q
        t          % Time vector
        Fs         % Sampling frequency
        FNom       % Nominal frequency
        VNom = 1   % Nominal voltage
        IRated = 1 % Rated current
        gridCode   % Struct of grid limits
        results    % Struct of PASS/FAIL results
    end

    methods
        %% Constructor
        function obj = gridCodeComplianceChecker(data, gridCode, F, opts)
            arguments
                data struct {mustHaveFields(data, {'Vmag','f','Iabc','Vabc','P','Q'})}
                gridCode struct {mustHaveValidGridCode(gridCode)}
                F (1,1) double {mustBePositive}
                opts.Fs double = []
                opts.t1 double = 0
                opts.t2 double = Inf
            end

            if isa(data.Vmag, 'timeseries')
                data = cropTimeseries(data, opts.t1, opts.t2);
                obj.t = data.Vmag.Time;
                obj.Fs = ifelse(isempty(opts.Fs), 1 / mean(diff(obj.t)), opts.Fs);
                data = extractTimeseriesData(data);
            else
                obj.Fs = opts.Fs;
                obj.t = (0:length(data.Vmag)-1) / obj.Fs;
            end

            mustBeValidData(data, length(obj.t));
            obj.data = data;
            obj.gridCode = gridCode;
            obj.FNom = F;

            obj.results = struct(...
                'Voltage', false, ...
                'Frequency', false, ...
                'Harmonics', false, ...
                'FRT', false, ...
                'FRT_Freq', false, ...
                'PQCapability', false, ...
                'QVCapability', false ...
                );

            obj.results.lvrtQInjection = struct( ...
                'pass', false, ...
                'details', 'Not tested');

        end

        %% Voltage Limit Compliance
        function obj = checkVoltage(obj)
            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
            end
            v = obj.data.Vmag;
            mask = v < obj.gridCode.voltage.min | v > obj.gridCode.voltage.max;
            obj.results.Voltage = all(~mask);
            reportResult('Voltage Compliance', obj.results.Voltage);
        end

        %% Frequency Limit Compliance
        function obj = checkFrequency(obj)
            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
            end
            f = obj.data.f;
            mask = f < obj.gridCode.frequency.min | f > obj.gridCode.frequency.max;
            obj.results.Frequency = all(~mask);
            reportResult('Frequency Compliance', obj.results.Frequency);
        end

        %% Harmonic Compliance
        function obj = checkHarmonics(obj)
            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
            end
            [THD_I, THD_V, pass] = plotHarmonicSpectrum(obj);
            obj.results.THD_I = THD_I;
            obj.results.THD_V = THD_V;
            obj.results.Harmonics = pass;
            fprintf('Maximum THD (Current): %.2f %% | Maximum THD (Voltage): %.2f %%\n', max(THD_I), max(THD_V));
            reportResult('Harmonics Compliance', obj.results.Harmonics);
        end

        %% Voltage Ride-Through with Power Recovery Check
        function obj = checkVoltageRideThrough(obj)
            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
            end
            v = obj.data.Vmag;
            P = obj.data.P;
            Q = obj.data.Q;
            frtPass = true;
            settling = round(1 * obj.Fs);
            idxStart = []; idxEnd = [];

            fprintf("\n[Voltage Ride-Through Test with Power Recovery]\n");

            % Loop through FRT thresholds
            for i = 1:size(obj.gridCode.lvrt, 1)
                limit = obj.gridCode.lvrt(i, 1);
                duration = obj.gridCode.lvrt(i, 2);

                mask = ifelse(limit > 1, v > limit, v < limit);
                faultIdx = find(mask);

                if isempty(faultIdx)
                    fprintf("✔ No violation @ %.2f pu\n", limit);
                    continue;
                end

                tDur = sum(mask) / obj.Fs;
                pass = tDur <= duration;
                idxStart = [idxStart faultIdx(1)];
                idxEnd   = [idxEnd faultIdx(end)];
                reportFRT('Voltage', limit, duration, tDur, pass);
            end

            % Power recovery check
            if isempty(idxStart) || isempty(idxEnd)
                obj.results.FRT = frtPass;
                return;
            end
            preIdx = max(idxStart(1) - round(0.3*obj.Fs), 1):idxStart(1);
            postStart = idxEnd(end) + settling;

            if postStart > length(v)
                fprintf('⚠ Not enough samples after fault to check power recovery.\n');
                obj.results.FRT = frtPass;
                return;
            end
            stable = find(v(postStart:end) > 0.98, 1, 'first');
            if isempty(stable)
                fprintf('⚠ Voltage did not recover above 0.98 pu.\n');
                obj.results.FRT = frtPass;
                return;
            end

            Ppre = mean(P(preIdx));
            Qpre = mean(Q(preIdx));
            idxAvg = postStart + stable;
            idxEnd = min(idxAvg + round(1*obj.Fs), length(P));

            Ppost = mean(P(idxAvg:idxEnd));
            Qpost = mean(Q(idxAvg:idxEnd));

            Ptol = abs(Ppost - Ppre) / max(abs(Ppre), 1e-3) * 100;
            Qtol = abs(Qpost - Qpre) / max(abs(Qpre), 1e-3) * 100;
            passPower = Ptol <= 5 && Qtol <= 5;
            symbolPQ = ifelse(passPower, '✔', '❌');

            fprintf('%s Power Recovery | P: %.3f → %.3f (%.1f%%), Q: %.3f → %.3f (%.1f%%)\n', ...
                symbolPQ, Ppre, Ppost, Ptol, Qpre, Qpost, Qtol);

            obj.results.FRT = frtPass && passPower;
        end

        %% Frequency Ride-Through Duration Only
        function obj = checkFrequencyRideThrough(obj)
            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
            end
            f = obj.data.f;
            frtFreqPass = true;

            fprintf("\n[Frequency Ride-Through Test]\n");

            for i = 1:size(obj.gridCode.frt_freq, 1)
                limit = obj.gridCode.frt_freq(i, 1);
                dur = obj.gridCode.frt_freq(i, 2);
                mask = ifelse(limit < obj.FNom, f < limit, f > limit);
                tDur = sum(mask) / obj.Fs;
                pass = tDur <= dur;
                frtFreqPass = frtFreqPass && pass;
                reportFRT('Frequency', limit, dur, tDur, pass);
            end
            obj.results.FRT_Freq = frtFreqPass;
        end

        %% PQ Capability Check using gridCode.reactive.Qlimits(P)
        function obj = testPQCapability(obj, reference)
            % TESTPQCAPABILITY Verifies compliance with PQ capability limits.
            %   This function checks whether the measured active (P) and reactive (Q)
            %   power signals lie within the capability limits defined by the grid code.
            %
            %   It uses the steps in referencePQ.P to identify stable operating points
            %   and performs the compliance check at each step.
            %
            %   Inputs:
            %       obj         - gridCodeComplianceChecker object (fully initialized)
            %       referencePQ - struct with fields:
            %                       referencePQ.P (timeseries or struct with .Data)
            %                       referencePQ.Q (not used but validated for structure)
            %
            %   Output:
            %       obj         - updated object with results.PQCapability field

            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
                reference DynamicSignalGenerator
            end

            % Extract measured active and reactive power signals
            Pmeas = obj.data.P;
            Qmeas = obj.data.Q;

            %----Re-sample-------
            t_resampled = obj.t(1):reference.dt:obj.t(end);
            P = interp1(obj.t, Pmeas, t_resampled, 'linear', 'extrap');
            Q = interp1(obj.t, Qmeas, t_resampled, 'linear', 'extrap');

            % Extract reference active power signal (used to detect step transitions)
            Pref = reference.PQcapability.P.Data;

            % Detect step changes in reference P (step where delta > threshold)
            dPref = abs([0; diff(Pref)]);
            stepIdx = [1; find(0.9 > dPref & dPref > 0.1)];

            % Flag for cumulative pass/fail
            passAll = true;
            fprintf("\n[PQ Capability Check — Based on Reference P Steps]\n");

            % Loop through all identified step intervals
            for i = 1:length(stepIdx)
                iStart = stepIdx(i);
                if i < length(stepIdx)
                    iEnd = stepIdx(i+1) - 1;
                else
                    iEnd = min(length(P), length(Pref));
                end

                % Average measured P and Q over the interval
                Pstep = mean(P(iStart:iEnd));
                Qstep = mean(Q(iStart:iEnd));

                % Get Q limits from grid code for this P
                Qlim = obj.gridCode.reactive.Qlimits(Pstep);
                Qmin = Qlim(1);
                Qmax = Qlim(2);

                % Check compliance within ± tolerance
                tol = 1e-3;
                if Qstep < (Qmin - tol) || Qstep > (Qmax + tol)
                    passAll = false;
                    fprintf('❌ Step %2d | P = %.3f, Q = %.3f → Outside [%.3f, %.3f]\n', ...
                        i, Pstep, Qstep, Qmin, Qmax);
                else
                    fprintf('✔ Step %2d | P = %.3f, Q = %.3f → Within limits\n', ...
                        i, Pstep, Qstep);
                end
            end

            % Store final result
            obj.results.PQCapability = passAll;
            reportResult('PQ Capability (Reference-Based)', passAll);
        end

        %% Q-V Capability Check using gridCode.reactive.VQcurve(V)
        function obj = testQVCapability(obj, reference)
            % TESTQVCAPABILITY Verifies Q-V capability compliance using step-based testing.
            %   This function checks whether the measured reactive power (Q) at different
            %   voltage levels (Vmag) lies within the capability envelope defined by
            %   the grid code's Q(V) function.
            %
            %   Inputs:
            %       obj         - gridCodeComplianceChecker object (fully initialized)
            %       referenceQV - struct with field:
            %                       referenceQV.Vmag (timeseries or struct with .Data)
            %
            %   Output:
            %       obj         - updated object with results.QVCapability field

            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
                reference DynamicSignalGenerator
            end

            % Extract measured voltage and reactive power signals
            Vmeas = obj.data.Vmag;
            Qmeas = obj.data.Q;

            %----Re-sample-------
            t_resampled = obj.t(1):reference.dt:obj.t(end);
            V = interp1(obj.t, Vmeas, t_resampled, 'linear', 'extrap');
            Q = interp1(obj.t, Qmeas, t_resampled, 'linear', 'extrap');

            % Initialize overall pass flag
            passAll = true;
            fprintf("\n[QV Capability Check — Based on Reference Voltage Steps]\n");

            % Loop through each voltage step interval
            for i = 1:(5e-1/reference.dt):length(V)

                Vstep = V(i);
                Qstep = Q(i);

                % Get Qmin and Qmax from grid code's VQcurve(V)
                [Qmin, Qmax] = obj.gridCode.reactive.VQcurve(Vstep);

                % Compliance check with small tolerance
                tol = 1e-3;
                if Qstep < (Qmin - tol) || Qstep > (Qmax + tol)
                    passAll = false;
                    fprintf('❌ Time %.1f | V = %.3f, Q = %.3f → Outside [%.3f, %.3f]\n', ...
                        t_resampled(i), Vstep, Qstep, Qmin, Qmax);
                else
                    fprintf('✔ Time %.1f | V = %.3f, Q = %.3f → Within limits\n', ...
                        t_resampled(i), Vstep, Qstep);
                end
            end

            % Store final result
            obj.results.QVCapability = passAll;
            reportResult('QV Capability (Reference-Based)', passAll);
        end

        %% PQ Capability Visualization
        function obj = plotPQCapabilityEnvelope(obj)
            % plotPQCapabilityEnvelope - Visualizes PQ operating points and the
            % allowable PQ capability envelope defined by the grid code limits.
            %
            % The grid code defines Q-limits as a function of P, and this plot
            % fills the area between Qmin(P) and Qmax(P) using a light green patch.

            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
            end

            % --- Extract operating data ---
            Pmeas = obj.data.P(:);
            Qmeas = obj.data.Q(:);

            %----Re-sample-------
            t_resampled = obj.t(1):0.01:obj.t(end);
            P = interp1(obj.t, Pmeas, t_resampled, 'linear', 'extrap');
            Q = interp1(obj.t, Qmeas, t_resampled, 'linear', 'extrap');

            % --- Define a range of P values for envelope ---
            Pgrid = linspace(min(Pmeas), max(Pmeas), 500);

            % --- Evaluate Q limits from the grid code for each P ---
            Qlims = arrayfun(@(P) obj.gridCode.reactive.Qlimits(P), Pgrid, 'UniformOutput', false);
            Qlims = cell2mat(Qlims');  % N×2: [Qmin, Qmax] for each P

            QminCurve = Qlims(:,1);
            QmaxCurve = Qlims(:,2);

            % --- Begin plotting ---
            figure('Name', 'PQ Capability Envelope (Grid Code)', 'NumberTitle', 'off');
            hold on; grid on; box on;

            % --- Fill allowed region (light green) ---
            fill([Pgrid fliplr(Pgrid)], ...
                [QminCurve' fliplr(QmaxCurve')], ...
                [0.8, 1.0, 0.8], 'EdgeColor', 'none', ...
                'DisplayName', 'Allowed PQ Region');

            % --- Plot measured PQ operating points ---
            scatter(P, Q, 10, 'b', 'filled', 'DisplayName', 'Measured PQ');

            % --- Overlay boundary lines ---
            plot(Pgrid, QminCurve, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Q_{min}(P)');
            plot(Pgrid, QmaxCurve, 'g--', 'LineWidth', 1.2, 'DisplayName', 'Q_{max}(P)');

            % --- Labels and formatting ---
            xlabel('Active Power (P, pu)', 'FontWeight', 'bold');
            ylabel('Reactive Power (Q, pu)', 'FontWeight', 'bold');
            title('PQ Capability Envelope Based on Grid Code');
            legend('Location', 'best');
            axis tight;
        end

        %% QV Capability Visualization
        function obj = plotQVCapabilityEnvelope(obj)
            % plotQVCapabilityEnvelope - Visualizes measured Q–V operating points
            % and overlays the allowed Q limits based on grid code's V–Q curve.
            %
            % The allowable Q region is shown as a light green filled patch.

            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
            end

            % --- Extract data ---
            Vmeas = obj.data.Vmag(:);
            Qmeas = obj.data.Q(:);

            %----Re-sample-------
            t_resampled = obj.t(1):0.01:obj.t(end);
            V = interp1(obj.t, Vmeas, t_resampled, 'linear', 'extrap');
            Q = interp1(obj.t, Qmeas, t_resampled, 'linear', 'extrap');

            % --- Define voltage range from data for plotting limits ---
            Vspan = linspace(min(Vmeas)*0.95, max(Vmeas)*1.05, 500);

            % --- Evaluate Q limits for each V using VQcurve ---
            for i=1:length(Vspan)
                [QminCurve(i), QmaxCurve(i)] = obj.gridCode.reactive.VQcurve(Vspan(i));
            end

            % --- Plot ---
            figure('Name', 'QV Capability Envelope (Grid Code)', 'NumberTitle', 'off');
            hold on; grid on; box on;

            % --- Fill allowed Q region (light green) ---
            fill([Vspan, fliplr(Vspan)], ...
                [QminCurve, fliplr(QmaxCurve)], ...
                [0.8, 1.0, 0.8], 'EdgeColor', 'none', ...
                'DisplayName', 'Allowed Q-V Region');

            % --- Plot actual operating points ---
            scatter(V, Q, 12, 'b', 'filled', 'DisplayName', 'Measured QV');

            % --- Overlay boundary curves ---
            plot(Vspan, QminCurve, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Q_{min}(V)');
            plot(Vspan, QmaxCurve, 'g--', 'LineWidth', 1.2, 'DisplayName', 'Q_{max}(V)');

            % --- Labels and formatting ---
            xlabel('Voltage Magnitude (V, pu)', 'FontWeight', 'bold');
            ylabel('Reactive Power (Q, pu)', 'FontWeight', 'bold');
            title('QV Capability Envelope Based on Grid Code');
            legend('Location', 'best');
            axis tight;
        end

        %% Summary Table
        function obj = summaryTable(obj)
            arguments
                obj gridCodeComplianceChecker
            end

            % Get all field names and values
            fields = fieldnames(obj.results);
            values = cellfun(@(f) obj.results.(f), fields, 'UniformOutput', false);

            % Filter only logical scalars
            isLogical = cellfun(@(x) islogical(x) && isscalar(x), values);
            fields = fields(isLogical);
            values = values(isLogical);

            % Apply ✔ or ❌ for each logical value
            symbols = cellfun(@(x) ifelse(x, '✅', '❌'), values, 'UniformOutput', false);

            % Display summary table
            T = table(fields, symbols, 'VariableNames', {'Category','Compliance'});
            disp('--- Grid Code Compliance Summary ---');
            disp(T);
        end

        %% LVRT Reactive Injection Test
        function obj = checkLVRTReactiveInjection(obj, reference)
            % Parameters from grid code
            VdipThreshold = obj.gridCode.LVRT.minVoltage;
            QminRequired  = obj.gridCode.LVRT.minReactive;
            ResponseDelay = obj.gridCode.LVRT.responseDelay;

            % Extract signals
            Vmeas = obj.data.Vmag;
            Qmeas    = obj.data.Q;

            %----Re-sample-------
            t_resampled = obj.t(1):reference.dt:obj.t(end);
            V = interp1(obj.t, Vmeas, t_resampled, 'linear', 'extrap');
            Q = interp1(obj.t, Qmeas, t_resampled, 'linear', 'extrap');

            % Sampling time
            Ts = reference.dt;

            % Step 1: Detect dip event
            isDip = V < VdipThreshold;
            dipChanges = diff([0; isDip; 0]);
            dipStartIdx = find(dipChanges == 1);
            dipEndIdx   = find(dipChanges == -1) - 1;

            % Initialize result flags
            pass = true;
            details = {};

            for i = 1:length(dipStartIdx)
                idx1 = dipStartIdx(i);
                idx2 = dipEndIdx(i);
                t_dip_start = obj.t(idx1);

                % Step 2: Find Q before dip for reference
                idx_before = max(1, idx1 - round(0.1 / Ts));  % 100 ms before
                Q_pre = mean(Q(idx_before:idx1));

                % Step 3: Check Q rise after delay
                idx_delay_start = idx1 + round(ResponseDelay / Ts);
                idx_delay_end   = min(idx2, idx_delay_start + round(0.2 / Ts)); % 200ms window
                if idx_delay_end > length(Q), idx_delay_end = length(Q); end

                Q_post = mean(Q(idx_delay_start:idx_delay_end));
                deltaQ = Q_post - Q_pre;

                % Step 4: Check threshold
                if deltaQ >= QminRequired
                    details{end+1} = sprintf('Dip at %.3Fs: Q rise %.2f pu [PASS]', t_dip_start, deltaQ);
                else
                    details{end+1} = sprintf('Dip at %.3Fs: Q rise %.2f pu < %.2f pu [FAIL]', ...
                        t_dip_start, deltaQ, QminRequired);
                    pass = false;
                end
            end

            % Final result
            obj.results.lvrtQInjection.pass = pass;
            obj.results.lvrtQInjection.details = details;
        end

        %% Plot XY graphs for LVRT and Frequency Ride-Through compliance
        function plotLVRTFRTCompliance(obj)
            % This function plots the Low Voltage Ride Through (LVRT) and Over Voltage Ride Through (OVRT)
            % compliance of a renewable energy system based on measured voltage at the Point of Interconnection (POI).

            % Extract measurements and grid code data
            code = obj.gridCode;
            Vmag = obj.data.Vmag;

            % Extract LVRT data
            lvrt = code.lvrt;
            v_lvrt = lvrt(:, 1); % Voltage (pu)
            t_lvrt = lvrt(:, 2); % Max Duration (s)

            % Sort LVRT by decreasing voltage for correct patch order
            [~, idx] = sort(v_lvrt, 'descend');
            v_lvrt = v_lvrt(idx);
            t_lvrt = t_lvrt(idx);

            % Split into LVRT (undervoltage) and OVRT (overvoltage) regions
            lvrt_idx = v_lvrt <= 0.9; % Undervoltage region (up to 0.9 pu)
            ovrt_idx = v_lvrt >= 1.05; % Overvoltage region (1.05 pu and above)
            v_lvrt_lvrt = v_lvrt(lvrt_idx);
            t_lvrt_lvrt = t_lvrt(lvrt_idx);
            v_lvrt_ovrt = v_lvrt(ovrt_idx);
            t_lvrt_ovrt = t_lvrt(ovrt_idx);

            % Create step-like LVRT patch (undervoltage)
            t_patch_lvrt = 0; % Start at (0, max voltage in LVRT)
            v_patch_lvrt = [v_lvrt_lvrt(1)]; % Start at max LVRT voltage
            for i = 1:length(t_lvrt_lvrt)-1
                t_patch_lvrt = [t_patch_lvrt; t_lvrt_lvrt(i); t_lvrt_lvrt(i)]; %#ok<*AGROW> % Horizontal segment
                v_patch_lvrt = [v_patch_lvrt; v_lvrt_lvrt(i); v_lvrt_lvrt(i+1)]; % Step down
            end
            t_patch_lvrt = [t_patch_lvrt; t_lvrt_lvrt(end); 0]; % End and close
            v_patch_lvrt = [v_patch_lvrt; v_lvrt_lvrt(end); v_lvrt_lvrt(end)];

            % Create step-like OVRT patch or line (overvoltage)
            t_patch_ovrt = []; % Start at (0, max voltage in OVRT)
            v_patch_ovrt = []; % Start at max OVRT voltage
            for i = 1:length(t_lvrt_ovrt)-1
                t_patch_ovrt = [t_patch_ovrt; t_lvrt_ovrt(i); t_lvrt_ovrt(i)]; % Horizontal segment
                v_patch_ovrt = [v_patch_ovrt; v_lvrt_ovrt(i); v_lvrt_ovrt(i+1)]; % Step down
            end

            t_patch_ovrt = [t_patch_ovrt; t_lvrt_ovrt(end); 0]; % End and close
            v_patch_ovrt = [v_patch_ovrt; v_lvrt_ovrt(end); v_lvrt_ovrt(1)];

            % Create figure with IEEE-style formatting
            figure('Position', [100, 100, 600, 400]);
            set(gca, 'FontName', 'Times New Roman', 'FontSize', 10);

            % Plot LVRT patch (stay-connected region for undervoltage)
            patch(t_patch_lvrt, v_patch_lvrt, 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'k', 'LineWidth', 0.5, ...
                'DisplayName', 'LVRT Stay-Connected Region');
            hold on;

            % Plot patch for Contineous Operating region
            y = [v_patch_ovrt(2:end-1)' v_lvrt_ovrt(end)];
            x = [t_patch_ovrt(2:end-1)' obj.t(end)];
            fill([x,fliplr(x)],[y,v_lvrt_lvrt(1)*ones(size(y))], 'g', 'FaceAlpha', 0.2, 'DisplayName', 'Continuous Operating Region')

            % Plot OVRT patch or line (overvoltage region)
            patch(t_patch_ovrt, v_patch_ovrt, 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'k', 'LineWidth', 0.5, ...
                'DisplayName', 'OVRT Stay-Connected Region');

            % Find first violation (voltage )
            violation_idx = find( ...
                Vmag < max(v_lvrt_lvrt) | Vmag > min(v_lvrt_ovrt), 1, 'first');

            if isempty(violation_idx)
                disp('No voltage or frequency violation detected.');
                return;
            end

            % Time before violation
            t0 = obj.t(violation_idx);
            t_pre = t0 - 0.4;

            % Clip pre-violation window
            idx_start = find(obj.t >= t_pre, 1, 'first');
            idx_end = length(obj.t);  % till end of signal

            t_win = obj.t(idx_start:idx_end);
            V_win = Vmag(idx_start:idx_end);

            % Interpolate threshold curve from 0 onward (i.e., from t0)
            t_since_violation = t_win - t0;

            % Plot signal
            plot(t_since_violation, V_win, 'b', ...
                'LineWidth', 1.5, 'DisplayName', 'Measured Voltage at POI');


            % Add grid and labels
            grid on;
            xlabel('Duration (s)', 'FontName', 'Times New Roman', 'FontSize', 12);
            ylabel('Voltage (pu)', 'FontName', 'Times New Roman', 'FontSize', 12);
            title('Voltage at POI', 'FontName', 'Times New Roman', 'FontSize', 14);

            % Pre-fault and faulted zones marking
            text(-0.2, 0.9, 'Pre-fault', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'black', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
            xline(0, '--k', 'Fault Start', ...
                'LabelOrientation', 'horizontal', ...
                'LineWidth', 1.5, 'FontSize', 10, 'FontWeight', 'bold', 'DisplayName', 'Fault Boundary');

            % Axis limits
            xlim([min(t_since_violation), max(t_since_violation)]);
            ylim([0, 1.3]); % Accommodate max voltage (1.2 pu) with margin

            % Add legend
            legend('show', 'Location', 'best');

            % Plot Style
            set(gca, 'Box', 'on', 'LineWidth', 1, 'GridLineStyle', ':');
            set(gcf, 'Color', 'white');
        end

        %% Update the data in obj between time t1 and t2
        function obj = updateTimeWindow(obj, t1, t2)
            %   Ensures t1 < t2 and trims all signals in obj.data accordingly

            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
                t1 (1,1) double {mustBeFinite, mustBeNonnegative}
                t2 (1,1) double {mustBeFinite, mustBeNonnegative, mustBeGreaterThan(t2, t1)}
            end

            % Find time indices in desired range
            idx = obj.t >= t1 & obj.t <= t2;

            if nnz(idx) < 10
                warning('Selected time window [%.2f, %.2f] contains too few samples.', t1, t2);
            end

            % Trim all fields in obj.data
            fields = fieldnames(obj.data);
            for i = 1:numel(fields)
                sig = obj.data.(fields{i});
                if isvector(sig)
                    obj.data.(fields{i}) = sig(idx);
                elseif ismatrix(sig) && size(sig,1) == length(obj.t)
                    obj.data.(fields{i}) = sig(idx,:);
                end
            end

            % Trim time vector
            obj.t = obj.t(idx);
        end

        %% UPDATEDATA from a different simulation
        function obj = updateData(obj, newData, opts)
            % UPDATEDATA - Update the data struct (P, Q, Vmag, etc.) in the object.
            % Supports raw double arrays or timeseries format.
            %
            % Usage:
            %   obj = obj.updateData(newData);
            %   obj = obj.updateData(newData, "t1", 1, "t2", 5);
            %
            % Inputs:
            %   newData : struct with fields Vmag, f, Iabc, Vabc, P, Q (required)
            %   opts    : optional t1, t2 (crop times), Fs (sampling rate)
            %
            % Updates:
            %   obj.data, obj.t, obj.Fs

            arguments
                obj gridCodeComplianceChecker
                newData struct {mustHaveFields(newData, {'Vmag','f','Iabc','Vabc','P','Q'})}
                opts.t1 double = 0
                opts.t2 double = Inf
                opts.Fs double = []
            end

            % If timeseries, crop to t1-t2 and extract numeric
            if isa(newData.Vmag, 'timeseries')
                newData = cropTimeseries(newData, opts.t1, opts.t2);
                tvec = newData.Vmag.Time;
                FsNew = ifelse(isempty(opts.Fs), 1 / mean(diff(tvec)), opts.Fs);
                newData = extractTimeseriesData(newData);
            else
                FsNew = opts.Fs;
                if isempty(FsNew)
                    error("Sampling frequency (Fs) must be specified for numeric data.");
                end
                tvec = (0:length(newData.Vmag)-1)/FsNew;
            end

            % Validate structure
            mustBeValidData(newData, length(tvec));

            % Assign updated values
            obj.data = newData;
            obj.Fs = FsNew;
            obj.t = tvec;

            fprintf('✅ Data updated. Samples: %d | Duration: %.2f s\n', ...
                length(obj.t), obj.t(end) - obj.t(1));
        end

        %% Plot Basic Signals (Vmag, Frequency, P, Q)
        function obj = plotSignals(obj)
            % plotSignals - Plot voltage magnitude, frequency, active and reactive power vs time.
            %
            % This method helps visualize the raw signal behavior used for compliance testing.

            arguments
                obj gridCodeComplianceChecker {mustBeInitialized(obj)}
            end

            Vmag = obj.data.Vmag(:);
            freq = obj.data.f(:);
            P = obj.data.P(:);
            Q = obj.data.Q(:);

            figure('Name','Grid Code Input Signals','NumberTitle','off');
            set(gca, 'FontName', 'Times New Roman', 'FontSize', 10);

            % --- Voltage Magnitude ---
            subplot(4,1,1);
            plot(obj.t, Vmag, 'b', 'LineWidth', 1.5);
            hold on;
            yline(obj.gridCode.voltage.min, 'r--');
            yline(obj.gridCode.voltage.max, 'g--');
            ylabel('V_{mag} (pu)');
            title('Voltage Magnitude');
            grid on;
            xlim([obj.t(1) obj.t(end)]);

            % --- Frequency ---
            subplot(4,1,2);
            plot(obj.t, freq, 'b', 'LineWidth', 1.5);
            hold on;
            yline(obj.gridCode.frequency.min, 'r--');
            yline(obj.gridCode.frequency.max, 'g--');
            ylabel('Frequency (Hz)');
            title('System Frequency');
            grid on;
            xlim([obj.t(1) obj.t(end)]);

            % --- Active Power ---
            subplot(4,1,3);
            plot(obj.t, P, 'b', 'LineWidth', 1.5);
            ylabel('P (pu)');
            title('Active Power');
            grid on;
            xlim([obj.t(1) obj.t(end)]);

            % --- Reactive Power ---
            subplot(4,1,4);
            plot(obj.t, Q, 'b', 'LineWidth', 1.5);
            xlabel('Time (s)');
            ylabel('Q (pu)');
            title('Reactive Power');
            grid on;
            xlim([obj.t(1) obj.t(end)]);

            sgtitle('Measurements from POI');
        end

    end
end

%% ================= Helper Functions =================
% Check for all Fields
function mustHaveFields(s, fields)
for i = 1:numel(fields)
    if ~isfield(s, fields{i})
        error('Missing field: %s', fields{i});
    end
end
end

% Check for Initial Condition
function mustBeInitialized(obj)
if isempty(obj.data) || isempty(obj.t) || isempty(obj.Fs) || isempty(obj.gridCode) || isempty(obj.FNom)
    error('Object must be fully initialized.');
end
end

% Check for Valid Code
function mustHaveValidGridCode(gc)
mustHaveFields(gc, {'voltage','frequency','harmonics','lvrt','frt_freq'});
mustHaveFields(gc.voltage, {'min','max'});
mustHaveFields(gc.frequency, {'min','max'});
mustHaveFields(gc.harmonics, {'currentLimits','voltageLimits'});
end

% Check for Valid Mesurements
function mustBeValidData(data, N)
validateattributes(data.Vmag, {'double'}, {'vector','numel',N});
validateattributes(data.f, {'double'}, {'vector','numel',N});
validateattributes(data.Iabc, {'double'}, {'2d','nrows',N});
validateattributes(data.Vabc, {'double'}, {'2d','nrows',N});
end

% Crop Measured Data
function data = cropTimeseries(data, t1, t2)
fields = fieldnames(data);
for i = 1:numel(fields)
    if isa(data.(fields{i}), 'timeseries')
        data.(fields{i}) = getsampleusingtime(data.(fields{i}), t1, t2);
    end
end
end

% Extract Data
function data = extractTimeseriesData(data)
fields = fieldnames(data);
for i = 1:numel(fields)
    if isa(data.(fields{i}), 'timeseries')
        d = data.(fields{i}).Data;
        if ndims(d) == 3, d = permute(d, [3 2 1]); end
        data.(fields{i}) = d;
    end
end
end

% Markers for test result
function reportResult(label, pass)
fprintf('%s: %s\n', label, ifelse(pass, '✅ PASS', '❌ FAIL'));
end

% Report FRT Results
function reportFRT(type, limit, duration, observed, pass)
symbol = ifelse(pass, '✅', '✔');
fprintf('%s FRT-%s @ %.2f pu/Hz | Duration: %.2f s (Limit: %.2f s)\n', ...
    symbol, type, limit, observed, duration);
end

% Calculate Harmonics plot Harmonics spectrum in Voltage and Current
function [I_THD, V_THD, pass] = plotHarmonicSpectrum(obj)
N = length(obj.data.Iabc);
YI = abs(fft(obj.data.Iabc)/N); YI = YI(1:floor(N/2),:);
YV = abs(fft(obj.data.Vabc)/N); YV = YV(1:floor(N/2),:);

passI = true; passV = true;
for h = 2:50
    idx = round(h * obj.FNom * N / obj.Fs) + 1;
    if idx > size(YI,1), continue; end
    if h <= length(obj.gridCode.harmonics.currentLimits)
        passI = passI && (max(YI(idx,:))/obj.IRated <= obj.gridCode.harmonics.currentLimits(h));
    end
    if h <= length(obj.gridCode.harmonics.voltageLimits)
        passV = passV && (max(YV(idx,:))/obj.VNom <= obj.gridCode.harmonics.voltageLimits(h));
    end
end

pass = passI && passV;

hmax = 20;
h_idx = round((1:hmax) * obj.FNom * N / obj.Fs) + 1;

Ivals = zeros(hmax, 3); Vvals = zeros(hmax, 3);
for k = 2:hmax
    if h_idx(k) <= size(YI,1)
        Ivals(k,:) = (YI(h_idx(k),:)/obj.IRated)*100;
        Vvals(k,:) = (YV(h_idx(k),:)/obj.VNom)*100;
    end
end

% --- THD Calculation ---
I_THD = sqrt(sum(Ivals(2:end,:).^2, 1));
V_THD = sqrt(sum(Vvals(2:end,:).^2, 1));

% --- Plotting ---
figure('Name','Harmonic Spectrum','NumberTitle','off')
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10);
subplot(2,1,1);
bar(1:hmax, Ivals, 'grouped');
title(sprintf('Current Harmonics (THD: A=%.2f%%, B=%.2f%%, C=%.2f%%)', I_THD));
xlabel('Harmonic Order'); ylabel('% of Fundamental');
legend('A','B','C'); grid on;

subplot(2,1,2);
bar(1:hmax, Vvals, 'grouped');
title(sprintf('Voltage Harmonics (THD: A=%.2f%%, B=%.2f%%, C=%.2f%%)', V_THD));
xlabel('Harmonic Order'); ylabel('% of Fundamental');
legend('A','B','C'); grid on;
end

% Check for LVRT Condition
function y = ifelse(cond, valTrue, valFalse)
if cond, y = valTrue; else, y = valFalse; end
end

% Custom validator for t2 > t1
function mustBeGreaterThan(x, y)
if x <= y
    error('t2 must be greater than t1.');
end
end
