classdef AdmittanceScanHVDCWorkflowTest < BaseTest
    % This MATLAB unit test is used to run all the codes used in the
    % Design and Analysis of Admittance Scan HVDC example.
    % Copyright 2024-2025 The MathWorks, Inc.
    properties
        modelname = "HVDCScan";
    end
    
    methods (Test)
        function AdmittanceScanHVDCSimulateModel(testCase)
            % Test for the Admittance HVDC example model
            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));
            % Set parameters
            set_param(testCase.modelname, StopTime = "0.5")
            % Simulate model
            sim(testCase.modelname);
        end
        function HVDCScanRunLiveScript(testCase)
            % Test runs the main live script for VSC HVDC Scan 
            % Load system and add teardown
            load_system(testCase.modelname)
            testCase.addTeardown(@()close_system(testCase.modelname, 0));

            %suppress warnings
            warningID = 'Ident:estimation:tfestLowerOrder';
            warningState = warning('query', warningID);
            warning('off', warningID);
            testCase.addTeardown(@() warning(warningState.state,warningID));

            warningID2 = 'MATLAB:Axes:NegativeDataInLogAxis';
            warningState2 = warning('query', warningID2);
            warning('off', warningID2);
            testCase.addTeardown(@() warning(warningState2.state,warningID2));

            warningID3 = 'Ident:dataprocess:freqAboveNyquist';
            warningState3 = warning('query', warningID3);
            warning('off', warningID3);
            testCase.addTeardown(@() warning(warningState3.state,warningID3));

            % Set parameters
            set_param(testCase.modelname, StopTime = "6")
            % Run live script
            HVDCParameters
            VSCHVDCScanandStabilityAnalysis
        end
    end % methods (Test)
end % classdef