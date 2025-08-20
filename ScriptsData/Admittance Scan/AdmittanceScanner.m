classdef AdmittanceScanner
    % AdmittanceScanner estimates small-signal admittance transfer functions
    % for three-phase power systems using simulation data.
    % Supports scanning for both AC and DC domains, with integrated plotting.

    properties
        % Configuration structure with required fields: voltage disturbances along D-axis: Vd (PU), 
        % voltage disturbances along Q-axis: voltage disturbances Vq (PU), along DC-side: Vdc (PU), 
        % disturbance frequency vector: freq (Hz), order of transfer function: order, plotFlag: ('Y'/'N'), 
        % measurement data: data.

        config struct
    end

    properties
        % Estimated admittance systems (as transfer functions)

        SysD       % D-axis AC admittance [DD, DQ]
        SysQ       % Q-axis AC admittance [QQ, QD]
        SysDCac    % AC-side DC injection admittance [DDC, QDC]
        SysDC      % DC-link admittance
        SysDCD     % DC-link current vs D-axis injection
        SysDCQ     % DC-link current vs Q-axis injection
    end

    methods (Access = public)
        % This function creates the Admittancescanner class object
        function obj = AdmittanceScanner(config)
            % Constructor: Validates configurations and merges dataAc/dataDc if needed
            
            arguments
                config struct
            end

            requiredFields = ["Vd", "Vq", "Vdc", "freq", "order"];
            for iter = 1:length(requiredFields)
                if ~isfield(config, requiredFields(iter))
                    error("Missing required field: %s", requiredFields(iter));
                end
            end

            % Combine AC and DC data fields into one if provided separately
            if isfield(config, "dataAc") || isfield(config, "dataDc")
                if isfield(config, "dataAc")
                    dataAc = config.dataAc;
                else
                    dataAc = struct();
                end
                if isfield(config, "dataDc")
                    dataDc = config.dataDc;
                else
                    dataDc = struct();
                end
                config.data = AdmittanceScanner.combineDataStructs(dataAc, dataDc);
            elseif ~isfield(config, "data")
                error("No 'data', 'dataAc', or 'dataDc' field provided in config.");
            end

            obj.config = config;
        end
        % This function performs the AC-side scan
        function obj = runACScan(obj)
            % Estimates AC-side admittance transfer functions

            arguments
                obj {mustBeA(obj, 'AdmittanceScanner')}
            end

            cfg = obj.config; % Configuration
            w = 2 * pi * cfg.freq; % Frequency in (rad/sec)
            % Settings for frequency response estimation
            opt = tfestOptions('InitializeMethod', 'n4sid', 'Display', 'off', 'SearchMethod', 'lsqnonlin');

            if cfg.Vd > 0
                GDD = frestimate(cfg.data.DataDD, w, 'rad/s'); % Frequency response estimation along D-axis (ID/VD)
                GDQ = frestimate(cfg.data.DataDQ, w, 'rad/s'); % Frequency response estimation along D-axis (IQ/VD)
                sysDD = tfest(GDD, cfg.order, opt); % Estimated transfer function
                sysDQ = tfest(GDQ, cfg.order, opt); % Estimated transfer function
                obj.SysD = [sysDD, sysDQ]; % Combining the response for D-axis
            end

            if cfg.Vq > 0
                GQQ = frestimate(cfg.data.DataQQ, w, 'rad/s'); % Frequency response estimation along Q-axis (IQ/VQ)
                GQD = frestimate(cfg.data.DataQD, w, 'rad/s'); % Frequency response estimation along Q-axis (ID/VQ)
                sysQQ = tfest(GQQ, cfg.order, opt); % Estimated transfer function
                sysQD = tfest(GQD, cfg.order, opt); % Estimated transfer function
                obj.SysQ = [sysQQ, sysQD]; % Combining the response for Q-axis
            end

            if cfg.Vdc > 0
                GDDC = frestimate(cfg.data.DataDDC, w, 'rad/s');
                GQDC = frestimate(cfg.data.DataQDC, w, 'rad/s');
                sysDDC = tfest(GDDC, cfg.order, opt);
                sysQDC = tfest(GQDC, cfg.order, opt);
                obj.SysDCac = [sysDDC, sysQDC];
            end
        end
        % This function performs the DC-side scan
        function obj = runDCScan(obj)
            % Estimates DC-side admittance transfer functions

            arguments
                obj {mustBeA(obj, 'AdmittanceScanner')}
            end

            cfg = obj.config; % Configurations 
            omega = 2 * pi * cfg.freq; % Frequency vector in (rad/sec)

            if cfg.Vdc > 0 && isfield(cfg.data, "DataDC")
                GDC = frestimate(cfg.data.DataDC, omega, 'rad/s'); % Response along DC-side (IDC/VDC)
                obj.SysDC = tfest(GDC, cfg.order, ...
                    tfestOptions('InitializeMethod', 'n4sid', 'Display', 'off', 'SearchMethod', 'lsqnonlin')); % Estimated transfer function
            end

            if cfg.Vd > 0 && isfield(cfg.data, "DataDCD")
                GDCD = frestimate(cfg.data.DataDCD, omega, 'rad/s'); % Response along D-axis for DC disturbance (ID/VDC)
                obj.SysDCD = tfest(GDCD, cfg.order, ...
                    tfestOptions('InitializeMethod', 'n4sid', 'Display', 'off', 'SearchMethod', 'lsqnonlin')); % Estimated transfer function
            end

            if cfg.Vq > 0 && isfield(cfg.data, "DataDCQ")
                GDCQ = frestimate(cfg.data.DataDCQ, omega, 'rad/s'); % Response along Q-axis for DC disturbance (IQ/VDC)
                obj.SysDCQ = tfest(GDCQ, cfg.order, ...
                    tfestOptions('InitializeMethod', 'all', 'Display', 'off', 'SearchMethod', 'lsqnonlin')); % Estimated transfer function
            end
        end
        % This function does the D-axis Q-axis DC-axis admittance for
        % AC-side scan
        function plotAC(obj)
            % Plots AC-domain admittance if available
            arguments
                obj {mustBeA(obj, 'AdmittanceScanner')}
            end

            cfg = obj.config;

            if ~isempty(obj.SysD)
                figure;
                AdmittanceScanner.plotAdmittanceD(obj.SysD(1), obj.SysD(2), cfg.freq);
            end
            if ~isempty(obj.SysQ)
                figure;
                AdmittanceScanner.plotAdmittanceQ(obj.SysQ(1), obj.SysQ(2), cfg.freq);
            end
            if ~isempty(obj.SysDCac)
                figure;
                AdmittanceScanner.plotAdmittanceDQdc(obj.SysDCac(1), obj.SysDCac(2), cfg.freq);
            end
        end
        % This function does the D-axis Q-axis DC-axis admittance for
        % DC-side scan
        function plotDC(obj)
            % Plots DC-domain admittance if available
            arguments
                obj {mustBeA(obj, 'AdmittanceScanner')}
            end

            cfg = obj.config;

            if ~isempty(obj.SysDC)
                figure;
                AdmittanceScanner.plotAdmittanceDC(obj.SysDC, cfg.freq);
            end
            if ~isempty(obj.SysDCD)
                figure;
                AdmittanceScanner.plotAdmittanceDCd(obj.SysDCD, cfg.freq);
            end
            if ~isempty(obj.SysDCQ)
                figure;
                AdmittanceScanner.plotAdmittanceDCq(obj.SysDCQ, cfg.freq);
            end
        end
    end

    methods (Static, Access = private)
    % These functions are used for plotting the frequency responses 
        function plotAdmittanceD(sysDD,sysDQ,f)
            % This function plots the Bode plot for the D-axis admittance Ydd, Ydq

            h1=bodeplot(sysDD,sysDQ,{f(1)*2*pi,f(end)*2*pi}); % Bode plot
            setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
            legend('Y_DD','Y_DQ','Location','best');
            title('D axis Admittances');
            figure;
            subplot(2,2,1)
            nichols(sysDD)
            ngrid
            title('DD axis Admittance Nichols Chart'); % Nichols Chart for YDD
            subplot(2,2,2)
            nichols(sysDQ)
            title('DQ axis Admittance Nichols Chart'); % Nichols Chart for YDQ
            ngrid
            subplot(2,2,3)
            pzplot(sysDD)
            title('DD axis Poles and Zeros'); % Eigen plot for YDD
            subplot(2,2,4)
            pzplot(sysDQ)
            title('DQ axis Poles and Zeros'); % Eigen plot for YDD
        end
        function plotAdmittanceQ(sysQQ,sysQD,f)
            % This function plots the Bode plot for the Q-axis admittance Yqq, Yqd

            h1=bodeplot(sysQQ,sysQD,{f(1)*2*pi,f(end)*2*pi});
            setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
            legend('Y_QQ','Y_QD','Location','best');
            title('Q axis Admittances');
            figure;
            subplot(2,2,1)
            nichols(sysQQ) % Nichols Chart for YQQ
            ngrid
            title('QQ axis Admittance Nichols Chart');
            subplot(2,2,2)
            nichols(sysQD) % Nichols Chart for YQD
            title('QD axis Admittance Nichols Chart');
            ngrid
            subplot(2,2,3)
            pzplot(sysQQ) % Eigen plot for YQQ
            title('QQ axis Poles and Zeros');
            subplot(2,2,4)
            pzplot(sysQD) % Eigen plot for YQD
            title('QD axis Poles and Zeros');
        end
        function plotAdmittanceDQdc(sysDC,sysQDC,f)
            % This function plots the Bode plot for the DQ to Dc transfer admittance YdDc, YqDc

            h1=bodeplot(sysDC,sysQDC,{f(1)*2*pi,f(end)*2*pi});
            setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
            legend('Y_Ddc','Y_Qdc','Location','best');
            title('D and Q axis Transfer Admittances on DC bus disturbance');
            figure;
            subplot(2,2,1)
            nichols(sysDC) % Nichols Chart for YQQ
            ngrid
            title('D to dc Transfer Admittance Nichols Chart');
            subplot(2,2,2)
            nichols(sysQDC) % Nichols Chart for YQD
            title('Q to dc Admittance Nichols Chart');
            ngrid
            subplot(2,2,3)
            pzplot(sysDC) % Eigen plot for YQQ
            title('D dc axis Poles and Zeros');
            subplot(2,2,4)
            pzplot(sysQDC) % Eigen plot for YQD
            title('Q dc axis Poles and Zeros');
        end
        function plotAdmittanceDC(sysDC,f)
            % This function plots the Bode plot for the DC admittance YDc

            h1=bodeplot(sysDC,{f(1)*2*pi,f(end)*2*pi}); % Bode plot
            setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
            legend('Y_{DC}','Location','best');
            title('DC Admittances');
            figure;
            subplot(2,1,1)
            nichols(sysDC)
            ngrid
            title('Admittance Nichols Chart'); % Nichols Chart for YDD
            subplot(2,1,2)
            pzplot(sysDC);
            title('Poles and Zeros'); % Eigen plot for YDD
        end
        function plotAdmittanceDCd(sysDCd,f)
            % This function plots the Bode plot for the Dc to D-axis admittance YDcd

            h1=bodeplot(sysDCd,{f(1)*2*pi,f(end)*2*pi}); % Bode plot
            setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
            legend('Y_{dDC}','Location','best');
            title('DC Transfer Admittances on D axis Disturbance');
            figure;
            subplot(2,1,1)
            nichols(sysDCd)
            ngrid
            title('Admittance Nichols Chart'); % Nichols Chart for YDD
            subplot(2,1,2)
            pzplot(sysDCd)
            title('Poles and Zeros'); % Eigen plot for YDD
        end
        function plotAdmittanceDCq(sysDCq,f)
            % This function plots the Bode plot for the Dc to Q-axis admittance
            % YDcq

            h1=bodeplot(sysDCq,{f(1)*2*pi,f(end)*2*pi}); % Bode plot
            setoptions(h1,'FreqUnits','Hz','grid','on','PhaseWrapping','off');
            legend('Y_{qDC}','Location','best');
            title('DC Transfer Admittances on Q axis Disturbance');
            figure;
            subplot(2,1,1)
            nichols(sysDCq)
            ngrid
            title('Admittance Nichols Chart'); % Nichols Chart for YDD
            subplot(2,1,2)
            pzplot(sysDCq)
            title('Poles and Zeros'); % Eigen plot for YDD
        end
    % This function is used for combining the AC and DC scan data
        function merged = combineDataStructs(dataAc, dataDc)
            
            % This function combines AC and DC data if one or both are present
            arguments
                dataAc struct = struct()
                dataDc struct = struct()
            end

            merged = cell2struct( ...
                [struct2cell(dataAc); struct2cell(dataDc)], ...
                [fieldnames(dataAc); fieldnames(dataDc)], ...
                1 ...
                );
        end
    end
end
