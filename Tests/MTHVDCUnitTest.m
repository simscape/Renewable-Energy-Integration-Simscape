classdef MTHVDCUnitTest < matlab.unittest.TestCase
    % This MATLAB unit test is used to run all the codes used in the
    % Design and Analysis of Admittance Scan PRBS example.
    % Copyright 2024 The MathWorks, Inc.
    properties
        modelname = "HVDCMTGW";
        openfigureListBefore
    end
    methods(TestMethodSetup)
        function listOpenFigures(testCase)
            % List all open figures
            testCase.openfigureListBefore = findall(0,'Type','Figure');
        end
    end
    methods(TestMethodTeardown)
        function closeOpenedFigures(testCase)
            % Close all figure opened during test
            figureListAfter = findall(0,'Type','Figure');
            figuresOpenedByTest = setdiff(figureListAfter, testCase.openfigureListBefore);
            arrayfun(@close, figuresOpenedByTest);
        end
    end
    methods (Test)
        function MTHVDCSimulateModel(testCase)
            % Test for the HVDC offshore wind example model
            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));
            % Set parameters
            set_param(testCase.modelname, StopTime = "0.5")
            % Simulate model
            sim(testCase.modelname);
        end
        function TestHarnessRunMLX(testCase)
            % Test runs the main |.mlx| 
            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));

            %suppress warning
            warningID = 'Ident:estimation:tfestLowerOrder';
            warningState = warning('query', warningID);
            warning('off', warningID);
            testCase.addTeardown(@() warning(warningState.state,warningID));

            % Set parameters
            set_param(testCase.modelname, StopTime = "2.5")
            % Run |.mlx| script
            HVDCParameters
            MTHVDCModelDescription
        end
    end % methods (Test)
end % classdef