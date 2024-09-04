if ~exist('simlogWindFarmGFMControl', 'var') || ...
        pm_simlogNeedsUpdate(simlogWindFarmGFMControl)
    sim('WindFarmGFMControlFast.slx')
end

% Reuse Power figure if it exists, else create new figure
if ~exist('simlogWindFarmGFMControlpower', 'var') || ...
        ~isgraphics(h1simlogWindGFMControlpower, 'figure')
     h1simlogWindGFMControlpower= figure('Name', 'h1simlogWindGFMControlpower');
end
figure(h1simlogWindGFMControlpower)
clf(h1simlogWindGFMControlpower)
WindFarmGFMControlplotCurvepower(out.logsWindGFMControl,scenarioNumber,Tsim)

% Reuse Voltage and current figures if it exists, else create new figures
if ~exist('h1simlogWindGFMControlVoltageCurrent', 'var') || ...
        ~isgraphics(h1simlogWindGFMControlVoltageCurrent, 'figure')
     h1simlogWindGFMControlVoltageCurrent= figure('Name', 'h1simlogWindGFMControlVoltageCurrent');
end
figure(h1simlogWindGFMControlVoltageCurrent)
clf(h1simlogWindGFMControlVoltageCurrent)
WindFarmGFMControlplotCurvevoltagefrequency(out.logsWindGFMControl,scenarioNumber,Tsim,control,code,tevent)