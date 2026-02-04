%% This script provides the parameters for the test harness used in grid code testing
% Copyright 2025 - 2026 The MathWorks, Inc.

SimulationTime = 40; % Time is (s)
BatteryStoragePVPlantGFMParameters;% PV and Battery plant parameters
GridModel = 2; % Grid model selection
BESSControl = 1; %Choose Grid Model 1 for grid forming VSM and 2 for Grid following V and F supporting control
GFMBatteryController.voltagref = 1.02; % Voltage reference of GFM
GFMBatteryController.voltagedroop = 1.01; % Reactive power Voltage droop
droop = 1 ; % Choose 1 for BESS GFM control using droop and 2 for VSM
% 1 - Synchronous Machine based ideal source (used for classical stability studies)
% 2 - Frequency-controlled three-phase voltage source (used for modern dynamic tests)
% For testing renewable energy sources (e.g., solar, wind, BESS), 
% Enabling frequency dynamics allows testing of frequency ride-through capability 
% and synthetic inertia response of inverter-based resources, as mandated in IEEE 2800, ENTSO-E, AEMO, and CEA grid codes.
%Generated Reference for Testing
%Initializes a test signal generator that produces voltage, frequency, active/reactive power time-series signals used to simulate disturbances, ramps, and transitions, ensuring the plant can respond appropriately to grid events.
ts = 0.001; % Sampling time of test signals
reference = DynamicSignalGenerator(ts);  % Signal generation for test cases
% Saving signals in a .mat file for using in simulations
reference.exportForSignalEditor("TestSignals.mat");
Grid.frequency = 60; % grid frequency in (Hz)
%%  Use any steady-state data to initialize
% Configure all signals for a flat run
testPr = 1*reference.Flat; %#ok<*NASGU>
testQr = 0.1*reference.Flat;
testVg = reference.Flat;
testF = Grid.frequency*reference.Flat;
testPhi = 0*reference.Flat;
Qtrack = 0; % Track a reactive power reference if 0 else control reactive power and voltage

