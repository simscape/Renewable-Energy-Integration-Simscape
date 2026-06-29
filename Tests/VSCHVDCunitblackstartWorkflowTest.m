classdef VSCHVDCunitblackstartWorkflowTest < BaseTest
    % This MATLAB unit test is used to run all the codes used in the
    % Design and Analysis of VSC HVDC example.
    % Copyright 2024-2025 The MathWorks, Inc.
    properties
        modelname = "VSCHVDCunitblackstart";
    end

    methods (Test)
        function VSCHVDCunitblackstartSimulateModel(testCase)
            % Test for the VSC HVDC unit blackstart example model
            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));
            % Set parameters
            set_param(testCase.modelname, StopTime = "0.5")
            % Simulate model
            sim(testCase.modelname);
        end
        function VSCHVDCunitblackstartRunLiveScript(testCase)
            % Test runs the main live script for VSC HVDC blackstart unit 
            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));

            % %suppress warning
            % warningID = 'Ident:estimation:tfestLowerOrder';
            % warningState = warning('query', warningID);
            % warning('off', warningID);
            % testCase.addTeardown(@() warning(warningState.state,warningID));

            % Set parameters
            set_param(testCase.modelname, StopTime = "25")
            % Run live script
            HVDCParameters
            Blackstart
        end
    end % methods (Test)
end % classdef