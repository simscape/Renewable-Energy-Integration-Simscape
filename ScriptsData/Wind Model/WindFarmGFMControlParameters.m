% Copyright 2023 The MathWorks, Inc.
%% Simulation Parameters
T=5e-5;                % Step size [s]
Ts=5e-5;               % Control time step [s]
Tsim=10;               % Simulation time span
tevent=5;              % Time [s] at which events are triggered
time.fault=Tsim+1;     % Fault instant [s]
time.load=Tsim+1;      % load change instant [s]
time.wind=Tsim+1;      % Wind velocity instant [s]
time.island=Tsim+1;    % Islanded instant [s]
time.lineTrip=Tsim+1;  % Line trip instant [s]
islanded=0;            % Flag on islanding 
%% Wind Transformer
windTransformer.lv=4.16e3;  % Wind transformer lv side L-L voltage in V
windTransformer.hv=230e3;   % Wind transformer hv side L-L voltage in V
windTransformer.va=200e6;   % Wind transformer VA rating
windTransformer.windingResistance=0.002;     % Winding resistance in pu
windTransformer.windingLekageReactance=0.04; % Winding lekage reactance in pu
windTransformer.zeroSequenceReactance=0.1;   % Winding zero sequence reactance in pu 
%% Grid Parameters
grid.voltage=230e3; % Actual supply L-L voltage used for simulating the system,
grid.frequency=60;  % Supply frequency in Hz
grid.rs=0.01;       % Grid source resistance in ohms 0.01;
grid.ls=0.3e-3;     % Grid source inductance in Henry 3e-3;
%%Grid Parameters
grid.voltage=0.98*230e3;  % Supply L-L voltage           
grid.governorDroop=0.1/(2*pi*grid.frequency); % Grid generator governor droop in (pu)
grid.damping=0.2;         % Grid generator damping ratio 
grid.mva=100e6;           % Grid generator VA base
grid.H=0.4;               % Grid generator inertia in (sec)
grid.pRef=0.5;            % Grid generator real power reference 
grid.sensorTime=8e-5;     % Speed sensor tim delay in (sec)
%% Parameters of Wind Turbine
load('wind_turbine_Cp.mat')                 % Loading wind turbine power coefficient table
load('wind_MPPT.mat')                       % Loading MPPT characteristics -power/omega vs wind speed                                                        
load('wind_derating.mat')                   % Loading derating table - wind speed vs pitch angle
% Rotor hub parameters
windTurbine.turbineRadius               = 83;                        % (m) Turbine radius
windTurbine.inertia                     = 3.2e8;                     % Inertia in kgm^2
windTurbine.airDensity                  = 1.225;                     % (kg/m^3) Air density
windTurbine.vWindThreshold              = 0.01;                      % (m/s) Threshold wind velocity to avoid divison by zero in Tip Speed Ratio calculation
windTurbine.wThreshold                  = 0.01;                      % (rad/s) Threshold wind turbine velocity for numerical convergence
windTurbine.cpBraking                   = -0.001;                    % Power coefficient for aerodynamic braking
windTurbine.turbineRatedPower           = 12.5;                       % Power turbine rated power
% Turbine state machine parameters
windTurbine.vWindCutInLower             = 4;                            % (m/s) Cut in lower wind speed
windTurbine.vWindCutOut                 = 23;                           % (m/s) Cut out wind speed
windTurbine.vWindCutInUpper             = 0.9*windTurbine.vWindCutOut;  % (m/s) Cut in upper wind speed
windTurbine.vWindRated                  = 12;                           % (m/s) Rated wind speed
% Extending power coefficient table in aerodynamic pitch brake region
windTurbine.numTSR                      = size(cp,2);                % Estimating size of power coefficient table
windTurbine.pitch                       = [pitch,90,95];             % (deg) Extending pitch angle vector to brake region
windTurbine.cp                          = [cp;windTurbine.cpBraking*ones(2,windTurbine.numTSR)]; % Power coefficient table extension to braking region
windTurbine.TSR                         = TSR;
%% 
% *Wind Inverter Parameters*
windInverter.imaxPU=1.2/6;                                      % Max current limit of inverter in (pu).
windInverter.vdc=windTransformer.lv*sqrt(2)*2/(1*sqrt(3))*1.25; % Calculation of required dc voltage of inverter
windInverter.c=1e-2;                                            % Inverter dc bus capacitance
windInverter.l=(2*0.5e-3);                                      % Inverter ac side filter inductance
windInverter.cFilter=1.1e-3;                                    % Inverter ac side filter capacitance 
%Define base for Wind controller design
base.kV=4.16e3;                                                 %Base KV
base.mVA=50e6;                                                  %Base MVA
base.z=(base.kV)^2/base.mVA;                                    %Base impedance
%% Wind Controller Parameters
%Current controller Wind inverter
windController.tSensor=2e-5; % Sensor time constant
windController.kpic=1.5;       % Proportional gain
windController.kiic=250;     % Integral gain
windController.kd=0;         % Derivative gain
% AC Voltage controller Wind inverter
windController.mv=0.05;       % Volatge controller gain
windController.vRef=1.0;      % Volatge controller reference
%DC bus Voltage_controller
windController.kpv=4;         % Proportional gain
windController.kiv=0.5;       % Integral gain
windController.kdv=0.0;       % Derivative gain
windController.vdcBase=1e3;   % Dc side base voltage in (Volts)
%GFM wind controller parameters
windController.kpvgfm=0.05; %Voltage controller proportional gain
windController.kivgfm=0.3;  %Voltage controller integral gain
windController.kdvgfm=0;    %Voltage controller derevative gain
%% GFM using Dc link voltage control by GSC (G-GFM)
%Parameters of G-GFM Transfer function 
gGFM.kt=10.5;      %GFM tracking cofficient
gGFM.kj=0.05;      %GFM inertia cofficient
gGFM.kd=100;         %GFM damping cofficient
gGFMTf=tf([1 gGFM.kt],[gGFM.kj gGFM.kd]); % G-GFM Real power vs Frequency Transfer function
%Converting the Transfer Function Parameters to descrete domain
gGFMTfz=c2d(gGFMTf,Ts/10);
%Reactive Power and Current Limiter Parameters 
gGFM.qref=0.01;     %GFM reactive power reference
gGFM.kq=0.3;        %GFM reactive power droop cofficient
gGFM.vref=1.0;     %GFM voltage reference
gGFM.fref=60;       %GFM frequency reference
gGFM.Imax=0.4;      %Current limit
gGFM.x_vir=3e-1;    %Virtual reactance
gGFM.r_vir=5e-2;  %Virtual resistance
%% GFM MSC (M-GFM)
mGFM.d=0.7;        %GFM damping cofficient
mGFM.h=0.1;        %GFM inertia cofficient
mGFM.kp=0.07;        %GFM active power droop cofficient
mGFM.kq=1.95;      %GFM reactive power droop cofficient
mGFM.Vd=1.0;       %GFM voltage reference
mGFM.fref=60;      %GFM frequency reference
mGFM.kpdc=0.3;     %DC bus voltage controller proportional gain
mGFM.kidc=0.8;     %DC bus voltage controller integral gain 0.2
mGFM.Imax=0.35;    %Current Limit
mGFM.x_vir=0.3;    %Virtual reactance
mGFM.r_vir=0.05;   %Virtual resistance

%% Machine Parameters
pmsm.pmax = 12.5e6;  % Maximum power                   [W]
pmsm.ld   = 1.6e-3; % Stator d-axis inductance        [H]
pmsm.lq   = 1.6e-3; % Stator q-axis inductance        [H]
pmsm.rs   = 8.2e-4; % Stator resistance per phase     [Ohm]
pmsm.psim = 9;      % Permanent magnet flux linkage   [Wb]
pmsm.p    = 26;     % Number of pole pairs
pmsm.alpha=6000;    % pmsm Current controller cofficient
%% Transmission Line Parameters
line.r=0.03;      % Resistance in Ohms per Km
line.l=0.6;       % Inductance in mH per Km
line.m=0.1;       % Mutual inductance in mH per Km
line.cll=1.731e-2;% Capacitance line to line in micr0-farad per Km
line.clg=6.751e-2;% Line to ground capacitance in micro-farad per Km
line.mr=0;        % Line mutual resistance in ohms per km
line.length1=100; % Line length in Km
%% Feeder Parameters
feeder.r=0.026;           % Feeder resistance in Ohms per Km
feeder.l=2.1e-4;          % Feeder inductance in Henry per Km 
feeder.length=0.5;        % Feeder length in Km
%% Loads
loads.P1=5e6;  %Load 1 real power
loads.Q1=1e6;  %Load 1 reactive power
loads.P2=1e6;  %Load 2 real power
%% Grid Code Settings
%(Following the IEEE 2800 standards)
lvrt.time=[0.32,0.32,0.32,1.2,3,6,inf,inf,1800,1,1,0.015,0.003,0.001,0.0002]; % Trip time vs Volatge (PU)
lvrt.voltage=[0,0.1,0.25,0.5,0.7,0.9,0.91,1.05,1.051,1.11,1.19,1.2,1.4,1.6,1.7];
%Volatge vs Reactive Current Injection (Following the German Grid Code)
lvrt.iq=[1,1,0.2,0,0];  % Reactive current vs Volatge (PU)
lvrt.voltageiq=[0,.5,.9,.91,1];
% Frequency Ride Through characteristics: Frequency (Hz) vs Tripping Time (sec) (Following the IEEE 2800 standards)
frt.time=[0.1,299,inf,299,299,0.1,0.1];
frt.frequency=([-0.2,-0.05,-0.02,0.021,0.03,0.031,0.2]+1)*grid.frequency;
code.vh=1.1;          %Voltage upper limit
code.vl=0.9;          %Voltage lower limit
code.fh=61.2;         %Frequency upper limit
code.fl=58.8;         %Frequency lower limit
gridCode="IEEE 2800"; %Default grid code for tests
%% PLL Parameteters
pll.kp=100;  %Proportional PLL gain
pll.ki=2000; %Integral PLL gain
WindControl=1; %Choose Grid Model 1 for grid forming G-GFM and 2 for M-GFM control
WindVSMControlDClink=Simulink.Variant(' WindControl == 1 ');
WindVSMControlTurbineInertia =Simulink.Variant(' WindControl == 2 ');
%% Standard Compliance Table
TableIII=readtable('BatteryStoragePVPlantGFMTableComplianceIEEEStd.xlsx','VariableNamingRule', 'preserve');
TableIII.('Satisfied'){1}= char(hex2dec('2713'));
TableIII.('Satisfied'){2}= char(hex2dec('2713'));
TableIII.('Satisfied'){3}= char(hex2dec('2713'));
TableIII.('Satisfied'){4}= char(hex2dec('2713'));
TableIII.('Satisfied'){5}= char(hex2dec('2713'));
TableIII=table(TableIII,'VariableNames',{'Table: Compliance on Key Criteria mentioned in Standards'});
%% Initilazation of model with GGFM control as default wind GFM Controller
imGFM=0; %Set flag to 1 for initating the initilization process with MGFM control
%%