classdef BatteryStoragePVPlantGFMWorkflowTest < BaseTest
    %% Class implementation of unit test
    % Copyright 2023-2025 The MathWorks, Inc.

    properties
        modelname = "BatteryStoragePVPlantGFM";
    end

    methods (Test)
        function SolarGFMControlModelTest(testCase)
            %BatteryStoragePVPlantGFMParameters
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));
            set_param(testCase.modelname,StopTime = "0.5")
            sim(testCase.modelname)
        end

        function SolarGFMControlMlxTest(~)
            BatteryStoragePVPlantGFMMainPage
        end
    end % methods (Test)
end