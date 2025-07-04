function sys = dcAdmittancescanPRBS(Vd,Vq,Vdc,f,data,o,plt)
%% This function estimates the admittance as transfer functions between Idc vs Vdc
%using transfer function estimation function available in control system
%tool box.

arguments
    Vd  {mustBeGreaterThanOrEqual(Vd,0)} % Should be the amplitude of D axis disturbance in PU
    Vq  {mustBeGreaterThanOrEqual(Vq,0)} % Should be the amplitude of Q axis disturbance in PU
    Vdc {mustBeGreaterThanOrEqual(Vdc,0)} % Should be the amplitude of DC voltage disturbance in PU
    f {mustBeVector} % Disturbance frequency vector in Hz
    data {mustBeNonempty}  % Should be a output structure containing the simulation data
    o {mustBeNumeric} % Should be a numeric value defining the order of the model
    plt {mustBeMember(plt,{'Y','N'})} % Should be a Y/N value to plot or not on execution
end
%% Initialize the transfer functions as a structure.
sys.DC = [];
sys.DCD = [];
sys.DCQ = [];
w =2*pi*f;
if(Vdc>1e-6)
    GDCfrd = frestimate(data.DataDC,w,'rad/s'); % Transfer function YDC
    figure;
    opt = tfestOptions('InitializeMethod','n4sid','Display','off','SearchMethod','lsqnonlin');
    sysDC = tfest(GDCfrd,o,opt);% Filtered transfer function YDC
    sys.DC=sysDC;
    if(plt=='Y')
        plotAdmittanceDC(sysDC,f); %Plots the Bode plots for DC admittance
    end
end
if(Vd>1e-6)
    GDCDfrd = frestimate(data.DataDCD,w,'rad/s'); % Transfer function YDCD
    figure;
    opt = tfestOptions('InitializeMethod','n4sid','Display','off','SearchMethod','lsqnonlin');
    sysDCD = tfest(GDCDfrd,o,opt);% Filtered transfer function YDCD
    sys.DCD = sysDCD;
    if(plt=='Y')
        plotAdmittanceDCd(sysDCD,f); %Plots the Bode plots for D-axis admittance
    end
end
if(Vq>1e-6)
    GDCQfrd = frestimate(data.DataDCQ,w,'rad/s'); % Transfer function YDCQ
    figure;
    opt = tfestOptions('InitializeMethod','all','Display','off','SearchMethod','lsqnonlin');
    sysDCQ = tfest(GDCQfrd,o,opt); % Filtered transfer function YDCQ
    sys.DCQ=sysDCQ;
    if(plt=='Y')
        plotAdmittanceDCq(sysDCQ,f);  %Plots the Bode plots for Q-axis admittance
    end
end
end