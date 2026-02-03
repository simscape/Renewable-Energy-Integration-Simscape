classdef DynamicSignalGenerator
    % DYNAMICSIGNALGENERATOR
    % Generates synthetic test signals (voltage, frequency, power, Q) 
    % for renewable energy plants to validate compliance with grid codes.
    % Copyright 2025 - 2026 The MathWorks, Inc.
    
    % Signals include voltage ramps, frequency excursions, power and
    % reactive steps, and capability envelope tests (PQ and QV).
    %
    % Output signals are stored as timeseries for easy export to
    % Simulink Signal Editor or custom test benches.
    
    properties
        dt              % Time step (s)
        fs              % Sampling frequency (Hz)

        % Test signals as timeseries (individual or structured)
        VgridRamp       % Simulated grid voltage ramp profile
        Vstep           % Step changes in voltage magnitude
        Pstep           % Step test for active power
        PstepMulti      % Multi-step ramp-up in active power
        Qref            % Step changes in reactive power reference
        Fover           % Over-frequency ride-through test signal
        Funder          % Under-frequency ride-through test signal
        Vdip            % LVRT / voltage sag profile
        Flat            % Flat nominal signal (used for baseline cases)
        PQcapability    % Structured PQ reference trajectory (P and Q)
        QVcapability    % Structured Q-V response based on voltage
    end

    methods
        function obj = DynamicSignalGenerator(dt)
            % Constructor: Initializes the object and generates all test signals.
            if nargin < 1, dt = 0.001; end  % Default timestep: 1 ms
            obj.dt = dt;
            obj.fs = 1/dt;

            % Generate all default test profiles
            obj.VgridRamp    = obj.genVgridRamp();
            obj.Vstep        = obj.genVstep();
            obj.Pstep        = obj.genPstep();
            obj.Qref         = obj.genQref();
            obj.Fover        = obj.genFover();
            obj.Funder       = obj.genFunder();
            obj.Vdip         = obj.genVdip();
            obj.PstepMulti   = obj.genPstepMulti();
            obj.Flat         = obj.genFlat();
            obj.PQcapability = obj.genPQcapability();
            obj.QVcapability = obj.genQVcapability();
        end

        % === TEST SIGNAL GENERATORS ===

        function ts = genVgridRamp(obj)
            % Simulates voltage magnitude ramping across operating limits
            % Tests GFL/GFM response to dynamic grid voltage changes
            t = (0:obj.dt:70)';
            y = ones(size(t));
            y(t >= 5  & t < 11) = 1 - 0.1 * (t(t >= 5 & t < 11) - 5) / 6;     % Downramp to 0.9 pu
            y(t >= 11 & t < 20) = 0.9;
            y(t >= 20 & t < 26) = 0.9 + 0.2 * (t(t >= 20 & t < 26) - 20) / 6; % Upramp to 1.1 pu
            y(t >= 26 & t < 35) = 1.1;
            y(t >= 35 & t < 41) = 1.1 - 0.2 * (t(t >= 35 & t < 41) - 35) / 6; % Downramp to 0.9 pu
            y(t >= 41 & t < 50) = 0.9;
            y(t >= 50 & t <= 56) = 0.9 + 0.1 * (t(t >= 50 & t <= 56) - 50) / 6; % Back to 1.0 pu
            ts = timeseries(y, t);
        end

        function ts = genVstep(obj)
            % Step changes in grid voltage magnitude for voltage regulation tests
            t = (0:obj.dt:40)';
            y = ones(size(t));
            y(t >= 5  & t < 15) = 1.1;
            y(t >= 15 & t < 25) = 0.9;
            y(t >= 25 & t < 35) = 1.05;
            y(t >= 35) = 1.0;
            ts = timeseries(y, t);
        end

        function ts = genPstep(obj)
            % Active power step response test
            t = (0:obj.dt:40)';
            y = ones(size(t));
            y(t >= 5  & t < 15) = 0.5;
            y(t >= 15 & t < 25) = 0.1;
            y(t >= 25) = 1.0;
            ts = timeseries(y, t);
        end

        function ts = genPstepMulti(obj)
            % Active power multi-step ramp test (e.g., for MPPT or control tracking)
            t = (0:obj.dt:35)';
            y = zeros(size(t));
            y(t >= 0  & t < 5)  = 0.0;
            y(t >= 5  & t < 10) = 0.2;
            y(t >= 10 & t < 15) = 0.4;
            y(t >= 15 & t < 20) = 0.6;
            y(t >= 20 & t < 25) = 0.8;
            y(t >= 25)          = 1.0;
            ts = timeseries(y, t);
        end

        function ts = genQref(obj)
            % Reactive power step signal for Q control tests
            t = (0:obj.dt:45)';
            y = zeros(size(t));
            y(t >= 5  & t < 15) = -0.3;
            y(t >= 15 & t < 25) = 0.3;
            y(t >= 25 & t < 35) = -0.3;
            ts = timeseries(y, t);
        end

        function ts = genFunder(obj)
            % Under-frequency ride-through test (normalized to pu)
            t = (0:obj.dt:25)';
            y = 50 * ones(size(t));
            y(t >= 5 & t < 8)   = 50 - 1 * (t(t >= 5 & t < 8) - 5);   % 50 → 47 Hz
            y(t >= 8 & t < 15)  = 47;
            y(t >= 15 & t < 18) = 47 + 1 * (t(t >= 15 & t < 18) - 15);% 47 → 50 Hz
            y(t >= 18) = 50;
            ts = timeseries(y / 50, t);  % pu normalization
        end

        function ts = genFover(obj)
            % Over-frequency ride-through test (normalized to pu)
            t = (0:obj.dt:25)';
            y = 50 * ones(size(t));
            y(t >= 5 & t < 8)   = 50 + (2/3) * (t(t >= 5 & t < 8) - 5);   % 50 → 52 Hz
            y(t >= 8 & t < 15)  = 52;
            y(t >= 15 & t < 18) = 52 - (2/3) * (t(t >= 15 & t < 18) - 15);% 52 → 50 Hz
            y(t >= 18) = 50;
            ts = timeseries(y / 50, t);
        end

        function ts = genVdip(obj)
            % Low voltage ride-through (LVRT) test waveform
            t = (0:obj.dt:12)';
            y = ones(size(t));
            y(t >= 5.0 & t < 5.2) = 0.1;  % Deep dip (e.g. 10%)
            y(t >= 5.2 & t < 5.4) = 0.5;  % Partial recovery
            rampIdx = t >= 5.4 & t <= 6.4;
            y(rampIdx) = 0.8 + (t(rampIdx) - 5.4) * 0.2;  % Smooth ramp back
            y(t > 6.4) = 1.0;
            ts = timeseries(y, t);
        end

        function ts = genFlat(obj)
            % Constant flat signal (1.0 pu) for baseline comparison
            Tflat = 70;
            t = (0:obj.dt:Tflat)';
            y = ones(size(t));
            ts = timeseries(y, t);
        end

        function ts = genPQcapability(obj)
            % PQ capability curve test (unit circle like response)
            t = (0:obj.dt:10)';
            P = zeros(size(t));
            Q = zeros(size(t));
            for i = 1:5
                idx = t >= (i-1)*2 & t < i*2;
                P(idx) = 0.2 * i;
                Q(idx) = linspace(-sqrt(1 - P(find(idx,1))^2), ...
                                   sqrt(1 - P(find(idx,1))^2), sum(idx));
            end
            ts = struct('P', timeseries(P, t), 'Q', timeseries(Q, t));
        end

        function ts = genQVcapability(obj)
            % QV curve response: Q as function of voltage
            t = (0:obj.dt:10)';
            V = linspace(0.9, 1.1, length(t))';
            Q = zeros(size(V));
            Q(V > 1) = -0.44 .* (V(V > 1) - 1); % Capacitive absorption
            Q(V < 1) = 0.44 .* (1 - V(V < 1));  % Inductive injection
            ts = struct('V', timeseries(V, t), ...
                        'P', timeseries(ones(size(t)), t), ...
                        'Q', timeseries(Q, t));
        end

        % === EXPORT AND VISUALIZATION ===

        function exportForSignalEditor(obj, filename)
            % Exports all signals as Simulink Signal Editor Dataset (.mat)
            if nargin < 2
                filename = 'AEMO_FigureBasedSignals.mat';
            end
            ds = Simulink.SimulationData.Dataset;
            ds = ds.addElement(obj.VgridRamp, 'VgridRamp');
            ds = ds.addElement(obj.Vstep, 'Vstep');
            ds = ds.addElement(obj.PstepMulti, 'PstepMulti');
            ds = ds.addElement(obj.Pstep, 'Pstep');
            ds = ds.addElement(obj.Qref, 'Qref');
            ds = ds.addElement(obj.Fover, 'Fover');
            ds = ds.addElement(obj.Funder, 'Funder');
            ds = ds.addElement(obj.Vdip, 'Vdip');
            ds = ds.addElement(obj.Flat, 'Flat');
            ds = ds.addElement(obj.PQcapability.P, 'PQ_Pref');
            ds = ds.addElement(obj.PQcapability.Q, 'PQ_Qref');
            ds = ds.addElement(obj.QVcapability.V, 'QV_Vmag_ext');
            ds = ds.addElement(obj.QVcapability.P, 'QV_Pref');
            ds = ds.addElement(obj.QVcapability.Q, 'QV_Qref');
            save(filename, 'ds');
            fprintf('✅ Exported to "%s" for Simulink Signal Editor\n', filename);
        end

        function plotSignal(obj, signalName)
            % Utility to plot any signal by name
            if isprop(obj, signalName)
                sig = obj.(signalName);
                if isa(sig, 'timeseries')
                    figure;
                    plot(sig.Time, sig.Data, 'LineWidth', 1.5);
                    grid on;
                    xlabel('Time (s)');
                    ylabel(signalName);
                    title(['Signal: ', signalName]);
                elseif isstruct(sig)
                    fields = fieldnames(sig);
                    for k = 1:numel(fields)
                        subplot(numel(fields), 1, k);
                        plot(sig.(fields{k}).Time, sig.(fields{k}).Data, 'LineWidth', 1.5);
                        title([signalName '.' fields{k}]);
                        xlabel('Time (s)');
                        ylabel(fields{k});
                        grid on;
                    end
                else
                    error('❌ The property "%s" is not a timeseries or structured timeseries.', signalName);
                end
            else
                error('❌ Unknown signal "%s". Check property name.', signalName);
            end
        end
    end
end
