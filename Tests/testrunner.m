% Copyright 2022 The MathWorks, Inc.
 
% Create test suite
fprintf('*** Creating test suite ***')
import matlab.unittest.TestSuite;
%suite = [testsuite('teeBatteryStoragePVPlantGFM.m'), testsuite('tWindFarmGFMControl.m')];
 suite = testsuite('tWindFarmGFMControl.m');
% Create test runner
runner = matlab.unittest.TestRunner.withTextOutput(...
    'OutputDetail',matlab.unittest.Verbosity.Detailed);
 
% Set up report for results
runner.addPlugin(matlab.unittest.plugins.XMLPlugin.producingJUnitFormat('testResults.xml'));
 
% Run tests
results = runner.run(suite);
disp(results.assertSuccess);
clear rmtestdir