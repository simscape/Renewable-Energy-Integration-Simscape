classdef AdmittanceScanPRBSHarnessTest < BaseTest
    % This MATLAB unit test is used to run all the codes used in the
    % Design and Analysis of Admittance Scan PRBS example.
    % Copyright 2024-2025 The MathWorks, Inc.
    properties
        modelname = "TestHarness";
    end
    
    methods (Test)
        function AdmittanceScanSimulateModel(testCase)
            % Test for the AdmittanceScanPRBS example model
            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));
            % Set parameters
            set_param(testCase.modelname, StopTime = "0.5")
            % Simulate model
            sim(testCase.modelname);
        end
        function TestHarnessRunMLX(testCase)
            % Test runs the main |.mlx| for AdmittanceScanPRBS control
            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));

            %suppress warning
            warningID = 'Ident:estimation:tfestLowerOrder';
            warningState = warning('query', warningID);
            warning('off', warningID);
            testCase.addTeardown(@() warning(warningState.state,warningID));

            % Set parameters
            set_param(testCase.modelname, StopTime = "10.5")
            % Run |.mlx| script
            Harnessparm
            TestHarnessDescription
        end
    end % methods (Test)
end % classdef