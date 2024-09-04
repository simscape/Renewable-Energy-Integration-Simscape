%This function calculates the short circuit ratio at the point of
%Copyright 2022 - 2023 The MathWorks, Inc.
%interconnection
function [SCRCal] = BatteryStoragePVPlantGFMSCRCal(Line,Feeder,Grid,SubTransmissionLine,PVpower)
SCRCal.Vbg=4.16e3;                    %Base Volatge at POI
SCRCal.MVAb=PVpower;                  %Base MVA is PV plant Peak MW capacity
SCRCal.zbg=(SCRCal.Vbg)^2/SCRCal.MVAb; %Base impedance
SCRCal.zg=(4.16/24.9)^2*(Grid.Rs+1j*Grid.Ls*2*pi*60)/SCRCal.zbg; %Per-unit impedance of grid
SCRCal.zst=(4.16/24.9)^2*(SubTransmissionLine.R+1j*SubTransmissionLine.L*2*pi*60)/SCRCal.zbg;%Per-unit impedance of subtransmission line
SCRCal.z_L=Line.l_km*(4.16/24.9)^2*(Line.r_l+1j*2*pi*60*Line.L_l*1e-3)/SCRCal.zbg; %Per-unit impedance of transmission line
SCRCal.zpcc=(Feeder.R_f+1j*2*pi*60*(Feeder.L_f))*(Feeder.lengthFirstHalf+Feeder.lengthSecondHalf)/SCRCal.zbg; %Per-unit impedance of feeder
SCRCal.zp=(SCRCal.zg+SCRCal.z_L+SCRCal.zpcc+SCRCal.zst);% Totaal impedance 
SCRCal.SCR=1/abs(SCRCal.zp); %Calculated SCR
end
