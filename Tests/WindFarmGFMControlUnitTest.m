classdef WindFarmGFMControlUnitTest < matlab.unittest.TestCase
    % This MATLAB unit test is used to run all the codes used in the
    % Design and Analysis of Wind Farm GFM Control example.

    % Copyright 2024 The MathWorks, Inc.

    properties
        modelname = "WindFarmGFMControl";
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

        function WindFarmGFMControlSimulateModel(testCase)
            % Test for the WindFarmGFMControl example model

            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));

            % Set parameters
            set_param(testCase.modelname, StopTime = "0.5")

            % Simulate model
            sim(testCase.modelname);
        end

        function WindFarmGFMControlRunMLX(testCase)
            % Test runs the main |.mlx| for Wind Farm GFM control

            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));

            % Set parameters
            set_param(testCase.modelname, StopTime = "0.5")

            % Run |.mlx| script
            MWWindFarmwithGridformingControls
        end

    end % methods (Test)

end % classdef