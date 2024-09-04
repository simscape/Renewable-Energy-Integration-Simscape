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
set_param('WindFarmGFMControl/Wind Farm','nGFM',0);
%%Simulate wind Power Change Scenario
scenarioNumber=1;
time.load=Tsim+1;
time.wind=tevent;
time.fault=Tsim+1;
time.island=Tsim+1;
time.lineTrip=Tsim+1;
islanded=0;
out=sim('WindFarmGFMControl','SrcWorkspace','current');
WindFarmGFMControlplotCurvevoltagefrequency(out.logsWindGFMControl,scenarioNumber,Tsim,' with Only Grid Following Controllers',code,tevent)
%%
%%With GFM
set_param('WindFarmGFMControl/Wind Farm','nGFM',2);
%%Weak Grid
scenarioNumber=1;
time.load=Tsim+1;
time.wind=tevent;
time.fault=Tsim+1;
time.island=Tsim+1;
time.lineTrip=Tsim+1;
islanded=0;
out=sim('WindFarmGFMControl','SrcWorkspace','current');
WindFarmGFMControlplotCurvevoltagefrequency(out.logsWindGFMControl,scenarioNumber,Tsim,' with M-GFM Wind Controllers',code,tevent)