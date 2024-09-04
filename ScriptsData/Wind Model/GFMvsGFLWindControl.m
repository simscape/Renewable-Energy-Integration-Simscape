% Copyright 2023 The MathWorks, Inc.
%%Grid Code Setting 
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
%%Only Grid Following Control in Strong Grid
mdl='WindFarmGFMControl';
open_system(mdl);
%load('windGFLOp.mat');
Op=windGFLOp;
set_param('WindFarmGFMControl/Wind Farm/Wind Tuebine 1(GFM)','Commented','on');
set_param('WindFarmGFMControl/Wind Farm/Wind Tuebine 1(GFM)1','Commented','on');
set_param('WindFarmGFMControl/Wind Farm/Wind Tuebine 1(GFM)2','Commented','on');
set_param('WindFarmGFMControl/Wind Farm/Measurements1','Commented','on');
set_param('WindFarmGFMControl/Wind Farm/GSC Measurements','Commented','on');
set_param('WindFarmGFMControl/Wind Farm/RLC (Three-Phase)6','Commented','on');
set_param('WindFarmGFMControl/Wind Farm/RLC (Three-Phase)7','Commented','on');
set_param('WindFarmGFMControl/Wind Farm/RLC (Three-Phase)8','Commented','on');
set_param('WindFarmGFMControl/Wind Farm/Bus Selector2','Commented','on');
%%Simulate wind Power Change scenario
scenarioNumber=1;
time.load=Tsim+1;
time.wind=tevent;
time.fault=Tsim+1;
time.island=Tsim+1;
time.lineTrip=Tsim+1;
islanded=0;
simIn2 = Simulink.SimulationInput(mdl);
simIn2 = setModelParameter(simIn2,"StopTime","2.5");
simIn2 = setInitialState(simIn2,Op);
out=sim(simIn2);
WindFarmGFMControlplotCurvevoltagefrequency(out.logsWindGFMControl,scenarioNumber,Tsim,' with Only Grid Following Controllers',code)
%%
%%With GFM
mdl='WindFarmGFMControl';
open_system(mdl);
Op=turbineInertaRegulationOp;
set_param('WindFarmGFMControl/Wind Farm/Wind Tuebine 1(GFM)','Control','VSM Using Turbine Inertia');
set_param('WindFarmGFMControl/Wind Farm/Wind Tuebine 1(GFM)1','Control','VSM Using Turbine Inertia');
set_param('WindFarmGFMControl/Wind Farm/Wind Tuebine 1(GFM)2','Control','VSM Using Turbine Inertia');
set_param('WindFarmGFMControl/Wind Farm/Wind Tuebine 1(GFM)','Commented','off');
set_param('WindFarmGFMControl/Wind Farm/Wind Tuebine 1(GFM)1','Commented','off');
set_param('WindFarmGFMControl/Wind Farm/Wind Tuebine 1(GFM)2','Commented','off');
set_param('WindFarmGFMControl/Wind Farm/Measurements1','Commented','off');
set_param('WindFarmGFMControl/Wind Farm/GSC Measurements','Commented','off');
set_param('WindFarmGFMControl/Wind Farm/RLC (Three-Phase)6','Commented','off');
set_param('WindFarmGFMControl/Wind Farm/RLC (Three-Phase)7','Commented','off');
set_param('WindFarmGFMControl/Wind Farm/RLC (Three-Phase)8','Commented','off');
set_param('WindFarmGFMControl/Wind Farm/Bus Selector2','Commented','off');
simIn2 = Simulink.SimulationInput(mdl);
simIn2 = setModelParameter(simIn2,"StopTime","2.5");
simIn2 = setInitialState(simIn2,Op);
%%Weak Grid
scenarioNumber=1;
time.load=Tsim+1;
time.wind=tevent;
time.fault=Tsim+1;
time.island=Tsim+1;
time.lineTrip=Tsim+1;
islanded=0;
out=sim(simIn2);
WindFarmGFMControlplotCurvevoltagefrequency(out.logsWindGFMControl,scenarioNumber,Tsim,' with M-GFM Wind Controllers',code)