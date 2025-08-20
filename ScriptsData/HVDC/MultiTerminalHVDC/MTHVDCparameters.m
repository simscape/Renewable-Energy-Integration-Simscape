%% Simulation Parameters
% This file sets the parameters for all the blocks and variables used in the simulation model
%% Renewable plant parameters
BatteryStoragePVPlantGFMParameters;% PV and Battery plant parameters
WindFarmGFMControlParameters;% Wind plant parameters
% windTurbine.turbineRadius=90; % Turbine radius in m
% base.kV=4.16e3;
% base.mVA=50e6;                                                  %Base MVA
% base.z=(base.kV)^2/base.mVA; 
%% Configure Mppt parameters
% sweepTurbine;
% plotPowerCurves;
% mpptPower=maxPower*0.98;
% mpptWindSpeed=windSpeedv;
% mpptOmega=maxPowerRPM;
%% HVDC Station Parameters
HVDC.L=3.1e-5;
HVDC.C=0.085;
HVDC.Vdc=250e3;
HVDC.Vdcbase=10e3;
HVDC.Imaxpu=1.2;
windTransformer.hv1=HVDC.Vdc/(1.3*sqrt(2));
base.kV1=windTransformer.hv1;
grid.sensorTime=2*Ts;
Grid.governor_droop=1e-3;
Grid.H=0.1;%0.1;
Grid.MVA=80e6;%100e6;
%%%
%%
%% Admittance Scan parameters
scan.end=6;% time to end frequency scan
scan.start=2.0;% time to start frequency scan
scan.samplingfrequency=5e3;% Sampling frequency of frequency scan
scan.Vd=0.01;% Disturbance voltage magnitude in PU
scan.Vq=0.0;% Disturbance voltage magnitude in PU
scan.f=[1:1e4]/(2*pi); % Range of disturbance frequency in Hz
modelorder=4; % Model order to obtain a reduced ordered admittance model of the system
Tsim=scan.end+0.2;
%% Event timings
time.renewablevariation=11;% time to change renewable power
time.fault=11;% time to to create ac onshore fault
time.load=11;% time to change load power
time.dcfault=11;% time to create dc fault