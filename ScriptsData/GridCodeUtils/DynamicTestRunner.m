classdef DynamicTestRunner
%% DynamicTestRunner
% Copyright 2025 - 2026 The MathWorks, Inc.
%==========================================================================
% DESCRIPTION:
%   DynamicTestRunner is a class-based test framework for evaluating the
%   dynamic performance of renewable energy plants and converter-based
%   resources against reference test signals. It is intended for post-
%   processing of time-domain simulation or measurement data obtained from
%   EMT or RMS models in Simscape.
%
%   The class compares measured plant responses at the Point of Interconnection
%   (POI) against predefined reference signals and automatically evaluates
%   compliance with common grid-code–style dynamic performance requirements.
%
% FUNCTIONALITY OVERVIEW:
%   - Time-window extraction of measured and reference signals (t1–t2)
%   - Flat-run stability tests (steady-state deviation checks)
%   - Step response tracking (overshoot and settling time)
%   - Ramp tracking performance (max error and RMSE)
%   - Voltage ramp power stability assessment
%   - Fault Ride-Through (FRT) active power recovery evaluation
%
% INPUTS:
%   measured   : Struct containing measured timeseries signals at the POI
%                (e.g., Vmag, P, Q, Iabc, f)
%   reference  : Struct containing reference timeseries test signals
%                (e.g., voltage ramps, power steps, frequency events)
%
% NAME-VALUE OPTIONS:
%   'Ts'        : Sampling time (s) used for analysis and settling logic
%   't1'        : Start time of the analysis window (s)
%   't2'        : End time of the analysis window (s)
%   'tolerance' : Acceptable deviation threshold for pass/fail decisions
%
% OUTPUTS:
%   - PASS/FAIL summaries for each test
%   - Diagnostic plots comparing measured and reference signals
%
% DESIGN NOTES:
%   - Uses MATLAB timeseries objects for signal handling
%   - Designed for automated, repeatable dynamic compliance testing
%   - Suitable for extension to different grid codes (IEEE 2800, ENTSO-E,
%     AEMO, CEA, etc.) using representative thresholds
%
% TYPICAL USAGE:
%   tester = DynamicTestRunner(measured, reference, ...
%       "t1", 5, "t2", 40, "tolerance", 0.05);
%   tester.runAll();
    properties
        measured    % Struct of measured signals (timeseries)
        reference   % Struct of reference test signals (timeseries)
        tolerance   % Acceptable deviation (pu or Hz)
        Ts          % Time step (s)
    end

    methods
        function obj = DynamicTestRunner(measuredVal, referenceVal, options)
            arguments
                measuredVal struct
                referenceVal DynamicSignalGenerator
                options.Ts (1,1) double {mustBePositive} = 0.001
                options.t1 (1,1) double {mustBePositive} = 0
                options.t2 (1,1) double {mustBePositive} = Inf
                options.tolerance (1,1) double {mustBePositive} = 0.025
            end
            % Extract time vector from timeseries of measurements
            measuredVal.Iabc = getsampleusingtime(measuredVal.Iabc, options.t1, options.t2); % is a structure containing the POI measurements in (PU)
            measuredVal.Vabc = getsampleusingtime(measuredVal.Vabc, options.t1, options.t2);
            measuredVal.Vmag = getsampleusingtime(measuredVal.Vmag, options.t1, options.t2);
            measuredVal.f = getsampleusingtime(measuredVal.f, options.t1, options.t2);
            measuredVal.P = getsampleusingtime(measuredVal.P, options.t1, options.t2);
            measuredVal.Q = getsampleusingtime(measuredVal.Q, options.t1, options.t2);
            % Extract time vector from timeseries of reference
            referenceVal.VgridRamp = getsampleusingtime(referenceVal.VgridRamp, options.t1, options.t2); % is a structure containing the POI measurements in (PU)
            referenceVal.Pstep = getsampleusingtime(referenceVal.Pstep, options.t1, options.t2);
            referenceVal.Qref = getsampleusingtime(referenceVal.Qref, options.t1, options.t2);
            referenceVal.Fover = getsampleusingtime(referenceVal.Fover, options.t1, options.t2);
            referenceVal.Funder = getsampleusingtime(referenceVal.Funder, options.t1, options.t2);
            referenceVal.Vdip = getsampleusingtime(referenceVal.Vdip, options.t1, options.t2);
            obj.measured = measuredVal;
            obj.reference = referenceVal;
            obj.tolerance = options.tolerance;
            obj.Ts = options.Ts;
        end

        function runAll(obj)
            fprintf('\n===== Dynamic Tests on Simulated Measurements =====\n');
            obj.testFlatRun('Vmag');
            obj.testFlatRun('P');
            obj.testFlatRun('Q');
            obj.testStepTracking(obj.measured.P, obj.reference.Pstep, 'Active Power (P)');
            obj.testStepTracking(obj.measured.Q, obj.reference.Qref, 'Reactive Power (Q)');
            obj.testRampTracking(obj.measured.Vmag, obj.reference.VgridRamp, 'Voltage Ramp');
            obj.testRampTracking(obj.measured.F, obj.reference.Fover, 'Overfrequency');
            obj.testRampTracking(obj.measured.F, obj.reference.Funder, 'Underfrequency');
            obj.testActivePowerDuringVoltageRamp();
            obj.testFRTPowerRecovery();
        end
        %% Flat Run test
        function testFlatRun(obj, signal, options)
            arguments
                obj DynamicTestRunner
                signal (1,:) char  % Name of the signal, e.g. 'Vmag', 'P', 'Q'
                options {mustBeMember(options, ["Y", "N"])} = "N"
            end

            fprintf('\n[%s Flat Run Test]\n', signal);

            % Access the timeseries dynamically
            ts = obj.measured.(signal);
            data = ts.Data;

            % Flatness check
            delta = max(data) - min(data);
            fprintf('Delta = %.5f — %s\n', delta, passFail(delta < obj.tolerance));

            % Plot
            if options == "Y"
                obj.plotSignal(ts, signal);
            end
        end

        %% Step Signal tracking
        function testStepTracking(obj, measuredTS, refTS, name)
            arguments
                obj DynamicTestRunner
                measuredTS timeseries
                refTS timeseries
                name (1,:) char
            end
            fprintf('\n[%s Step Tracking Test]\n', name);
            [meas, ref, t] = obj.sync(measuredTS, refTS);
            figure("Name",'Step Tracking');
            plot(t,ref,'--k',t,meas,'b');
            title([name ' Step Tracking']); xlabel('Time (s)'); ylabel(name);
            legend('Reference', 'Measured');
           
            % Round ref to remove noise and ensure piecewise constant signal
            refClean = round(ref * 100) / 100;  % Round to 2 decimal places

            % Find step changes with a minimum step size to avoid noise
            minStepSize = 0.02; % Minimum step size to consider (adjust as needed)
            diffRef = diff(refClean);
            stepIdxs = find(abs(diffRef) > minStepSize);

            % Debounce: Keep only the first index within a small time window (e.g., 2*Ts)
            debounceWindow = ceil(2 * obj.Ts / (t(2) - t(1))); % Number of samples in 2*Ts
            if ~isempty(stepIdxs)
                keepIdx = true(size(stepIdxs));
                for i = 2:length(stepIdxs)
                    if stepIdxs(i) - stepIdxs(i-1) <= debounceWindow
                        keepIdx(i) = false; % Remove steps too close together
                    end
                end
                stepIdxs = stepIdxs(keepIdx);
            end

            if isempty(stepIdxs)
                fprintf('No steps detected in reference signal.\n');
                return;
            end
            
            % Analyze each step
            for i = 1:length(stepIdxs)
                idx = stepIdxs(i);
                tStep = t(idx);
                finalVal = refClean(idx+0.1/obj.Ts); % Value after the step

                % Define a settling window (e.g., 8 seconds after the step)
                settleWindow = idx+0.5/obj.Ts:min(idx+floor(8/obj.Ts), length(t));
                deviation = abs(meas(settleWindow) - finalVal);
                settled = find(deviation < 0.05, 1);
                if isempty(settled)
                    settlingTime = NaN;
                    settledStr = 'not settled';
                else
                    settlingTime = t(settleWindow(settled)) - tStep;
                    settledStr = sprintf('%.3f s', settlingTime);
                end

                % Calculate overshoot
                maxVal = max(meas(idx+0.1/obj.Ts:min(idx+floor(8/obj.Ts), length(t))));
                overshoot = max(0, maxVal - finalVal);

                fprintf('Step %d @ %.2fs Final Value: %.2f: Overshoot = %.3f, Settling Time = %s — %s\n', ...
                    i, tStep, finalVal, overshoot, settledStr, ...
                    passFail(overshoot < 0.1 && ~isnan(settlingTime) && settlingTime < 8));
            end
        end
        %% Ramp Signal tracking
        function testRampTracking(obj, measuredTS, refTS, name)
            arguments
                obj DynamicTestRunner
                measuredTS timeseries
                refTS timeseries
                name (1,:) char
            end
            fprintf('\n[%s Ramp Tracking Test]\n', name);
            [meas, ref, t] = obj.sync(measuredTS, refTS);
            error = abs(meas - ref);
            maxError = max(error);
            rmse = sqrt(mean((meas - ref).^2));

            figure('Name', [name ' Ramp Response'], 'NumberTitle', 'off');
            plot(t, ref, '--k', t, meas, 'b'); grid on;
            title([name ' Ramp Tracking']); xlabel('Time (s)'); ylabel(name);
            legend('Reference', 'Measured');

            fprintf('Max Error = %.4f, RMSE = %.4f — %s\n', ...
                maxError, rmse, passFail(maxError < obj.tolerance));
        end

         %% Voltage Ramp Signal test
        function testActivePowerDuringVoltageRamp(obj)
            arguments
                obj DynamicTestRunner
            end
            fprintf('\n[Voltage Ramp Power Stability Test]\n');
            [~, ~, t] = obj.sync(obj.measured.Vmag, obj.reference.VgridRamp);
            [P, ~, ~] = obj.sync(obj.measured.P, obj.reference.VgridRamp);
            rampIdx = (t >= 5);
            P_during_ramp = P(rampIdx);
            P_drop = max(P_during_ramp) - min(P_during_ramp);

            fprintf('Max Delta P during ramp: %.3f pu — %s\n', P_drop, passFail(P_drop < 0.05));
        end

         %% Fault Recovery Test
        function testFRTPowerRecovery(obj)
            arguments
                obj DynamicTestRunner
            end
            fprintf('\n[FRT Power Recovery Test — Dip Response]\n');
            [Vmag, Vref, t] = obj.sync(obj.measured.Vmag, obj.reference.Vdip);
            [P, ~, ~] = obj.sync(obj.measured.P, obj.reference.Vdip);
            dipRefIdx = find(Vref < 0.9);
            dipIdx = find(Vmag < 0.9, 1);
            tdip = t(dipRefIdx(end)) - t(dipRefIdx(1));
            if isempty(dipIdx)
                fprintf('No dip < 0.9 pu detected in Vmag.\n');
                return;
            end

            P_initial = P(dipIdx - 1);
            recoveryIdx = find(P(dipIdx:end) >= 0.95 * P_initial, 1);
            if isempty(recoveryIdx)
                fprintf('FAIL: Active power did not recover post-dip.\n');
                return;
            end
            t_rec = t(dipRefIdx(end) + recoveryIdx) - t(dipRefIdx(1));
            fprintf('Power recovered to 95%% in %.4f s — %s\n', t_rec, passFail(t_rec < 1.5));
            fprintf('The volatge dip was conducted for %0.4f sec', tdip);
        end

         %% Helper function for time sync
        function [y1, y2, t] = sync(~, ts1, ts2)
            % Ensure both are timeseries with same timebase via interpolation
            tStart = max(ts1.Time(1), ts2.Time(1)); %#ok<*NASGU>
            tEnd   = min(ts1.Time(end), ts2.Time(end));
            t = ts1.Time;  % or use linspace(tStart, tEnd, N) for common base

            % Use interpolation to align both signals
            y1 = interp1(ts1.Time, ts1.Data, t, 'linear', 'extrap');
            y2 = interp1(ts2.Time, ts2.Data, t, 'linear', 'extrap');
        end

         %% Plot functions
        function plotSignal(~, ts, name)
            figure('Name', [name ' Flat Signal'], 'NumberTitle', 'off');
            plot(ts.Time, ts.Data, 'b'); grid on;
            title([name ' Flat Run']);
            xlabel('Time (s)'); ylabel(name);
        end

        function plotWaveform(~, t, measured, reference, name, type)
            figure('Name', [name ' ' type], 'NumberTitle', 'off');
            plot(t, reference, '--k', t, measured, 'b'); grid on;
            title([name ' ' type]);
            xlabel('Time (s)'); ylabel(name);
            legend('Reference', 'Measured');
        end

        function plotFRTVoltage(obj)
            [Vmag, Vref, t] = obj.sync(obj.measured.Vmag, obj.reference.Vdip);
            obj.plotWaveform(t, Vmag, Vref, 'Voltage Magnitude', 'FRT Response');
        end

    end
end

%% ================= Helper Functions =================
function result = passFail(condition)
if condition
    result = '✅ PASS';  % Use the literal character if your editor supports it
else
    result = '❌ FAIL';
end
end

