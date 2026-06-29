classdef BaseTest < matlab.unittest.TestCase
%Tester
    properties
        openfigureListBefore;
        openModelsBefore;
    end

    methods(TestMethodSetup)
        % This function will be executed before each test point runs
        function listOpenFigures(testCase)
            % List all open figures
            testCase.openfigureListBefore = findall(0,'Type','Figure');
        end

        function listOpenModels(testCase)
            % List all open simulink models
            testCase.openModelsBefore = get_param(Simulink.allBlockDiagrams('model'),'Name');
        end
    end

    methods(TestMethodTeardown)
        % This function will be executed after each test point runs
        function closeOpenedFigures(testCase)
            % Close all figure opened during test
            figureListAfter = findall(0,'Type','Figure');
            figuresOpenedByTest = setdiff(figureListAfter, testCase.openfigureListBefore);
            arrayfun(@close, figuresOpenedByTest);
        end

        function closeOpenedModels(testCase)
            % Close all models opened during test
            openModelsAfter = get_param(Simulink.allBlockDiagrams('model'),'Name');
            modelsOpenedByTest = setdiff(openModelsAfter, testCase.openModelsBefore);
            close_system(modelsOpenedByTest, 0);
        end
    end

end