%% This function estimates the admittance as transfer functions between Id vs Vd, Id vs Vq, Iq vs Vd, Id vs Vd
%using transfer function estimation function available in control system
%tool box.
function sys=admittancescanPRBS(Vd,Vq,f,data,o)
    arguments
     Vd  {mustBeGreaterThanOrEqual(Vd,0)} % Should be the amplitude of D axis disturbance in PU
     Vq  {mustBeGreaterThanOrEqual(Vq,0)} % Should be the amplitude of Q axis disturbance in PU
     f {mustBeVector} % Disturbance frequency vector in Hz
     data {mustBeNonempty}  % Should be a output structure containing the simulation data    
     o {mustBeNumeric} % Should be a numeric value defining the order of the model
    end
    w =2*pi*f;
    if(Vd>1e-6)
        GDDfrd = frestimate(data.dataDD,w,'rad/s'); % Transfer function YDD
        GDQfrd = frestimate(data.dataDQ,w,'rad/s'); % Transfer function YDQ
        figure;
        opt = tfestOptions('InitializeMethod','n4sid','Display','off','SearchMethod','lsqnonlin');
        sysDD = tfest(GDDfrd,o,opt);% Filtered transfer function YDD
        sysDQ = tfest(GDQfrd,o,opt);% Filtered transfer function YDQ
        sys=[sysDD,sysDQ];
        plotAdmittanceD(sysDD,sysDQ,f) %Plots the Bode plots for D-axis admittance
    end
    if(Vq>1e-6)
        GQDfrd = frestimate(data.dataQD,w,'rad/s'); % Transfer function YQD
        GQQfrd = frestimate(data.dataQQ,w,'rad/s'); % Transfer function YQQ
        figure;
        opt = tfestOptions('InitializeMethod','all','Display','off','SearchMethod','lsqnonlin');
        sysQD = tfest(GQDfrd,o,opt); % Filtered transfer function YQD
        sysQQ = tfest(GQQfrd,o,opt); % Filtered transfer function YQQ
        sys=[sysQQ,sysQD];
        plotAdmittanceQ(sysQQ,sysQD,f)  %Plots the Bode plots for Q-axis admittance
    end
end