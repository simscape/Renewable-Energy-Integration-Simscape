# **Renewable Energy Integration Design with Simscape**
This repository provides engineering solutions for the operation of power systems with high penetration of renewable energy sources. The developed models comply with current IEEE/IEC and national grid standards.

[![View ​Renewable Energy Integration Design with Simscape on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/123870-renewable-energy-integration-design-with-simscape)
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=simscape/Renewable-Energy-Integration-Simscape)

# This Repository Includes the Following Engineering Solutions
### 1. [Evaluate Performance of MTHVDC System with GFM Control for Offshore Wind Integration.](https://viewer.mathworks.com/?viewer=live_code&url=https%3A%2F%2Fwww.mathworks.com%2Fmatlabcentral%2Fmlc-downloads%2Fdownloads%2F45965b03-57ee-472e-a6cb-8bc8dd5d299a%2F1739254663%2Ffiles%2FScriptsData%2FHVDC%2FMTHVDCModelDescription.mlx&embed=web)
### 2. [Evaluate Performance of Grid Forming Controls for Type 4 Wind Generators in Wind Farm.](https://viewer.mathworks.com/?viewer=live_code&url=https%3A%2F%2Fwww.mathworks.com%2Fmatlabcentral%2Fmlc-downloads%2Fdownloads%2F45965b03-57ee-472e-a6cb-8bc8dd5d299a%2F1739254828%2Ffiles%2FScriptsData%2FWind%20Model%2FMWWindFarmwithGridformingControls.mlx&embed=web)
### 3. [Assess the Stability of Inverter-Based Resources using Admittance Scan Technique.](https://viewer.mathworks.com/?viewer=live_code&url=https%3A%2F%2Fwww.mathworks.com%2Fmatlabcentral%2Fmlc-downloads%2Fdownloads%2F45965b03-57ee-472e-a6cb-8bc8dd5d299a%2F1739254828%2Ffiles%2FScriptsData%2FAdmittance%20Scan%2FAdmittanceScanofIBRsDescription.mlx&embed=web)
### 4. [Performance Evaluation of Grid Forming Battery Energy Storage Systems in Solar PV Plants.](https://viewer.mathworks.com/?viewer=live_code&url=https%3A%2F%2Fwww.mathworks.com%2Fmatlabcentral%2Fmlc-downloads%2Fdownloads%2F45965b03-57ee-472e-a6cb-8bc8dd5d299a%2F1739254828%2Ffiles%2FScriptsData%2FPVPlant%2FBatteryStoragePVPlantGFMMainPage.mlx&embed=web)

# Overview
## Performance Evaluation of Grid Forming Battery Energy Storage Systems in Solar PV Plants
<table>
  <tr>
    <td class="image-column" width=700><img src="Pictures/SystemModel.png" alt="PV Plant with BESS"></td>
    <td class="image-column" width=50></td>
    <td class="image-column" width=600><img src="Pictures/BESSGFL&GFM.PNG" alt="BESS GFL vs GFM"></td>
    <td class="image-column" width=50></td>
    <td class="text-column" width=300>This project evaluates the capabilities of a grid-forming (GFM) battery energy storage system (BESS) in maintaining a stable power system with high penetration of solar photovoltaic (PV) energy sources. 
    Use this model to test and verify if the PV plant and BESS unit can perform as required by the IEEE 2800 standards.</td>
  </tr>
</table>

## Evaluate Performance of Grid Forming Controls for Type 4 Wind Generators in Wind Farms
<table>
  <tr>
    <td class="image-column" width=700><img src="Pictures/WindFarm.PNG" alt="GFM Wind"></td>
    <td class="image-column" width=50></td>
    <td class="image-column" width=500><img src="Pictures/MGFMwind.PNG" alt="MGFM"></td>
    <td class="image-column" width=50></td>
    <td class="text-column" width=300>In this project you can use two GFM control strategies for type-4 wind turbine generators: GFM control based on DC-link voltage regulation (GGFM), and GFM control using turbine inertia (MGFM). Use this model to test the performance (such as fault-ride-through) of the GFM wind controller and campare it with the industry standards.</td>
  </tr>
</table>

## Assess the Stability of Inverter-Based Resources (IBRs) using Admittance Scan Technique
<table>
  <tr>
    <td class="image-column" width=300><img src="Pictures/Scanadmi.png" alt="plot"></td>
    <td class="image-column" width=50></td>
    <td class="text-column" width=400> This project investigates the use of admittance scanning to detect oscillatory instability in power networks with a high presence of IBRs. Use this admittance scan block to obtain the admittance spectrum of grid connected IBRs.</td>
  </tr>
  </table>

<table>
  <tr>
    <td class="image-column" width=800><img src="Pictures/Admiscanmodel.png" alt="Model"></td>
    <td class="image-column" width=50></td>
    <td class="text-column" width=400> Using this model you can assess the oscillatory instability of the grid connected renewable plant using admittance/ impedance scanning technique, where the effective admittance/ impedance of the renewable plant and the grid are estimated over a range of different frequencies.</td>
  </tr>
</table>

##  Evaluate Performance of Multi-terminal High Voltage Direct Current (MTHVDC) Systems with GFM Control for Offshore Wind Integration
<table>
  <tr>
    <td class="image-column" width=600><img src="Pictures/HVDCModelGFM.png" alt="MTHVDCModel"></td>
    <td class="image-column" width=50></td>
    <td class="text-column" width=400> This study evaluates the capabilities of voltage source converter (VSC) based MTHVDC systems in maintaining a stable system during high off-shore wind penetration. MTHVDC system have more than two converter stations interconnected by DC lines, enabling power transfer between multiple offshore locations. You can investigate the performance of various types of controlllers for the HVDC stations including grid forming controls. Use the tools provided in this project to design a MTHVDC system, connect them to offshore renewable sources and evaluate their performance under various dynamic scenario, like, faults, large variation in renewable power, grid outage, etc.</td>
  </tr>
</table>

## Setup
- Clone the repository and add to MATLAB&reg; path, then click the 'RenewableEnergyIntegrationwithSimscape.prj' file to get started. 
- In the toolstrip, use the project shortcut buttons to load the model.
- This project requires MATLAB&reg; R2024a or later.

## Setup
- Clone the repository and add to MATLAB&reg; path, then click the 'RenewableEnergyIntegrationwithSimscape.prj' file to get started. 
- In the toolstrip, use the project shortcut buttons to load the model.
- This project requires MATLAB&reg; R2024a or later.

Copyright 2022-2025 The MathWorks, Inc.
