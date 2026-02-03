classdef GridCodeUnitTest < matlab.unittest.TestCase
    % This MATLAB unit test is used to run all the codes used in the
    % Grid-Code testing.
    % Copyright 2025 The MathWorks, Inc.
    properties
        modelname = "TestonBESSPVPlant";
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
        function GridCodeSimulateModel(testCase)
            % Test for the PV BESS example model
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
            % Run |.mlx| script
            testModelparameters
            reportOfGridCodeTest
        end
    end % methods (Test)
end % classdef