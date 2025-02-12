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

##  Evaluate Performance of Multi-terminal High Voltage Direct Current (MTHVDC) Systems with GFM Control for Offshore Wind Integration

This study evaluates the capabilities of voltage source converter (VSC) based MTHVDC systems in maintaining a stable system during high offshore wind penetration. 

MTHVDC system have more than two converter stations interconnected by DC lines, enabling power transfer between multiple offshore locations.

This figure shows the MTHVDC model for offshore wind integration.

![](Pictures/HVDCModelGFM.png)

You can investigate the performance of various types of controlllers for the HVDC stations including grid forming (GFM) controls. 
Use the tools provided in this project to design a MTHVDC system, connect them to offshore renewable sources and evaluate their 
performance under various dynamic scenario, like, faults, large variation in renewable power, grid outage, etc.

## Evaluate Performance of Grid Forming Controls for Type 4 Wind Generators in Wind Farms
This project evaluates the capabilities of a grid-forming (GFM) controller of type-4 wind turbine generators in maintaining a stable power system operation with high inverter-based renewable energy sources penetration. 

Use this model to compare the dynamic performance of the grid-connected wind farm during normal operation and contingencies, such as a large drop in wind power, load change, faults, and generation outage. 
Run this model to test whether the designed GFM wind controller helps the wind farm to conform with the performance requirements that the industry standards recommend.

![](Pictures/WindFarm.PNG)

In this project you can use two GFM control strategies for type-4 wind turbine generators:
- G-GFM: GFM control based on DC-link voltage regulation by the grid-side converter (GSC).  
- M-GFM: GFM control using turbine inertia with DC-link voltage control by the machine-side converter (MSC). 

These figures show the general control scheme for the GFM control of wind turbine generators using G-GFM and M-GFM controllers.

![](Pictures/MGFMwind.PNG)

![](Pictures/GGFMwind.PNG)

These figures show the response of the wind plant during a fault condition. A stable volatge and frequency indicates that the wind plant is able to ride-through low voltage and frequency variation during the fault, which is in compliance with the ride-through requirements in standards. 
Once the fault clears, the system returns to its pre-fault state in 0.5 sec, which follows the post-fault recovery requirements of standard. 

![](Pictures/MGFMFault.PNG)
## Assess the Stability of Inverter-Based Resources (IBRs) using Admittance Scan Technique
This project investigates the use of admittance scanning to detect oscillatory instability in power networks with a high presence of IBRs.
The IBRs can destabilize grid voltage because of undesired interactions between the IBR feedback controller and the variations in equivalent grid impedance at the point of interconnection (POI). 
These interactions cause oscillations in the three-phase voltages and currents, which can cause the protection system to trip the renewable plant. 

You can assess the oscillatory instability using admittance/ impedance scanning technique, where the effective admittance/ impedance of 
the renewable plant and the grid are estimated over a range of different frequencies.

Use this admittance scan block to obtain the admittance spectrum of grid connected IBRs.

![](Pictures/AdmiP1.png)

Use this model and the block to study the effect of renewable penetration on small signal stability of the power system.

![](Pictures/Admiscanmodel.png)
![](Pictures/Scanadmi.png)

## Performance Evaluation of Grid Forming Battery Energy Storage Systems in Solar PV Plants
This project evaluates the capabilities of a grid-forming (GFM) battery energy storage system (BESS) in maintaining a stable power system with high penetration of solar photovoltaic (PV) energy sources. 
Use this model to assess the dynamic performance of the BESS connected to the PV plant during normal operation and contingencies, such as a large drop in PV power, significant load change, grid outage, and faults. Simulate the model to verify whether the designed PV plant and BESS unit, along with their associated controllers, conform the performance requirements of the current IEEE 2800 standards. 

![](Pictures/SystemModel.png)

This model provides two control modes for the BESS controller:
The first control mode comprises a phase-locked-loop (PLL)-based grid-following (GFL) BESS controller with voltage and frequency support.
The second control mode comprises a virtual synchronous machine (VSM)-based GFM controller.

These figures show the control schemes for the BESS controllers.

![](Pictures/BESSGFL&GFM.PNG)


## Setup
- Clone the repository and add to MATLAB&reg; path, then click the 'RenewableEnergyIntegrationwithSimscape.prj' file to get started. 
- In the toolstrip, use the project shortcut buttons to load the model.
- This project requires MATLAB&reg; R2024a or later.

Copyright 2022-2025 The MathWorks, Inc.
