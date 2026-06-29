classdef BlackstartAnalyzer
    % ==========================================================
    % BLACKSTART ANALYZER - HVDC + WIND FARM
    % ==========================================================
    % Copyright 2025 - 2026 The MathWorks, Inc.

    % The BlackstartAnalyzer class provides an automated framework for
    % analyzing HVDC black-start simulations involving offshore wind farms
    % and VSC-HVDC systems. It processes simulation logs, extracts key signals,
    % detects operational events, computes Key Performance Indicators (KPIs),
    % and generates visualization.

    % This class is designed for:
    % - HVDC black-start studies
    % - Grid-forming (GFM) and grid-following (GFL) interaction analysis
    % - Renewable integration research
    % - MATLAB/Simulink post-processing automation

    %% SYNTAX
    % analyzer = BlackstartAnalyzer(logsout)
    % -------------------------------------------------------------------------
    %% INPUT
    % logsout : Simulink.SimulationData.Dataset
    % Simulation output dataset containing logged signals.
    %% OUTPUT
    % KPI Computation
    % - DC energization metrics (rise time, overshoot, settling)
    % - Offshore grid formation metrics
    % - Frequency stability indicators
    % - Power transfer and mismatch indices
    % - Black-start sequence timing
    %
    %% Visualization
    % - Multi-panel dashboard plots
    % - Offshore vs onshore comparison


    properties
        logsout
        data
        signals
        event
        KPI
        KPITable
        params
    end

    methods
        %% ================= CONSTRUCTOR =================
        function obj = BlackstartAnalyzer(logsout)

            if nargin > 0
                obj.logsout = logsout;

                % Default parameters
                obj.params.f_nom = 60;
                obj.params.Vdc_tol = 0.98;

                obj = obj.parseLogs();
                obj = obj.extractSignals();
                obj = obj.detectEvents();
                obj = obj.computeKPIs();
                obj = obj.getKPITable();
            end
        end

        %% ================= PARSE LOGS =================
        function obj = parseLogs(obj)

            logs = obj.logsout;
            data1 = struct();

            for i = 1:logs.numElements
                sig = logs{i};

                baseKey = matlab.lang.makeValidName( ...
                    strrep(sig.BlockPath.getBlock(1), '/', '_'));

                % Make unique using signal name
                nameKey = matlab.lang.makeValidName(sig.Name);

                key = [baseKey '_' nameKey '_' num2str(i)];

                data1.(key).name  = sig.Name;
                data1.(key).time  = sig.Values.Time;
                data1.(key).value = sig.Values.Data;
            end

            obj.data = data1;
        end

        %% ================= EXTRACT SIGNALS =================
        function obj = extractSignals(obj)

            data1 = obj.data;
            fields = fieldnames(data1);

            sig = struct();

            for i = 1:length(fields)
                f = fields{i};
                name = lower(data1.(f).name);

                % DC
                if contains(name,'vdc')
                    sig.Vdc = data1.(f);

                % Onshore
                elseif contains(name,'vabconshore')
                    sig.V_on = data1.(f);

                elseif strcmp(name,'pg')
                    sig.P_on = data1.(f);
                
                elseif contains(name,'vmagonshore')
                    sig.Vmag_on = data1.(f);

                elseif contains(name,'fonshore')
                    sig.F_on = data1.(f);

                % Offshore
                elseif contains(name,'vmag')
                    sig.V_off = data1.(f);

                elseif strcmp(name,'foffshore')
                    sig.F_off = data1.(f);

                elseif contains(name,'pwindfarm')
                    sig.P_off = data1.(f);
                end
            end

            obj.signals = sig;
        end

        %% ================= EVENT DETECTION =================
        function obj = detectEvents(obj)

            sig = obj.signals;

            %% --- DC ---
            Vdc = sig.Vdc.value;
            t   = sig.Vdc.time;

            idx = find(Vdc > 1e-4*max(Vdc),1);
            obj.event.t_charge_start = obj.safeIndex(t, idx);

            idx = find(Vdc > obj.params.Vdc_tol*max(Vdc),1);
            obj.event.t_dc_ready = obj.safeIndex(t, idx);

            %% --- Offshore ---
            if isfield(sig,'V_off')
                Voff = sig.V_off.value;
                toff = sig.V_off.time;

                idx = find(Voff > 0.9*max(Voff),1);
                obj.event.t_offshore_ready = obj.safeIndex(toff, idx);
            else
                obj.event.t_offshore_ready = NaN;
            end

            %% --- Onshore ---
            if isfield(sig,'Vmag_on')
                Von = sig.Vmag_on.value;
                ton = sig.Vmag_on.time;

                idx = find(Von > 0.2*max(Von),1);
                obj.event.t_onshore_start = obj.safeIndex(ton, idx);
            else
                obj.event.t_onshore_start = NaN;
            end

            %% --- Load ---
            if isfield(sig,'P_on')
                P = sig.P_on.value;
                tp = sig.P_on.time;

                idx = find(P > 0.1*max(P),1);
                obj.event.t_load = obj.safeIndex(tp, idx);
            else
                obj.event.t_load = NaN;
            end
        end

        %% ================= KPI =================
        function obj = computeKPIs(obj)

            sig = obj.signals;
            e   = obj.event;

            obj.KPI = struct();

            %% ================= DC KPIs =================
            Vdc = sig.Vdc.value;
            t   = sig.Vdc.time;

            Vfinal = mean(Vdc(end-100:end));

            % Rise time (1% → 90%)
            idx10 = find(Vdc > 0.01*Vfinal,1);
            idx90 = find(Vdc > 0.9*Vfinal,1);

            obj.KPI.Vdc_rise_time = t(idx90) - t(idx10);

            % Overshoot
            obj.KPI.Vdc_overshoot = (max(Vdc)-Vfinal)/Vfinal;

            % Settling time
            idx_settle = find(abs(Vdc - Vfinal) < 0.02*Vfinal,1);
            obj.KPI.Vdc_settling_time = t(idx_settle);

            % Charging rate
            obj.KPI.Vdc_charging_rate = (Vdc(idx90)-Vdc(idx10)) / ...
                (t(idx90)-t(idx10));
            %% ================= OFFSHORE KPIs =================
            Voff = sig.V_off.value;
            toff = sig.V_off.time;

            % --- Build time (keep existing logic) ---
            Vnom = mean(Voff(end-100:end));
            idx = find(Voff > 0.9*Vnom,1);
            obj.KPI.V_off_build_time = obj.safeIndex(toff, idx);

            % --- Voltage dip AFTER offshore grid formation ---
            t_start = obj.event.t_offshore_ready;

            if ~isnan(t_start)

                idx = toff >= t_start;

                V_valid = Voff(idx);

                % Reference (steady-state)
                if numel(V_valid) > 50
                    Vref = mean(V_valid(end-50:end));
                else
                    Vref = mean(V_valid);
                end

                % Minimum after energization
                Vmin = min(V_valid);

                % Per-unit dip
                obj.KPI.V_off_dip = (Vref - Vmin)/Vref;

            else
                obj.KPI.V_off_dip = NaN;
            end


            %% ================= FREQUENCY KPIs =================
            if isfield(sig,'F_off')

                F  = sig.F_off.value;
                tf = sig.F_off.time;

                t_start = obj.event.t_offshore_ready;

                if ~isnan(t_start)

                    idx = tf >= t_start;
                    F_valid = F(idx);

                    if numel(F_valid) > 50
                        Fref = mean(F_valid(end-50:end));
                    else
                        Fref = mean(F_valid);
                    end

                    Fmin = min(F_valid);

                    % Frequency dip (Hz)
                    obj.KPI.freq_dip = (Fref - Fmin);

                    % Peak deviation (Hz)
                    obj.KPI.freq_peak_dev = max(abs(F_valid - obj.params.f_nom));

                    % Oscillation metric
                    obj.KPI.freq_std = std(F_valid);

                    % Steady-state error
                    obj.KPI.freq_steady_error = ...
                        abs(Fref - obj.params.f_nom);

                else
                    obj.KPI.freq_dip = NaN;
                    obj.KPI.freq_std = NaN;
                    obj.KPI.freq_steady_error = NaN;
                end
            end

            %% ================= POWER KPIs =================
            if isfield(sig,'P_off') && isfield(sig,'P_on')

                Poff = sig.P_off.value;
                Pon  = sig.P_on.value;
                tp   = sig.P_on.time;

                obj.KPI.power_balance_error = ...
                    abs(mean(Poff(end-100:end)) - mean(Pon(end-100:end)));

                % Oscillation index (energy)
                obj.KPI.P_oscillation_index = trapz(tp, (Pon - mean(Pon)).^2);

            end

            %% ================= TIMING KPIs =================
            obj.KPI.t_PIR_to_DC_ready = e.t_dc_ready - e.t_charge_start;
            obj.KPI.t_DC_to_GFM       = e.t_offshore_ready - e.t_dc_ready;
            obj.KPI.t_GFM_to_load     = e.t_load - e.t_offshore_ready;
            obj.KPI.total_blackstart_time = e.t_load;

        end

        %% ================= KPI Table =================

        function obj = getKPITable(obj)

            K = obj.KPI;

            KPI_name = string.empty;
            Value    = [];
            Unit     = string.empty;

            %% -------- DC KPIs --------
            KPI_name(end+1) = 'Vdc Rise Time';
            Value(end+1)    = K.Vdc_rise_time;
            Unit(end+1)     = 's';

            KPI_name(end+1) = 'Vdc Overshoot';
            Value(end+1)    = K.Vdc_overshoot;
            Unit(end+1)     = 'pu';

            KPI_name(end+1) = 'Vdc Settling Time';
            Value(end+1)    = K.Vdc_settling_time;
            Unit(end+1)     = 's';

            KPI_name(end+1) = 'Vdc Charging Rate';
            Value(end+1)    = K.Vdc_charging_rate;
            Unit(end+1)     = 'V/s';

            %% -------- Offshore --------
            KPI_name(end+1) = 'Offshore Voltage Build Time';
            Value(end+1)    = K.V_off_build_time;
            Unit(end+1)     = 's';

            KPI_name(end+1) = 'Offshore Voltage Dip';
            Value(end+1)    = K.V_off_dip;
            Unit(end+1)     = 'pu';

            %% -------- Frequency --------

            if isfield(K,'freq_dip')
                KPI_name(end+1) = 'Frequency Dip';
                Value(end+1)    = K.freq_dip;
                Unit(end+1)    = 'Hz';
            end

            if isfield(K,'freq_peak_dev')
                KPI_name(end+1) = 'Frequency Peak Deviation';
                Value(end+1)    = K.freq_peak_dev;
                Unit(end+1)     = 'Hz';
            end

            if isfield(K,'freq_std')
                KPI_name(end+1) = 'Frequency Std Dev';
                Value(end+1)    = K.freq_std;
                Unit(end+1)     = 'Hz';
            end

            %% -------- Power --------
            if isfield(K,'power_balance_error')
                KPI_name(end+1) = 'Power Balance Error';
                Value(end+1)    = K.power_balance_error;
                Unit(end+1)     = 'W';
            end

            if isfield(K,'P_oscillation_index')
                KPI_name(end+1) = 'Power Oscillation Index';
                Value(end+1)    = K.P_oscillation_index;
                Unit(end+1)     = 'W^2·s';
            end

            %% -------- Timing --------
            KPI_name(end+1) = 'PIR → DC Ready';
            Value(end+1)    = K.t_PIR_to_DC_ready;
            Unit(end+1)     = 's';

            KPI_name(end+1) = 'DC → GFM';
            Value(end+1)    = K.t_DC_to_GFM;
            Unit(end+1)     = 's';

            KPI_name(end+1) = 'GFM → Load';
            Value(end+1)    = K.t_GFM_to_load;
            Unit(end+1)     = 's';

            KPI_name(end+1) = 'Total Blackstart Time';
            Value(end+1)    = K.total_blackstart_time;
            Unit(end+1)     = 's';

            %% -------- CREATE TABLE --------
            T = table(KPI_name', Value', Unit',...
                'VariableNames',{'KPI','Value','Unit'});
            obj.KPITable = T;

        end

        %% ================= MAIN PLOT =================
        function plotDashboard(obj)

            sig = obj.signals;

            figure('Name','Blackstart Dashboard','Units','normalized','OuterPosition',[0 0 0.5 0.5])
            tiledlayout(2,2,'TileSpacing','compact');
            %% --- Vdc ---
            subplot(2,2,1)

            Vdc = sig.Vdc.value/1e3;
            t   = sig.Vdc.time;

            idx = find(Vdc > obj.params.Vdc_tol*max(Vdc),1);
            idxst = find(Vdc > 0.01*max(Vdc),1);

            hold on

            %% -------- PATCHES --------
            h1 = patch([t(idxst) t(idx) t(idx) t(idxst)],...
                [min(Vdc) min(Vdc) max(Vdc) max(Vdc)],...
                [0.7 0.85 1],'FaceAlpha',0.25,'EdgeColor','none');

            h2 = patch([t(idx) t(end) t(end) t(idx)],...
                [min(Vdc) min(Vdc) max(Vdc) max(Vdc)],...
                [0.75 1 0.75],'FaceAlpha',0.25,'EdgeColor','none');

            %% -------- Vdc LINE --------
            h3 = plot(t,Vdc,'b','LineWidth',1.8);

            %% -------- EVENTS --------
            obj.addEventMarkers();

            %% -------- LEGEND --------
            % Dummy lines for legend (no plotting impact)
            e1 = plot(nan,nan,'--','Color',[0 0.4 1]);
            e2 = plot(nan,nan,'--','Color',[0 0.7 0]);
            e3 = plot(nan,nan,'--','Color',[0.7 0 0.7]);
            e4 = plot(nan,nan,'--','Color',[1 0.6 0]);
            e5 = plot(nan,nan,'--','Color',[1 0 0]);

            legend([h1 h2 h3 e1 e2 e3 e4 e5],...
                {'Charging Stage',...
                'Voltage Control',...
                'Vdc',...
                'DC Start',...
                'DC Ready',...
                'Offshore Ready',...
                'Onshore Start',...
                'Load'},...
                'Location','northwest');
            title('DC Voltage with Blackstart Phases','FontWeight','bold')
            xlabel('Time (s)'), ylabel('Vdc (kV)')
            grid on
            box on

            %% --- Offshore Voltage ---
            subplot(2,2,2)
            hold on
            plot(sig.V_off.time, sig.V_off.value,'LineWidth',1.5)
            plot(sig.Vmag_on.time, sig.Vmag_on.value,'LineWidth',1.5)
            obj.addEventMarkers()
            legend('Offshore','Onshore','Location','northwest')
            title('AC Voltage Magnitude'), grid on
            xlabel('Time (s)'), ylabel('V (pu)')

            %% --- Frequency ---
            subplot(2,2,3)
            hold on
            plot(sig.F_off.time, sig.F_off.value,'LineWidth',1.5)
            plot(sig.F_on.time, sig.F_on.value,'LineWidth',1.5)
            obj.addEventMarkers()
            legend('Offshore','Onshore','Location','northwest')
            title('Frequency'), grid on
            xlabel('Time (s)'), ylabel('Frequency (Hz)')

            %% --- Power ---
            subplot(2,2,4)
            hold on
            plot(sig.P_off.time, sig.P_off.value/1e6,'LineWidth',1.5)
            plot(sig.P_on.time, sig.P_on.value/1e6,'LineWidth',1.5)
            obj.addEventMarkers()
            legend('Offshore','Onshore')
            title('Power'), grid on;
            xlabel('Time (s)'), ylabel('Power (MW)')
        end

        %% ================= SYSTEM COMPARISON =================
        function plotSystemComparison(obj)

            sig = obj.signals;
            e   = obj.event; %#ok<NASGU>
            K   = obj.KPI;

            %% ================= FIGURE =================
            figure('Name','System Comparison',...
                'Units','normalized','OuterPosition',[0 0 0.5 0.5])

            tlo = tiledlayout(3,1,...
                'Padding','none','TileSpacing','compact');


            ax = gca; ax.LooseInset = ax.TightInset;

            %% ================= FREQUENCY =================
            nexttile
            hold on

            if isfield(sig,'F_off')
                h3 = plot(sig.F_off.time, sig.F_off.value,...
                    'k','LineWidth',1.5); %#ok<NASGU>
            else
                text(0.4,0.5,'Frequency not available')
                axis off
            end

            obj.addEventMarkers()

            title('Frequency Response','FontWeight','bold')
            ylabel('Hz')
            grid on
            box on

            ax = gca; ax.LooseInset = ax.TightInset;

            %% ================= POWER =================
            nexttile
            hold on

            % Offshore power
            h4 = plot(sig.P_off.time, sig.P_off.value/1e6,...
                'b','LineWidth',1.5);

            % Onshore power
            h5 = plot(sig.P_on.time, sig.P_on.value/1e6,...
                'r','LineWidth',1.5);


            obj.addEventMarkers()

            legend([h4 h5],...
                {'Offshore','Onshore'},...
                'Location','best')

            title('Power Transfer','FontWeight','bold')
            ylabel('Power (MW)')
            xlabel('Time (s)')
            grid on
            box on

            ax = gca; ax.LooseInset = ax.TightInset;

            %% ================= KPI OVERLAY =================
            txt = sprintf(['Vdc Rise: %.2f s\n',...
                'Freq Dev: %.2f Hz\n',...
                'Power Error: %.2e\n',...
                'Total Time: %.2f s'],...
                K.Vdc_rise_time,...
                K.freq_peak_dev,...
                K.power_balance_error,...
                K.total_blackstart_time);

            annotation('textbox',[0.15 0.15 0.2 0.2],...
                'String',txt,...
                'FitBoxToText','on',...
                'BackgroundColor','w',...
                'FontWeight','bold');

        end

        %% ================= EVENT MARKERS =================
        function addEventMarkers(obj)

            e = obj.event;

            lw = 1.2;

            if ~isnan(e.t_charge_start)
                xline(e.t_charge_start,'--','Color',[0 0.4 1],'LineWidth',lw);
            end

            if ~isnan(e.t_dc_ready)
                xline(e.t_dc_ready,'--','Color',[0 0.7 0],'LineWidth',lw);
            end

            if ~isnan(e.t_offshore_ready)
                xline(e.t_offshore_ready,'--','Color',[0.7 0 0.7],'LineWidth',lw);
            end

            if ~isnan(e.t_onshore_start)
                xline(e.t_onshore_start,'--','Color',[1 0.6 0],'LineWidth',lw);
            end

            if ~isnan(e.t_load)
                xline(e.t_load,'--','Color',[1 0 0],'LineWidth',lw);
            end
        end
    end

    methods (Static)
        function val = safeIndex(vec, idx)
            if isempty(idx)
                val = NaN;
            else
                val = vec(idx);
            end
        end
    end
end