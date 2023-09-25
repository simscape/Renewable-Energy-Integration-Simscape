classdef WindFarmGFMControlSystemTest < matlab.unittest.TestCase
    % Copyright 2023 The MathWorks, Inc.
    
    % System level test for WindFarmGFMControl.slx 
    % Test strategy: 
    % Test point 1 : testMPPT This test point checks the maximum power
    % point tracking(MPPT) algorithm for Grid-following(GFL) wind turbines.
    % Test point 2 : testLoadChange This test point checks if the Grid-
    % forming (GFM) wind turbine increases its power immediately and the
    % GFL wind turbine output is constant after the load is increased.
    % Test point 3 : testFaultThrough This test point checks if the total 
    % output power of the wind farm is the same before and after 0.5
    % seconds of clearing the fault.
    
    properties
        model = 'WindFarmGFMControl'
        simIn
    end

    properties(TestParameter)
        % Use TestParameter If you need to run the same test method for
        % different inputs or scenarios. In this case, this test runs
        % all the test points GFM wind turbine in the below modes
        converterControl = {'VSM Using Turbine Inertia','VSM Using DC Link Voltage'};
    end

    methods(TestMethodSetup)
        function loadAndTearDown(testCase)
            % This function executes before each test method runs. This
            % function loads the model and add a teardown which
            % executes after the test method is run 
            % Load the model
            load_system(testCase.model);

            % Create a Simulink.SimulationInput object for the model
            testCase.simIn = Simulink.SimulationInput(testCase.model);

            % Close the model after each test point
            testCase.addTeardown(@()bdclose(testCase.model));
        end
    end

    methods(Test)
        function testMPPT(testCase,converterControl)
            % Check if the output power of the GFL wind turbine is tracking
            % the maximum power point tracking(MPPT)
            
            % Import necessary constraints for the test
            import Simulink.sdi.constraints.MatchesSignal
            import Simulink.sdi.constraints.MatchesSignalOptions

            % Set the wind speed 
            initialSpeed = 12;
            finalSpeed = 10;
            stepTime = 5;
            blockPath = strcat(testCase.model,'/','Wind Farm','/','Step1');
            testCase.simIn = setBlockParameter(testCase.simIn,blockPath,'Before',...
                mat2str(initialSpeed),blockPath,'After',mat2str(finalSpeed),blockPath,'Time',mat2str(stepTime));
            
            % Set the simulation time
            stopTime = 8;
            testCase.simIn = setVariable(testCase.simIn,'Tsim',stopTime);
            
            % Set the type of GFM wind turbine converter
            setWindConverterType(testCase,converterControl);
         
            % Simulate the model
            out = sim(testCase.simIn);

            % Get the Grid following wind converter ouput
            windGFLPower = extractTimetable(out.logsWindGFMControl.get('P_GFL'));
            windReferencePower = extractTimetable(out.logsWindGFMControl.get('PMPP'));

            % Set settling time to 0.5s after which all the
            % values reach steady state
            settlingTime = 0.5;
            
            % Remove data for the first 0.1 second to avoid any unnecessary
            % transients. Split the entire simulation in two different time
            % intervals depending on the number of reference changes.
            % Compare the simulation output with the reference in these
            % time intervals
            startTime = 2;
            timeWindow = [{startTime,stepTime},{stepTime+settlingTime,stopTime}];
            
            % Verify the output from the GFL wind turbine is matching the
            % reference MPPT
            for timeIdx = 1:2:length(timeWindow)
                options = MatchesSignalOptions('IgnoringExtraData',true);
                range = timerange(seconds(timeWindow{timeIdx}),seconds(timeWindow{timeIdx+1})) ;
                actualPower = windGFLPower(range,:);
                referencePower = windReferencePower(:,1);
                expectedPower = referencePower(range,:);
                
                % Set row names of the table same for verification
                actualPower.Properties.VariableNames = {'Power'};
                expectedPower.Properties.VariableNames = {'Power'};
                testCase.verifyThat(actualPower,MatchesSignal(expectedPower,...
                    'AbsTol',1e-1,'RelTol',1e-1,'WithOptions',options),...
                    sprintf('The active power output of the GFL wind turbine is not following MPPT when GFM wind turbine is operated in %s mode. Examine the model',converterControl));              
            end
        end

        function testLoadChange(testCase,converterControl)
            % Check if the GFM wind turbine power increases momentarily
            % when there is an increase in the load demand
            
            % Set the load breaker status
            stepTime = 5;
            blockPath = strcat(testCase.model,'/','Loads','/','Step2');
            testCase.simIn = setBlockParameter(testCase.simIn,blockPath,'Time',mat2str(stepTime));
        
            % Set the simulation time
            stopTime = 8;
            testCase.simIn = setVariable(testCase.simIn,'Tsim',stopTime);
            
            % Set the type of GFM wind turbine converter
            setWindConverterType(testCase,converterControl);
          
            % Simulate the model
            out = sim(testCase.simIn);

            % Get the GFM and GFL wind converters power
            windGFLPower = extractTimetable(out.logsWindGFMControl.get('P_GFL'));
            windGFMPower = extractTimetable(out.logsWindGFMControl.get('P_GFM'));
            
            % Remove data for the first 0.1 second to avoid any unnecessary
            % transients. Split the entire simulation in two different
            % time intervals before and after the load change
            startTime = 2;
            timeWindow = [{startTime,stepTime},{stepTime,stopTime}];
            preLoadChange = timerange(seconds(timeWindow{1}),seconds(timeWindow{2}));
            postLoadChange = timerange(seconds(timeWindow{3}),seconds(timeWindow{4}));
             
            % GFL wind turbine power before and after the load change
            preLoadChangeGFLPower = windGFLPower(preLoadChange,:).P_GFL;
            postLoadChangeGFLPower = windGFLPower(postLoadChange,:).P_GFL;

            % GFM wind turbine power before the load change
            preLoadChangeGFMPower = windGFMPower(preLoadChange,:).P_GFM;

            % Set the transient time period 
            transientPeriod = 0.06;
            transientTimeRange = timerange(seconds(stepTime),seconds(stepTime+transientPeriod));
            transientGFMPower = windGFMPower(transientTimeRange,:).P_GFM;

            % Verify if the GFL wind turbine power is the same before and
            % after the load change
            testCase.verifyEqual(preLoadChangeGFLPower,postLoadChangeGFLPower,'AbsTol',10e3,...
                sprintf('GFL power changed after the load change when GFM is operated in %s. Examine the model',converterControl));
            
            % Verify if the GFM wind turbine power increases momentarily
            % after the load change
            testCase.verifyGreaterThan(mean(transientGFMPower)-mean(preLoadChangeGFMPower),0.1e6,...
                sprintf('GFM is not supplying the transient power after the load change when it is operated in %s. Examine the model',converterControl));          
        end

        function testFaultRideThrough(testCase,converterControl)
            % Check if the GFM wind turbine power reaches the prefault
            % value after 0.5 sec of clearing the fault
            
            % Set the fault time 
            faultTime = 5;
            faultClearTime = 5.14;
            blockPath = strcat(testCase.model,'/','Fault1','/','Step2');
            blockPath1 = strcat(testCase.model,'/','Fault1','/','Step1');
            testCase.simIn = setBlockParameter(testCase.simIn,blockPath,'Time',mat2str(faultTime));
            testCase.simIn = setBlockParameter(testCase.simIn,blockPath1,'Time',mat2str(faultClearTime));
            
            % Set the simulation time
            stopTime = 8.64;
            testCase.simIn = setVariable(testCase.simIn,'Tsim',stopTime);
            
            % Set the type of GFM wind turbine converter
            setWindConverterType(testCase,converterControl);
          
            % Simulate the model
            out = sim(testCase.simIn);

            % Get the GFM and GFL wind converters power
            windPower = extractTimetable(out.logsWindGFMControl.get('PTotal'));
            
            % Remove data for the first 0.1 second to avoid any unnecessary
            % transients. Split the entire simulation in two different
            % time intervals before and after the fault
            startTime = 2;
            standardTime = 0.5;
            timeWindow = [{startTime,faultTime},{faultClearTime+standardTime,stopTime}];
            preFault = timerange(seconds(timeWindow{1}),seconds(timeWindow{2}));
            postFault = timerange(seconds(timeWindow{3}),seconds(timeWindow{4}));
            
            % Total wind farm power before and after the fault
            preFaultWindPower = windPower(preFault,:).PTotal;
            postFaultWindPower = windPower(postFault,:).PTotal;
            
            % Verify if the wind farm power is the same before and after
            % the fault
            testCase.verifyEqual(preFaultWindPower,postFaultWindPower,'AbsTol',10e6,...
                sprintf('Wind farm power changed after the fault when GFM is operated in %s. Examine the model',converterControl));

        end
    end

    methods
        function testCase = setWindConverterType(testCase,converterControl)
            % This function sets the GFM wind turbine converter type        
            % Set the type of wind turbine converter
            testCase.simIn = setBlockParameter(testCase.simIn,strcat(testCase.model,'/Wind Farm/Wind Turbine (GFM)'),'Control',converterControl);
            testCase.simIn = setBlockParameter(testCase.simIn,strcat(testCase.model,'/Wind Farm/Wind Turbine (GFM)1'),'Control',converterControl); 
        end
    end
end