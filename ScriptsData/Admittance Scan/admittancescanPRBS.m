function sys = admittancescanPRBS(Vd,Vq,Vdc,f,data,o,plot)
%% This function estimates the admittance as transfer functions between Id vs Vd, Id vs Vq, Iq vs Vd, Id vs Vd
%using transfer function estimation function available in control system
%tool box.

arguments
    Vd  {mustBeGreaterThanOrEqual(Vd,0)} % Should be the amplitude of D axis disturbance in PU
    Vq  {mustBeGreaterThanOrEqual(Vq,0)} % Should be the amplitude of Q axis disturbance in PU
    Vdc {mustBeGreaterThanOrEqual(Vdc,0)} % Should be the amplitude of DC voltage disturbance in PU
    f {mustBeVector} % Disturbance frequency vector in Hz
    data {mustBeNonempty}  % Should be a output structure containing the simulation data
    o {mustBeNumeric} % Should be a numeric value defining the order of the model
    plot {mustBeMember(plot,{'Y','N'})} % Should be a Y/N value to plot or not on execution
end
%% Initialize the transfer functions as a structure.
sys.D = [];
sys.Q = [];
sys.DC = [];
w =2*pi*f;
if(Vd>1e-6)
    GDDfrd = frestimate(data.DataDD,w,'rad/s'); % Transfer function YDD
    GDQfrd = frestimate(data.DataDQ,w,'rad/s'); % Transfer function YDQ
    figure;
    opt = tfestOptions('InitializeMethod','n4sid','Display','off','SearchMethod','lsqnonlin');
    sysDD = tfest(GDDfrd,o,opt);% Filtered transfer function YDD
    sysDQ = tfest(GDQfrd,o,opt);% Filtered transfer function YDQ
    sys.D = [sysDD,sysDQ];
    if(plot=='Y')
        plotAdmittanceD(sysDD,sysDQ,f); %Plots the Bode plots for D-axis admittance
    end
end
if(Vq>1e-6)
    GQDfrd = frestimate(data.DataQD,w,'rad/s'); % Transfer function YQD
    GQQfrd = frestimate(data.DataQQ,w,'rad/s'); % Transfer function YQQ
    figure;
    opt = tfestOptions('InitializeMethod','all','Display','off','SearchMethod','lsqnonlin');
    sysQD = tfest(GQDfrd,o,opt); % Filtered transfer function YQD
    sysQQ = tfest(GQQfrd,o,opt); % Filtered transfer function YQQ
    sys.Q = [sysQQ,sysQD];
    if(plot=='Y')
        plotAdmittanceQ(sysQQ,sysQD,f);  %Plots the Bode plots for Q-axis admittance
    end
end
if(Vdc>1e-6)
    GDDCfrd = frestimate(data.DataDDC,w,'rad/s'); % Transfer function YDDC
    GQDCfrd = frestimate(data.DataQDC,w,'rad/s'); % Transfer function YQDC
    figure;
    opt = tfestOptions('InitializeMethod','all','Display','off','SearchMethod','lsqnonlin');
    sysDDC = tfest(GDDCfrd,o,opt); % Filtered transfer function YQD
    sysQDC = tfest(GQDCfrd,o,opt); % Filtered transfer function YQQ
    sys.DC = [sysDDC,sysQDC];
    if(plot=='Y')
        plotAdmittanceDQdc(sysDDC,sysQDC,f);  %Plots the Bode plots for DC-axis admittance
    end
end
end