% This code sets the parameters for the chossen Scenario and plot 
% the results
% Copyright 2022 - 2023 The MathWorks, Inc.
[Parameters] = BatteryStoragePVPlantGFMSettingScenario(Scenario.number,SimulationTime,Scenario.t_event);
%Secnario Parameters
Scenario.Fault_distance=Parameters(1);Scenario.Fault_time=Parameters(2);
Scenario.Fault_duration=Parameters(3);Scenario.Load_switching_time=Parameters(4);
Scenario.Solar_flactuation_time=Parameters(5);Scenario.Grid_outage_time=Parameters(6);
Scenario.Line_trip_time=Parameters(7);
% Generate new simulation results if they don't exist or if they need to be updated
if ~exist('simlog_ee_spv_park_battery', 'var') || portSetting.Scenario~=Scenario.number || portSetting.GridModel~=GridModel ||  ...
        portSetting.BESSControl~=BESSControl||portSetting.GridStrength~=GridStrength||portSetting.droop~=droop
    portSetting.Scenario=Scenario.number;
    portSetting.GridModel=GridModel;
    portSetting.BESSControl=BESSControl;
    portSetting.GridStrength=GridStrength;
    portSetting.droop=droop;
    sim('BatteryStoragePVPlantGFM.slx')
end

% Reuse Power figure if it exists, else create new figure
if ~exist('h1_simlog_ee_spv_park_battery', 'var') || ...
        ~isgraphics(h1_simlog_ee_spv_park_battery, 'figure')
     h1_simlog_ee_spv_park_battery= figure('Name', 'h1_simlog_ee_spv_park_battery');
end
figure(h1_simlog_ee_spv_park_battery)
clf(h1_simlog_ee_spv_park_battery)
BatteryStoragePVPlantGFMplotCurve_power(logs_ee_spv_park_battery,Scenario.number)

% Reuse Voltage and current figures if it exists, else create new figures
if ~exist('h1_simlog_ee_spv_park_battery_voltage_currents', 'var') || ...
        ~isgraphics(h1_simlog_ee_spv_park_battery_voltage_currents, 'figure')
     h1_simlog_ee_spv_park_battery_voltage_currents= figure('Name', 'h1_simlog_ee_spv_park_battery_voltage_currents');
end
figure(h1_simlog_ee_spv_park_battery_voltage_currents)
clf(h1_simlog_ee_spv_park_battery_voltage_currents)
BatteryStoragePVPlantGFMplotCurve_voltage_frequency(logs_ee_spv_park_battery,Scenario.number)
[SCRCal] = BatteryStoragePVPlantGFMSCRCal(Line,Feeder,Grid,SubTransmissionLine,PVpower); % Calculated SCR at POI