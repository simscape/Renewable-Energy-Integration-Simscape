# Renewable Energy Integration Design with Simscape  

Engineering solutions for power systems with high renewable energy integration, compliant with IEEE/IEC standards and national grid codes.  

[![View ​Renewable Energy Integration Design with Simscape on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/123870-renewable-energy-integration-design-with-simscape)
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=simscape/Renewable-Energy-Integration-Simscape)
---

## 📖 Table of Contents  

- Overview  
- Engineering Solutions
  - [Grid-Forming BESS in Solar PV Plants](https://viewer.mathworks.com/addons/123870/25.1.1.1/files/ScriptsData/PVPlant/BatteryStoragePVPlantGFMMainPage.mlx)  
  - [Check Grid-Code Compliance for a Renewable Plant](https://viewer.mathworks.com/addons/123870/25.1.1.1/files/ScriptsData/GridCodeUtils/reportOfGridCodeTest.mlx) 
  - [Grid-Forming Controls for Type-4 Wind Generators](https://viewer.mathworks.com/addons/123870/25.1.1.1/files/ScriptsData/Wind%20Model/MWWindFarmwithGridformingControls.mlx) 
  - [Stability Assessment of Inverter-Based Resources](https://viewer.mathworks.com/addons/123870/25.1.1.1/files/ScriptsData/Admittance%20Scan/AdmittanceScanofIBRsDescription.mlx)
  - [Multi-Terminal HVDC Systems for Offshore Wind](https://viewer.mathworks.com/addons/123870/25.1.1.1/files/ScriptsData/HVDC/MultiTerminalHVDC/MTHVDCModelDescription.mlx) 
  - [Admittance-Based Stability of HVDC Links](https://viewer.mathworks.com/addons/123870/25.1.1.1/files/ScriptsData/HVDC/ScanOfVSCHVDC/VSCHVDCScanandStabilityAnalysis.mlx) 
- Prerequisites
- Setup
---

## 🌍 Overview  

This repository provides workflows for modeling, simulation, and stability assessment of renewable energy systems. It enables:  

- Study of high **inverter based resource (IBR)** penetration and grid stability  
- Comparison of **grid-forming (GFM) vs. grid-following (GFL)** controls  
- Evaluation of compliance with **IEEE 2800, IRE**, and **national grid codes**  
- Assessment of **fault ride-through (FRT), frequency/voltage support, GFM control for Offshore wind with HVDC**  
- **Impedance/admittance scanning** for oscillation and stability studies  

---

## ⚡ Engineering Solutions  

### Grid-Forming BESS in Solar PV Plants  

| ![PV Plant with BESS](Pictures/SystemModel.png) |  
|-----------------------------------------------|  
| **Description:** A **grid-forming battery energy storage system (GFM-BESS)** stabilizes solar PV plants. Includes **IEEE 2800 compliance tests** for frequency and voltage support. |  

---

### Grid-Forming Controls for Type-4 Wind Generators  

| ![GFM Wind](Pictures/WindFarm.PNG) <br><br> ![MGFM](Pictures/MGFMwind.PNG) |  
|-----------------------------------------------------------------------------|  
| **Description:** Implements two grid-forming strategies for wind generators: **DC-link regulation (GGFM)** and **turbine inertia emulation (MGFM)**. Evaluated under **fault ride-through (FRT)** conditions. |  

---

### Stability Assessment of Inverter-Based Resources  

| ![Admittance Scan Model](Pictures/Admiscanmodel.png) |  
|--------------------------------------------------------------------------------------------------|  
| **Description:** **Admittance scanning** identifies oscillatory instabilities in IBR-dominated systems. Features **Bode plots, eigenvalue tracking, and mode interaction analysis**. |  

---

### Multi-Terminal HVDC Systems for Offshore Wind  

| ![MTHVDC Model](Pictures/HVDCModelGFM.png) |  
|---------------------------------------------|  
| **Description:** Models **multi-terminal VSC-HVDC systems** for offshore wind integration. Tested under **grid faults, asynchronous operation, and variation in grid strength**. |  

---

### Admittance-Based Stability of HVDC Links  

| ![AdmiHVDC Model](Pictures/HVDCScan.png) |  
|-------------------------------------------|  
| **Description:** Demonstrates **admittance scanning and stability analysis** of a **two-terminal VSC-HVDC system** linking offshore wind farms to the grid. |  

---

## 🛠️ Prerequisites  

- MATLAB® **R2025a** or later  
- Simscape™  and Simscape™  Electrical toolboxes  

---

## 🚀 Setup  

Download the repository and open the MATLAB project.

