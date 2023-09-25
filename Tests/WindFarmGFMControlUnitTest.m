classdef WindFarmGFMControlUnitTest < matlab.unittest.TestCase
%% Class implementation of unit test


% Copyright 2023 The MathWorks, Inc.


methods (Test)
function WindFarmGFMControl_Test_1(~)
 close all
 bdclose all
 WindFarmGFMControlParameters
 load_system("WindFarmGFMControl.slx")
 set_param("WindFarmGFMControl",StopTime = "0.5")
 sim("WindFarmGFMControl.slx")
 close all
 bdclose all
end

function WindFarmGFMControl_Test_2(~)
 close all
 bdclose all
 load_system("WindFarmGFMControl.slx")
 set_param("WindFarmGFMControl",StopTime = "0.5")
 MWWindFarmwithGridformingControls
 close all
 bdclose all
end
end % methods (Test)
end % classdef