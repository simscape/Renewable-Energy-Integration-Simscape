classdef BatteryStoragePVPlantGFMControlUnitTest < matlab.unittest.TestCase
    %% Class implementation of unit test
    % Copyright 2023 The MathWorks, Inc.

    properties
        modelname = "BatteryStoragePVPlantGFM";
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