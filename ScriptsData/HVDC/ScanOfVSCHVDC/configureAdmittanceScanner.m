function scanner = configureAdmittanceScanner(scanData, axis, scanFreq, scan)
% This function creates objects of the class AdmittanceScanner for scanning
% along the D, Q, and Dc axis.
%
% Inputs:
%   scanData - Simulink.SimulationOutput array from parsim
%   axis     - String array of scan axes ("D-axis", "Q-axis", "DC")
%   scanFreq - Frequency vector (Hz)
%   scan     - (Optional) Scan struct with Vd, Vq, Vdc fields.
%              If omitted, uses default amplitudes.

arguments
    scanData {mustBeA(scanData,"Simulink.SimulationOutput")}
    axis string {mustBeNonempty}
    scanFreq {mustBeVector}
    scan struct = struct('Vd', 0.001, 'Vq', 0.001, 'Vdc', 0.01)
end

    for i = 1:length(axis)
        cfg = struct();
        if axis(i) == "D-axis" % D-axis settings
            cfg.Vd = scan.Vd; cfg.Vq = 0; cfg.Vdc = 0;
        elseif axis(i) == "Q-axis" % Q-axis settings
            cfg.Vd = 0; cfg.Vq = scan.Vq; cfg.Vdc = 0;
        else % Dc-axis settings
            cfg.Vd = 0; cfg.Vq = 0; cfg.Vdc = scan.Vdc;
        end
        cfg.freq = scanFreq; % frequency vector in Hz
        cfg.dataAc = scanData(i).dataAc; % Ac perturbation data
        cfg.dataDc = scanData(i).dataDc; % Dc perturbation data
        cfg.order = 4; % Model order for transfer function estimation
        % Create the scan object
        scanner(i) = AdmittanceScanner(cfg); %#ok<AGROW>
    end
end