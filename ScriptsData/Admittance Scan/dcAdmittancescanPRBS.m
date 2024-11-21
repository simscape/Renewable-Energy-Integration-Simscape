%% This function estimates the admittance as transfer functions between Idc vs Vdc
%using transfer function estimation function available in control system
%tool box.
function sys=dcAdmittancescanPRBS(Vdc,f,data,o)
    arguments
     Vdc  {mustBeGreaterThanOrEqual(Vdc,0)} % Should be the amplitude of D axis disturbance in PU
     f {mustBeVector} % Disturbance frequency vector in Hz
     data {mustBeNonempty}  % Should be a output structure containing the simulation data    
     o {mustBeNumeric} % Should be a numeric value defining the order of the model
    end
    w =2*pi*f;
    if(Vdc>1e-6)
        GDCfrd = frestimate(data.dataDC,w,'rad/s'); % Transfer function YDC
        figure;
        opt = tfestOptions('InitializeMethod','n4sid','Display','off','SearchMethod','lsqnonlin');
        sysDC = tfest(GDCfrd,o,opt);% Filtered transfer function YDD
        plotAdmittanceDC(sysDC,f) %Plots the Bode plots for D-axis admittance
    end
end