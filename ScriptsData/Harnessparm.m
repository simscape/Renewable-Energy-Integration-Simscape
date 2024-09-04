%% Test Harness parameters
%% Grid Parameters
grid.voltage=4.16e3; % Actual supply L-L voltage used for simulating the system,
grid.frequency=60;   % Supply frequency in Hz
grid.rs=1e-3;        % Grid source resistance in ohms 0.01;
grid.ls=0e-3;        % Grid source inductance in Henry 3e-3;
%% Star Connected Load Parameters
loadl.l=10e-3; % Load inductance in H
loadl.c=1e-3;  % Load capacitance in F
loadl.r=1e-2;  % Load resistance in Ohms 
fres=1/(2*pi*sqrt(loadl.c*(grid.ls+loadl.l))); % Resonance frequency of load
%% Admittance Scan parameters
scan.end=10.5;% time to end frequency scan
scan.start=1.5;% time to start frequency scan
scan.samplingfrequency=5e3;% Sampling frequency of frequency scan
scan.Vd=0.01;% Disturbance voltage magnitude in PU
scan.Vq=0.0;% Disturbance voltage magnitude in PU
scan.f=[1:1e4]/(2*pi); % Range of disturbance frequency in Hz
modelorder=4; % Model order to obtain a reduced ordered admittance model of the system
%% PLL Parameters
pll.kp=100;  %Proportional PLL gain
pll.ki=2000; %Integral PLL gain 
%% Define base of system
base.kV=4.16e3; %Base in KV
base.mVA=50e6;  %Base MVA
base.z=(base.kV)^2/base.mVA; % Base Impedance in Ohms
%%Chose Resource to test
Choice=1; % Test for RLC load
%% Parameters for GFL BESS
BatteryStoragePVPlantGFMParameters;
%% Simulation Time Step
Ts=5e-5; % Sample Time in sec
