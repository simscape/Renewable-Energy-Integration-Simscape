%% Simulation Parameters
% This file sets the parameters for all the blocks and variables used in the 
% simulation model
% % Reuse Power figure if it exists, else create new figure
% PV Transformer Parameters
PVTransformer.lv=4.16e3;                     % PV transformer lv side L-L voltage in (V)
PVTransformer.hv=24.9e3;                     % PV transformer hv side L-L voltage in (V)
PVTransformer.VA=200e6;                      % PV transformer VA rating
PVTransformer.winding_resistance=0.002;      % winding resistance in (pu)
PVTransformer.winding_lekage_reactance=0.04; % winding lekage reactance in (pu)
PVTransformer.zero_sequence_reactance=0.1;   % winding zero sequence reactance in (pu) 
% *Simulation Time & Time Step*
SimulationTime=4; % Simulation duration in (sec)
Ts=5e-5;            % Simulation time step in (sec)
% *Grid  Parameters*
Grid.voltage=230e3;       % Supply L-L voltage 
Grid.frequency=60;        % Supply frequency in (Hz)
Grid.Rs=5e-1;             % Grid source resistance in (ohms)
Grid.Ls=3.5e-2;           % Grid source inductance in (Henry)
Grid.governor_droop=0.04; % Grid generator governor droop in (pu)
Grid.damping=0.2;         % Grid generator damping ratio 0.13
Grid.MVA=20e6;            % Grid generator MVA base
Grid.H=1.1;               % Grid generator inertia in (sec)
Grid.Pref=0.3;            % Grid generator real power reference 0.1
Grid.sensor_time=Ts;    % Speed sensor tim delay in (sec)
% *Grid Transformer Parameters*
GridTransformer.lv=24.9e3;                     % Grid transformer lv side L-L voltage in (V)
GridTransformer.hv=230e3;                      % Grid transformer hv side L-L voltage in (V)
GridTransformer.VA=100e6;                      % Grid transformer VA rating
GridTransformer.winding_resistance=0.0016;     % winding resistance in (pu)
GridTransformer.winding_lekage_reactance=0.08; % winding lekage reactance in (pu)
GridTransformer.zero_sequence_reactance=0.1;   % winding zero sequence reactance in (pu)
% *PV Inverter Parameters*
PVInverter.I_max_pu=1.2;                                    % Max current limit of inverter in (pu).
PVInverter.Vdc=PVTransformer.lv*sqrt(2)*2/(1*sqrt(3))*1.15; % Calculation of required dc voltage of inverter
PVInverter.C=8.5e-4;                                        % Inverter dc bus capacitance
PVInverter.L=3.1e-4;                                        % Inverter ac side filter inductance 
% PV Cell Parameters
%PV_cell Parameters
SolarCell.diode_saturation_current=3.15e-07; %Cell diod saturation current
SolarCell.solar_generated_current_AM=3.80;   %light generated current
SolarCell.quality_factor_i=1.4;              %Quality factor1
SolarCell.quality_factor_j=2;                %Quality factor2
SolarCell.series_resistance=0.0042;          %Cell series resistance
SolarCell.parallel_resistance=10.1;          %Cell parallel resistance
SolarCell.temp_cofficient=0.000805;          %Cell temperature cofficient
SolarCell.Eg=1.14;                           %Cell energy gap (eV)
SolarCell.temperature_exponent_Is1=3.38;     %Temperature exponent of solar cell
SolarCell.temperature_exponent_Is2=3;        %Temperature exponent of solar cell
SolarCell.temperature_exponent_Rs=0;         %Temperature exponent of solar cell
SolarCell.temperature_exponent_Rp=0;         %Temperature exponent of solar cell
SolarCell.measurement_temperature=25;        %Temperature of solar cell in celcius 
SolarCell.device_temperature=25;             %Simulation temperature in celcius 
% Solar Panel & Array Design
%Solar Panel with Vmpp ~ Vdc
Panel.n_series_cell_panel=150;        % Number of series cells in an panel
Panel.n_parallel_strings_panel=10;    % Number of parallel cells in an panel
%Solar Array for 50MWp
Array.n_series_panels_per_string=100; % Each string can produce 0.25 MWp Power
Array.n_parallel_strings=200;         % Number of parallel strings to produce 25 MWp Power
Array.insolation=800;                 % Solar insolation incident on the array
PVpower=Array.insolation*2*50e6/1e3;  % Total power from the PV Plant with two PV inveters and arrays
% MPPT Parameters
%MPP Parameters for perturb and observ method
Mpp.dv=PVInverter.Vdc*4e-3; % MPP voltage step size
Mpp.ts=0.5e-3;              % MPP sampling time
Mpp.td=1.1e-3;              % Mpp delay time
% *Base KV & MVA*
%Define base for PV controller design
Base.KV_base_new=4.16e3;
Base.MVA_base_new=50e6;
Base.z_base=(Base.KV_base_new)^2/Base.MVA_base_new;
% PV Controller Parameters
%Current controller PV inverter
PVController.t_sensor=50e-5; % Sensor time constant
PVController.Kp_ic=2;        % Proportional gain
PVController.Ki_ic=250;      % Integral gain
PVController.Kd=0;           % Derivative gain
% AC Voltage controller PV inverter
PVController.m_v=-1.06;      % Volatge controller gain
PVController.V_ref=1.01;     % Volatge controller reference
%DC bus Voltage_controller
PVController.Kp_v=4;         % Proportional gain
PVController.Ki_v=0.5;       % Integral gain
PVController.Kd_v=0.0;       % Derivative gain
PVController.Vdc_base=1e4;   % Dc side base voltage in (Volts)
% Battery Parameters
battery.v_cell=12;                                   % Each cell has a voltage of 12 volts
battery.ns_cell=500;                                 % Number of series cells
battery.vbat_nominal=battery.ns_cell*battery.v_cell; % Nominal battery voltage
battery.resistance=0.001;                            % in (Ohms)
battery.capacity=60e6/battery.vbat_nominal;          % in (Ahr) with energy capacity 60MWhr
battery.vbat_1=battery.vbat_nominal*0.998;           % Voltage V1 when charge is AH1
battery.charge_vbat1=(battery.capacity)*0.85;        % Charge when no-load voltage is V1
battery.power=35e6;                                  % Continuous power rating of the BESS in Watts (W)
battery.baseMVA=50e6;                                % MVA rating
% Grid Forming (GFM) VSM based Battery Controller Parameters
GFMBatteryController.P_ref=0.3;     % Real power referenceof Battery inverter
GFMBatteryController.Q_ref=0.1;     % Reactive power referance of Battery inverter
GFMBatteryController.L_bat=0.9e-3;  % Filter inductance of Battery inverter
GFMBatteryController.C_bat=4.5e-6;  % Filter capacitance of Battery inverter
GFMBatteryController.C_dc=0.5e-4;   % DC bus capacitance of Battery inverter
GFMBatteryController.V_ref=1;       % Reference Volatge in per-unit
GFMBatteryController.w_ref=1;       % Reference frequency in per-unit
GFMBatteryController.Sampletime=5e-5;   % Active power measurement filter time constant (sec)
GFMBatteryController.frequencydroop=0.02; % Droop in per-unit
GFMBatteryController.VSMInertia=0.25;     % VSM Inertia time constant (sec)
GFMBatteryController.Damping=0.2;         % VSM damping  0.2
GFMBatteryController.filtertimeconstant=0.00833;             % VSM real power filter time constant
GFMBatteryController.reactivepowerfiltertimeconstant=0.0166; % VSM reactive power filter time constant
GFMBatteryController.voltagedroop=1.05;                      % VSM voltage droop 1.05
GFMBatteryController.voltagecontrolki=5;                    % VSM voltage controller integral gain
GFMBatteryController.voltagecontrolkp=100;                    % VSM voltage controller proportional gain
GFMBatteryController.voltagecontroltimeconstant=3e-4;        % VSM voltage controller time constant
GFMBatteryController.currentcontrollersampletime=1e-4;       % VSM current controller time constant
GFMBatteryController.currentcontrollerkp=9.5e-5;             % VSM current controller proportional gain
GFMBatteryController.currentcontrollerki=0.0171;             % VSM current controller integral gain
GFMBatteryController.voltagsupportgain=3;
GFMBatteryController.voltagref=1.01;
GFMBatteryController.frequencymeastimeconstant=0.15;
GFMBatteryController.maximumvirtualimpedancecurrent=1.3;
GFMBatteryController.virtimeconstant=0.01;
% *Setting the Parameters of GFM VSM Battery Inverter*
BatteryInverter.activePower = battery.power*1e-3; % Refernce active power in (kW)
BatteryInverter.reactivePower = 10e3; % Refernce reactive power in (kVR)
BatteryInverter.frequency = 60; % Refernce frequency in (Hz)
BatteryInverter.DCVoltage = PVInverter.Vdc; % DC bus Volatge in (V)
BatteryInverter.lineRMSVoltage = 4.16e3; % AC voltage in (V)
% Base Values for Grid Forming (GFM) Controller
VSMbase.power = BatteryInverter.activePower;            % kW
VSMbase.frequency = BatteryInverter.frequency;          % Hz
VSMbase.lineVoltage = BatteryInverter.lineRMSVoltage;   % V
VSMbase.basePhasePower = VSMbase.power*1e3/3;           % kW
VSMbase.basePhaseVoltage = VSMbase.lineVoltage/sqrt(3); % kW
VSMbase.voltage = VSMbase.basePhaseVoltage*sqrt(2);
VSMbase.basePhaseCurrent = VSMbase.basePhasePower/VSMbase.basePhaseVoltage; % A
VSMbase.current = VSMbase.basePhaseCurrent*sqrt(2);
VSMbase.impedance = VSMbase.basePhaseVoltage/VSMbase.basePhaseCurrent; % A
VSMbase.inductance = VSMbase.impedance/(2*pi*VSMbase.frequency);       % H
VSMbase.capacitance = 1/(VSMbase.impedance*2*pi*VSMbase.frequency);    % F
BatteryInverter.droopControl.freqSlopeMp = 0.02;   % pu
BatteryInverter.droopControl.lpfTimeConst = 0.05; % s
% Lead-lag
BatteryInverter.droopControl.T2 = 0.006; %lead lag filter time constant
BatteryInverter.droopControl.T1 = 0.005; %lead lag filter time constant
%Filter Inductor 
BatteryInverter.L =GFMBatteryController.L_bat; %/base.inductance;
% Minimum DC Bus Voltage Required
% DC bus voltage required
BatteryInverter.power = complex(BatteryInverter.activePower,-1*BatteryInverter.reactivePower); % kW
BatteryInverter.complexrmsCurrent = BatteryInverter.power*1e3/(sqrt(3)*BatteryInverter.lineRMSVoltage); % A
BatteryInverter.reqComplexConverterVoltage = BatteryInverter.lineRMSVoltage/sqrt(3)+BatteryInverter.complexrmsCurrent*sqrt(-1)*...
    2*pi*BatteryInverter.frequency*BatteryInverter.L;
BatteryInverter.reqConverterPhaseVoltagePeak = abs(BatteryInverter.reqComplexConverterVoltage)*sqrt(2);
BatteryInverter.vsdRef = BatteryInverter.reqConverterPhaseVoltagePeak*3/2;
BatteryInverter.reqMinDCBusVoltage = BatteryInverter.reqConverterPhaseVoltagePeak*2;
%Current Limiting Method Virtual Impedance Method
BatteryInverter.currentLimit.virImpResistance = 0.1; % Virtual resistance
BatteryInverter.currentLimit.virImpXbyR = 10; % x/r ratio 15
BatteryInverter.currentLimit.overloadFactor = 1.1; % Overload factor
BatteryInverter.currentLimit.overNominalCurrent = 1.1; % Nominal current
% Current Limiting/Saturation Method
BatteryInverter.currentLimit.maxCurrentFactor = 1.2; % pu
BatteryInverter.currentLimit.currentIsdSaturationMax = BatteryInverter.currentLimit.maxCurrentFactor*abs(BatteryInverter.complexrmsCurrent)*1.5*sqrt(2); % Ohm
BatteryInverter.currentLimit.overCurrentIsdDelay = 10e-3;% sec
% Grid Following (GFL) BESS Controller Parameters
%BESS controller in grid following mode with voltage and frquency support
GFLBatteryController.m_v=2;     % Voltage droop gain of BESS inverter
GFLBatteryController.m_p=15e6;  % Frequency droop for BESS inverter MW per Hz
GFLBatteryController.Td=3e-3; % Time delay in sec for BESS inverter frequency & voltage sensig 
%BESS controller Priority
GFLBatteryController.Priority=1; % Set 1 for active power priority and 0 for reactive power priority mode
%Reference Power and Voltage
GFLBatteryController.P_ref=30e6;  % in Watts
GFLBatteryController.Q_ref=10e4;  % in Watts
GFLBatteryController.V_ref=1.0;   % in per-unit
GFLBatteryController.f_ref=Grid.frequency; % in Hz
% Syncronous Machine Parameters 
%SM parameters
SM.MVA=500e6;    % MVA rating of synchronous machine
SM.Voltage=24e3; % Voltage rating of synchronous machine
SM.polepairs=1;  % Number of pole pairs of synchronous machine
SM.w_sm=2*pi*Grid.frequency;  % Nominal frequency 0f synchronous machine
SM.field_current=1300;        % Field current rating of synchronous machine
SM.Base_Torque_SM=SM.MVA/SM.w_sm; % Torque rating of synchronous machine
SM.initial_torque=0.15;       % Initial torque of synchronous machine
SM.initial_Pe=30e6;           % Initial real power output of synchronous machine
SM.initial_Qe=1e3;            % Initial reactive power output of synchronous machine
SM.stator_resistance=0.003;   % Stator resistance of synchronous machine
SM.lekage_reactance=0.15;     % Lekage reactance of synchronous machine
SM.xd=1.81;                   % d-axis reactance
SM.xq=1.76;                   % q-axis reactance
SM.xd_=0.3;                   % d-axis transient reactance
SM.xq_=0.65;                  % q-axis transient reactance
SM.xd_dash=0.23;              % d-axis sub-transient reactance
SM.xq_dash=0.25;              % q-axis sub-transient reactance
SM.Tdo_=8;                    % d-axis transient time constant
SM.Tdo_dash=0.03;             % d-axis sub-transient time constant
SM.Tqo_=1;                    % q-axis transient time constant
SM.Tqo_dash=0.07;             % q-axis sub-transient time constant
SM.inertia=2.525;             % Inertia constant of machine
SM.damping=0.01;              % Damping constant of machine
%Governor
SM.speed_reference=0.985;     % Speed reference of machine
SM.droop_p=5;                 % Droop cofficient of machine
SM.load_reference_set_point=0.5; % Load reference set point of machine
SM.governor_time_constant=0.2;   % Governer time constant
SM.time_constsnt_steamchest=0.3; % Steam chest time constant
%Load connected to Synchronous Machine 
SM.P_load=40e6;   % Real power of load connected to machine
SM.Q_load=3e3;    % Reactive power of load connected to machine
% *PLL Parameters*
PLL.Kp_pll=100;   % Proportional gain
PLL.Ki_pll=1000;  % Integral gain
% Transmission Line Parameters
Line.l_km=5;        % Line length in Km 
Line.r_l=0.03;      % Resistance in Ohms per Km
Line.L_l=0.6;       % Inductance in mH per Km
Line.M_l=0.1;       % Mutual inductance in mH per Km
Line.C_ll=1.731e-2; % Capacitance line to line in micr0-farad per Km
Line.C_lg=6.751e-1; % Line to ground capacitance in micro-farad per Km
Line.Mr=0;          % Line mutual resistance in ohms per km
% Feeder Parameters
Feeder.R_f=0.16;              % Feeder resistance in Ohms per Km
Feeder.L_f=3.1e-4;            % Feeder inductance in Henry per Km 
Feeder.lengthFirstHalf=0.05;  % Feeder length in Km 
Feeder.lengthSecondHalf=0.6;  % Feeder length in Km               
GridStrength=1;               % Grid Condition 0 for weak grid 1 for strong grid
% Sub-transmission Line Parameters
SubTransmissionLine.R=0.08;     % line resistance in Ohms per Km
SubTransmissionLine.L=2.1e-4;   % line inductance in Henry per Km
SubTransmissionLine.length=0.3; % length in Km 
% Load Parameters
Load.P1=60e6; % Real power of load connected at 4.16 kV feeder
Load.Q1=3e3;  % Reactive power of load connected at 4.16 kV feeder
Load.P2=40e6; % Real power of load connected at 4.16 kV feeder
Load.Q2=1e3;  % Reactive power of load connected at 4.16 kV feeder
%Load2 switching
Load2CB_initial=1; % Default initially disconnected
Load2CB_final=0;   % Connected at t_event
% Grid Strength Evaluation
% The function |eeBatteryStoragePVPlantGFMSCRCal|, calculates the shor circuit 
% ration (SCR) at the POI.
[SCRCal] = BatteryStoragePVPlantGFMSCRCal(Line,Feeder,Grid,SubTransmissionLine,PVpower); % SCR calculation function
% Voltage Ride Through Characteristics 
%Including LVRT & Transient over voltage ride through characteristics: Volatge (PU) vs Tripping Time (sec) 
%(Following the IEEE 2800 standards)
LVRT.time_y=[0.32,0.32,0.32,1.2,3,6,inf,inf,1800,1,1,0.015,0.003,0.001,0.0002]; % Trip time vs Volatge (PU)
LVRT.voltage_x=[0,0.1,0.25,0.5,0.7,0.9,0.91,1.05,1.051,1.11,1.19,1.2,1.4,1.6,1.7];
%Volatge vs Reactive Current Injection (Following the German Grid Code)
LVRT.iq_y=[1,1,0.2,0,0];  % Reactive current vs Volatge (PU)
LVRT.volatge_iq_x=[0,.5,.9,.91,1];
%% 
% *Frequency Ride Through Characteristics* 
%Frequency Ride Through characteristics: Frequency (Hz) vs Tripping Time (sec) (Following the IEEE 2800 standards)
fRT.time_y=[0.1,299,inf,299,299,0.1,0.1];
fRT.frequency_x=([-0.2,-0.05,-0.02,0.021,0.03,0.031,0.2]+1)*Grid.frequency;
%% 
% *Grid Source Model Selection*
GridModel=2; %Choose Grid Model 1 for SM and 2 for thre-phase frequency controlled source
SynchronousMachine=Simulink.Variant(' GridModel == 1 ');
VSMFrequencyControlledSource =Simulink.Variant(' GridModel == 2 ');
%% 
% *BESS Controller Selection*
%Default mode is VSM controller
BESSControl=2; %Choose Grid Model 1 for grid forming VSM and 2 for Grid following V and F supporting control
BESSVSMControl=Simulink.Variant(' BESSControl == 1 ');
BESSGridSupporting =Simulink.Variant(' BESSControl == 2 ');
%% 
% *Simulation Scenario*
%Choose the Scenario to Simulate 
Scenario.number=2;    % Default case is load change
Scenario.t_event=1.5; % Time at which the event is triggered
[Parameters] =BatteryStoragePVPlantGFMSettingScenario(Scenario.number,SimulationTime,Scenario.t_event);
%Secnerio Parameters
Scenario.Fault_distance=Parameters(1);Scenario.Fault_time=Parameters(2);
Scenario.Fault_duration=Parameters(3);Scenario.Load_switching_time=Parameters(4);
Scenario.Solar_flactuation_time=Parameters(5);Scenario.Grid_outage_time=Parameters(6);
Scenario.Line_trip_time=Parameters(7);
portSetting.Scenario=0;    % Default port setting 
portSetting.GridModel=1;   % Default grid source model is frequency controlled source
portSetting.BESSControl=0; % Default BESS controller is VSM GFM
portSetting.GridStrength=0; GridStrength=0; % Default grid is a weak grid with SCR=0.4           
%% 
% *IEEE 2800 Standards Compliance Table*
TableIII=readtable('BatteryStoragePVPlantGFMTableComplianceIEEEStd.xlsx','VariableNamingRule', 'preserve');
TableIII.('Satisfied'){1}= char(hex2dec('2713'));
TableIII.('Satisfied'){2}= char(hex2dec('2713'));
TableIII.('Satisfied'){3}= char(hex2dec('2713'));
TableIII.('Satisfied'){4}= char(hex2dec('2713'));
TableIII.('Satisfied'){5}= char(hex2dec('2713'));
TableIII=table(TableIII,'VariableNames',{'Table: Compliance with IEEE 2800 Standards [1]'});