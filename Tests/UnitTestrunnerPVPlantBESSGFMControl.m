%% Script to run unit tests
% This script runs tests for component-level and system-level tests.
% Note that tests for detailed model applications are not run
% to avoid long-running tests.

% Copyright 2023 The MathWorks, Inc.

relStr = matlabRelease().Release;
disp("This is MATLAB " + relStr + ".")

topFolder = currentProject().RootFolder;

%% Create test suite

suite = matlab.unittest.TestSuite.fromFile(...
fullfile(topFolder, "Tests", "BatteryStoragePVPlantGFMControlUnitTest.m"));

%% Create test runner

runner = matlab.unittest.TestRunner.withTextOutput( ...
  OutputDetail = matlab.unittest.Verbosity.Detailed);
%% MATLAB Code Coverage Report

coverageReportFolder = fullfile(topFolder, "coverage" + relStr);
if not(isfolder(coverageReportFolder))
  mkdir(coverageReportFolder)
end

coverageReport = matlab.unittest.plugins.codecoverage.CoverageReport( ...
  coverageReportFolder, ...
  MainFile = "PV Plant and BESS with GFM Control Coverage" + relStr + ".html" );

plugin = matlab.unittest.plugins.CodeCoveragePlugin.forFile( ...
  [ ...
  fullfile(topFolder, "ScriptsData", "PVPlant", "BatteryStoragePVPlantGFMMainPage.mlx")
  fullfile(topFolder, "ScriptsData", "PVPlant", "BatteryStoragePVPlantGFMComparisonGFLvsGFM.m")
  fullfile(topFolder, "ScriptsData", "PVPlant","BatteryStoragePVPlantGFMParameters.m")          
    ], ...
  Producing = coverageReport );

addPlugin(runner, plugin)

%% Run tests
results = run(runner, suite);
out = assertSuccess(results);
disp(out);