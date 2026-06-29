function T = KPIComparison(results)
% This function performs a KIP evaluation and comparison
% Copyright 2025 - 2026 The MathWorks, Inc.

pIR_list = [];
Vdip = [];
Fdip = [];
Ppeak = [];
Tcharge = [];
nCases = length(results);
for k = 1:nCases

    sig = results(k).signals;
    KPI = results(k).KPI;
    evt = results(k).event;

    pIR_list(end+1) = results(k).pIR;

    %% ================= VOLTAGE DIP =================
    if isfield(sig,'V_off') && ~isnan(evt.t_offshore_ready)

        t = sig.V_off.time;
        V = sig.V_off.value;

        idx = t >= evt.t_offshore_ready;

        if any(idx)
            V_valid = V(idx);

            if numel(V_valid) > 50
                Vref = mean(V_valid(end-50:end));
            else
                Vref = mean(V_valid);
            end

            Vmin = min(V_valid);
            Vdip(end+1) = (Vref - Vmin)/Vref;
        else
            Vdip(end+1) = NaN;
        end
    else
        Vdip(end+1) = NaN;
    end

    %% ================= FREQUENCY DIP (CORRECTED) =================
    if isfield(sig,'F_off') && ~isnan(evt.t_offshore_ready)

        t = sig.F_off.time;
        F = sig.F_off.value;

        idx = t >= evt.t_offshore_ready;

        if any(idx)
            F_valid = F(idx);

            if numel(F_valid) > 50
                Fref = mean(F_valid(end-50:end));
            else
                Fref = mean(F_valid);
            end

            Fmin = min(F_valid);
            Fdip(end+1) = (Fref - Fmin);
        else
            Fdip(end+1) = NaN;
        end
    else
        Fdip(end+1) = NaN;
    end

    %% ================= PEAK POWER =================
    if isfield(sig,'P_on')
        Ppeak(end+1) = max(sig.P_on.value);
    else
        Ppeak(end+1) = NaN;
    end

    %% ================= CHARGING TIME =================
    Tcharge(end+1) = KPI.t_PIR_to_DC_ready;

end

%% ================= CREATE TABLE =================
T = table(pIR_list', Vdip', Fdip', Ppeak', Tcharge',...
    'VariableNames',{'PIR','VoltageDip','FreqDip','PeakPower','ChargingTime'});

disp(T)

end