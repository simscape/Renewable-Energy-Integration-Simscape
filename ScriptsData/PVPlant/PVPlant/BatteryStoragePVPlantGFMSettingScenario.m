%This function sets the parameters for the scenarios
%Copyright 2022 - 2023 The MathWorks, Inc.
function [y] = BatteryStoragePVPlantGFMSettingScenario(n,SimulationTime,t_event)
switch n
    case 4
      Fault_distance=0.99; %Fault created at x% of the line length from Solar Park
      Fault_instant=t_event;  %Fault instant in sec
      Fault_duration=0.1; %Fault clearing instant in sec
      Load_change_instant=SimulationTime+.1; %Load change instant
      PVpower_change_instant=SimulationTime+.1; %PV power change instant
      Grid_outage_instant=SimulationTime+.1; %Grid outage instant
      Line_trip=SimulationTime+.1; %Line trip instant
    case 5
      Fault_distance=0.99;    %Fault created at x% of the line length from Solar Park
      Fault_instant=t_event;   %Fault instant in sec
      Fault_duration=SimulationTime; %Fault clearing instant in sec
      Load_change_instant=SimulationTime+.1; %Load change instant
      PVpower_change_instant=SimulationTime+.1; %PV power change instant
      Grid_outage_instant=SimulationTime+.1; %Grid outage instant
      Line_trip=SimulationTime+.1; %Line trip instant
    case 2
      Fault_distance=0.99; %Fault created at x% of the line length from Solar Park
      Fault_instant=SimulationTime+.1;   %Fault instant in sec
      Fault_duration=SimulationTime+0.1; %Fault clearing instant in sec
      Load_change_instant=t_event; %Load change instant
      PVpower_change_instant=SimulationTime+.1; %PV power change instant
      Grid_outage_instant=SimulationTime+.1; %Grid outage instant
      Line_trip=SimulationTime+.1; %Line trip instant
    case 1
      Fault_distance=0.99; %Fault created at x% of the line length from Solar Park
      Fault_instant=SimulationTime+.1;   %Fault instant in sec
      Fault_duration=SimulationTime+0.1; %Fault clearing instant in sec
      Load_change_instant=SimulationTime+0.1; %Load change instant
      PVpower_change_instant=t_event; %PV power change instant
      Grid_outage_instant=SimulationTime+.1; %Grid outage instant
      Line_trip=SimulationTime+.1; %Line trip instant
    case 3
      Fault_distance=0.9; %Fault created at x% of the line length from Solar Park
      Fault_instant=SimulationTime+.1;   %Fault instant in sec
      Fault_duration=SimulationTime+0.1; %Fault clearing instant in sec
      Load_change_instant=SimulationTime+0.1; %Load change instant
      PVpower_change_instant=SimulationTime+0.1; %PV power change instant
      Grid_outage_instant=t_event; %Grid outage instant
      Line_trip=SimulationTime+.1;%Line trip time
    case 6
      Fault_distance=0.99;  %Fault created at x% of the line length from Solar Park
      Fault_instant=1.5;   %Fault instant in sec
      Fault_duration=SimulationTime+0.1; %Fault clearing instant in sec
      Load_change_instant=SimulationTime+0.1; %Load change instant
      PVpower_change_instant=SimulationTime+0.1; %PV power change instant
      Grid_outage_instant=SimulationTime+0.1; %Grid outage instant
      Line_trip=SimulationTime+0.1; %Line trip instant
    otherwise
      Fault_distance=0.99; %Fault created at x% of the line length from Solar Park
      Fault_instant=SimulationTime+.1;  %Fault instant in sec
      Fault_duration=0.1; %Fault clearing instant in sec
      Load_change_instant=SimulationTime+.1; %Load change instant
      PVpower_change_instant=SimulationTime+.1; %PV power change instant
      Grid_outage_instant=SimulationTime+.1; %Grid outage instant
      Line_trip=SimulationTime+.1; %Line trip instant
end 
y=[Fault_distance,Fault_instant,Fault_duration,Load_change_instant,PVpower_change_instant,Grid_outage_instant,Line_trip];
end