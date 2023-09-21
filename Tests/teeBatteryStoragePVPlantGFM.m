classdef teeBatteryStoragePVPlantGFM < exampletest.simulationTest
   
    properties
        ModelName = 'BatteryStoragePVPlantGFM' % Name of the system under test
        ReleaseVersion = 'R2022b' % Release used for creating the model
        expectedCheckedOutProducts = {'matlab','simulink','simscape','power_system_blocks','stateflow','simdriveline'} % List of product licenses used by the model
        compareAgainstBaseline = false % Compare simulation results against a baseline present in a mat-file named 'baseline_<ModelName>.mat'. Leverage the exampletest.generateBaselineDataFileForModel function to generate the baseline.
    end
end