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
    MainFile = "Admittance Scan Test Coverage" + relStr + ".html" );
plugin = matlab.unittest.plugins.CodeCoveragePlugin.forFile(...
    [...
    fullfile(topFolder, "ScriptsData\Admittance Scan", "TestHarnessDescription.mlx")...
    fullfile(topFolder, "ScriptsData\Admittance Scan", "admittancescanPRBS.m")], ...
    Producing = coverageReport );
addPlugin(runner, plugin)
%% Run tests
results = run(runner, suite);
out = assertSuccess(results);
disp(out);
 