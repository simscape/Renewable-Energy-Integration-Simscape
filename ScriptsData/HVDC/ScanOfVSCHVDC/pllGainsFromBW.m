function [KpPll, KiPll] = pllGainsFromBW(fBW, zeta, Vm)
% pllGainsFromBW  Design SRF-PLL PI gains from bandwidth & damping
%
% Inputs:
%   fBW  - Desired PLL bandwidth (Hz)
%   zeta - Desired damping ratio (e.g., 0.707)
%   Vm   - Voltage magnitude (p.u.), default = 1 if not given
%
% Outputs:
%   Kp - PLL PI proportional gain
%   Ki - PLL PI integral gain

if nargin < 3
    Vm = 1;
end

wn = 2 * pi * fBW;   % Natural frequency (rad/s)
KiPll = (wn^2) / Vm;
KpPll = (2 * zeta * wn) / Vm;

end
