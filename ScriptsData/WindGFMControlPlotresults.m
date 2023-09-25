% Copyright 2023 The MathWorks, Inc.
if(gridCode=="IEEE 2800")
    code.vl=0.9;
    code.vh=1.1;
    code.fl=58.8;
    code.fh=61.2;
    lvrt.time=[0.32,0.32,0.32,1.2,3,6,inf,inf,1800,1,1,0.015,0.003,0.001,0.0002]; % Trip time vs Volatge (PU)
    lvrt.voltage=[0,0.1,0.25,0.5,0.7,0.9,0.91,1.05,1.051,1.11,1.19,1.2,1.4,1.6,1.7];
end
if(gridCode=="ERI GRID")
    code.vl=0.9;
    code.vh=1.14;
    lvrt.time=[0.15,0.15,0.45,0.45,0.45,inf]; % Trip time vs Volatge (PU)
    lvrt.voltage=[0,0.499,0.5,0.899,0.9,0.901];
end

if ~exist('out.simlogWindFarmGFMControl', 'var') || portSetting.scenario~=scenarioNumber||feeder.length~=portSetting.feederlength||...
        pm_simlogNeedsUpdate(simlogWindFarmGFMControl)
    portSetting.scenario=scenarioNumber;
    portSetting.feederlength=feeder.length;
    out=sim("WindFarmGFMControl",'SrcWorkspace','current');
end
% Reuse Voltage and current figures if it exists, else create new figures
if ~exist('h1simlogWindGFMControlVoltageCurrent', 'var') || ...
        ~isgraphics(h1simlogWindGFMControlVoltageCurrent, 'figure')
     h1simlogWindGFMControlVoltageCurrent= figure('Name', 'h1simlogWindGFMControlVoltageCurrent');
end
figure(h1simlogWindGFMControlVoltageCurrent)
clf(h1simlogWindGFMControlVoltageCurrent)
WindFarmGFMControlplotCurvevoltagefrequency(out.logsWindGFMControl,scenarioNumber,Tsim,wController,code,tevent)
% Reuse Power figure if it exists, else create new figure
if ~exist('simlogWindFarmGFMControlpower', 'var') || ...
        ~isgraphics(h1simlogWindGFMControlpower, 'figure')
     h1simlogWindGFMControlpower= figure('Name', 'h1simlogWindGFMControlpower');
end
figure(h1simlogWindGFMControlpower)
clf(h1simlogWindGFMControlpower)
WindFarmGFMControlplotCurvepower(out.logsWindGFMControl,scenarioNumber,Tsim)