function in = setSimulationforScan(mdl, scan, axis, varargin)
% Sets up Simulink.SimulationInput array for D/Q/DC admittance scan.
% Uses PRBS on selected axis, and applies optional parameters via Name-Value pairs.

% Input validation for required arguments
arguments
    mdl (1,:) char {mustBeNonempty}
    scan struct {mustBeNonempty}
    axis string {mustBeNonempty}
end

arguments (Repeating)
    varargin
end

% Convert varargin to a structure of parameters
params = struct(varargin{:});

% Extract parameters or use defaults
PllKp  = getFieldOrDefault(params, 'PllKp', []);
VdcKp  = getFieldOrDefault(params, 'VdcKp', []);
PllKi  = getFieldOrDefault(params, 'PllKi', []);
VdcKi  = getFieldOrDefault(params, 'VdcKi', []);
rsGrid = getFieldOrDefault(params, 'GridRs', 0.1);    % Default grid R
lsGrid = getFieldOrDefault(params, 'GridLs', 29.7e-3);  % Default grid L

% Expand scalar axis to full array if needed
if isscalar(axis)
    axis = repmat(axis, 1, 3);
end

% Initialize simulation input array
in(1:3) = Simulink.SimulationInput(mdl);

for i = 1:3
    % Grid impedance setup
    in(i) = in(i).setVariable('grid.rs', rsGrid);
    in(i) = in(i).setVariable('grid.ls', lsGrid);

    % PRBS excitation setup based on selected axis
    switch axis(i)
        case "D-axis"
            in(i) = in(i).setVariable('scan.Vd', scan.Vd).setVariable('scan.Vd1', scan.Vd1);
            in(i) = in(i).setVariable('scan.Vq', 0).setVariable('scan.Vq1', 0);
            in(i) = in(i).setVariable('scan.Vdc', 0).setVariable('scan.Vdc1', 0);

        case "Q-axis"
            in(i) = in(i).setVariable('scan.Vq', scan.Vq).setVariable('scan.Vq1', scan.Vq1);
            in(i) = in(i).setVariable('scan.Vd', 0).setVariable('scan.Vd1', 0);
            in(i) = in(i).setVariable('scan.Vdc', 0).setVariable('scan.Vdc1', 0);

        case "DC"
            in(i) = in(i).setVariable('scan.Vdc', scan.Vdc).setVariable('scan.Vdc1', scan.Vdc1);
            in(i) = in(i).setVariable('scan.Vd', 0).setVariable('scan.Vd1', 0);
            in(i) = in(i).setVariable('scan.Vq', 0).setVariable('scan.Vq1', 0);
    end

    % Controller gain injection if provided
    if ~isempty(PllKp)
        in(i) = in(i).setVariable('PLL.Kp_pll', PllKp);
        in(i) = in(i).setVariable('PLL.Ki_pll', PllKi);
    end
    if ~isempty(VdcKp)
        in(i) = in(i).setVariable('onshoreGfl.vdckpv', VdcKp);
        in(i) = in(i).setVariable('onshoreGfl.vdckiv', VdcKi);
    end
end
end

% Helper function to get field from struct or return default value
function val = getFieldOrDefault(s, field, default)
if isfield(s, field)
    val = s.(field);
else
    val = default;
end
end