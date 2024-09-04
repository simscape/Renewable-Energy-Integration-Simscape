%% Script to run unit tests
% This script runs tests for component-level and system-level tests.
% Note that tests for detailed model applications are not run
% to avoid long-running tests.
% Copyright 2024 The MathWorks, Inc.
relStr = matlabRelease().Release;
disp("This is MATLAB " + relStr + ".")
topFolder = currentProject().RootFolder;
%% Create test suite
suite = matlab.unittest.TestSuite.fromFile(...
    fullfile(topFolder, "Tests", "AdmittanceScanPRBSUnitTest.m"));
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
    MainFile = "Wind Farm with GFM Control Coverage" + relStr + ".html" );
plugin = matlab.unittest.plugins.CodeCoveragePlugin.forFile(...
    [...
    fullfile(topFolder, "ScriptsData", "TestHarnessDescription.mlx")...
    fullfile(topFolder, "ScriptsData", "ad.m")], ...
    Producing = coverageReport );
addPlugin(runner, plugin)
%% Run tests
results = run(runner, suite);
out = assertSuccess(results);
disp(out);
 %% Script to run unit tests
% This script runs tests for component-level and system-level tests.
% Note that tests for detailed model applications are not run
% to aoivd long-running tests.

% Copyright 2021-2023 The MathWorks, Inc.

relStr = matlabRelease().Release;
disp("This is MATLAB " + relStr + ".")

topFolder = currentProject().RootFolder;

%% Create test suite

suite = matlab.unittest.TestSuite.fromFile(...
fullfile(topFolder, "Tests", "WindFarmGFMControlUnitTest.m"));

%disp("### Not building test suite for detailed model applications.")

%% Create test runner

runner = matlab.unittest.TestRunner.withTextOutput( ...
  OutputDetail = matlab.unittest.Verbosity.Detailed);

%% JUnit style test result

% plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
%   fullfile(topFolder, "Test", "BEV_TestResults_"+relStr+".xml"));
% 
% addPlugin(runner, plugin)
% 
%% MATLAB Code Coverage Report

coverageReportFolder = fullfile(topFolder, "coverage" + relStr);
if not(isfolder(coverageReportFolder))
  mkdir(coverageReportFolder)
end

coverageReport = matlab.unittest.plugins.codecoverage.CoverageReport( ...
  coverageReportFolder, ...
  MainFile = "Wind Farm with GFM Control Coverage" + relStr + ".html" );

plugin = matlab.unittest.plugins.CodeCoveragePlugin.forFile( ...
  [ ...
  fullfile(topFolder, "ScriptsData", "MWWindFarmwithGridformingControls.mlx")
  fullfile(topFolder, "ScriptsData", "comparisonGFMvsGFL.m")
  fullfile(topFolder, "ScriptsData","WindFarmGFMControlParametersFast.m")          
  fullfile(topFolder, "ScriptsData","WindFarmGFMControlplotCurvepower.m")          
  fullfile(topFolder, "ScriptsData","WindFarmGFMControlplotCurvevoltagefrequency.m")          
  fullfile(topFolder, "ScriptsData","WindGFMControlPlotresults.m")
    ], ...
  Producing = coverageReport );

addPlugin(runner, plugin)

%% Run tests
results = run(runner, suite);
assertSuccess(results)
