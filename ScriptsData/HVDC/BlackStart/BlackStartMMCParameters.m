%% Parameters for Black starting using Offshore Wind Farms and Modular Multilevel Converters 
%% High-Voltage Direct-Current Transmission
% Copyright 2024 The MathWorks, Inc.

%% AC grid

VgridRated = 230e3; % V, rms line-to-line, grid-side rated voltage
VRated = 200e3; % V, rms line-to-line, converter-side rated voltage
FRated = 60; % Hz, grid frequency
PRated = 400e6; % VA, rated power

%% Transformer

Pnom = PRated; % VA, nominal power
Vt1 = VgridRated; % V, rms line-to-line, primary rated voltage
Vt2 = VRated; % V, rms line-to-line, secondary rated voltage  
Rt = 0.004; % pu, transformer total resistance
Lt = 0.15; % pu, transformer total leakage inductance

%% Base values

Pbase = PRated; % base power
Vbase = VRated/sqrt(3)*sqrt(2); % base voltage
wbase = 2*pi*FRated; % base radial frequency 
Ibase = Pbase/(1.5*Vbase); % base current
Zbase = Vbase/Ibase; % base impedance
Lbase = Zbase/wbase; % base inductance
Cbase = (1/Zbase)/wbase; % base capacitance
VdcRated = 400e3; % rated DC voltage
Idcbase = Pbase/VdcRated; % base DC current

%% PIR parameter
Tpir =15; % time is s
rpir = 0.15; % Pre-insertion resistance

fsw = 3*FRated; % Hz, switching frequency
Nm = 24; % Number of power submodule per arm
W = 80; % kJ/MVA, stored energy
Cm = W*1e3*(PRated*1e-6)/(0.5*(VdcRated/Nm)^2*Nm*6); % F, power submodule capacitance

%% Reactor and filters

Rr = 0.002; % pu, reactor resistance
Lr = 0.15; % pu, reactor inductance
Cf = 1/((Lr*Lbase)*(2*pi*(2*FRated))^2);
Rf = 1/(wbase*Cf)*(40);
Cdc = 10e-6;
Rdc = 1e-3;
Rc = 0.9; % Ohm, equivalent cable resistance
Ts = 5e-5; % fundamental sample time
Tsc = Ts; % s, control sample time
