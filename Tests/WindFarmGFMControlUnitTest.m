classdef WindFarmGFMControlUnitTest < matlab.unittest.TestCase
%% Class implementation of unit test


% Copyright 2023 The MathWorks, Inc.


methods (Test)


%% Utility > SignalDesigner folder


function WindFarmGFMControl_Test_1(~)
 close all
 bdclose all
 WindFarmGFMControlParametersFast
 load_system("WindFarmGFMControlFast.slx")
 set_param("WindFarmGFMControlFast",StopTime = "0.5")
 sim("WindFarmGFMControlFast.slx")
 close all
 bdclose all
end

function WindFarmGFMControl_Test_2(~)
 close all
 bdclose all
 load_system("WindFarmGFMControlFast.slx")
 set_param("WindFarmGFMControlFast",StopTime = "0.5")
 MWWindFarmwithGridformingControls
 close all
 bdclose all
end
end % methods (Test)
end % classdef