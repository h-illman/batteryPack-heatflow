## Project Overview
This repository contains a high-fidelity MATLAB thermal simulation developed for the Western Sunstang Solar Car Project. The tool is designed to predict the transient thermal behavior of a 14.5 kWh accumulator under diverse racing and environmental conditions for the FSGP 2026 MOV class vehicle.

The simulation utilizes a lumped-parameter nodal network to identify "hot spots" and thermal gradients within the pack. This data assists the mechanical team in verifying the effectiveness of the vehicle's unique Ram-Air intake and exhaust fan cooling architecture.

---

## System Specifications
The model is grounded in the technical specifications detailed in the Western University Team 96 Battery Tech Report:

* Architecture: 108V nominal system in a 40p30s configuration.
* Total Energy: 14.5 kWh (~134 Ah capacity).
* Cell Type: Panasonic NCR18650B (Li-ion 18650).
* Cell Parameters: 3.6V nominal, 3350mAh capacity, 48.5g mass.
* Total Cell Count: 1,200 cells.
* Safety Limits: Critical discharge threshold set at 60 degrees Celsius.

---

## Key Features

### 1. Dynamic Ram-Air Cooling Model
Unlike static simulations, this model treats the convective heat transfer coefficient (h) as a function of vehicle velocity (v). 
* Physics: h_total = h_fans + (C_ram * V_car)
* This specifically models the intake tubes pulling air from the back wheel arches and venting via the rear exhaust duct.

### 2. Multi-Scenario Stress Testing
The script includes pre-configured drive cycles to evaluate different boundary conditions:
* Nominal Cruise: Steady travel at 60 km/h (16.7 m/s) with low current draw.
* Sprint: Theoretical maximum performance at 100 km/h (27.8 m/s).
* Hill Climb (Worst Case): High current draw (140A) at low speeds (30 km/h), representing the highest thermal risk.
* Static Heat Soak: Post-race parking analysis for the insulated Fiberglass/Nomex honeycomb battery box.

### 3. Hardware Reliability Layer
Includes a Defect-Injection system to model real-world manufacturing variances:
* Resistance Variance: Simulates higher internal resistance in specific modules due to potential spot-welding or busbar inconsistencies.
* Airflow Blockage: Models reduced cooling efficiency for modules located deep within the box or near exhaust bends.

---

## How to Run
1. Ensure MATLAB (R2023b or later recommended) is installed.
2. Clone the repository: git clone https://github.com/YOUR_USERNAME/Sunstang-Battery-Thermal-Sim.git
3. Open Sunstang_Thermal_Sim.m in MATLAB.
4. Set the Target_Scenario variable to 'All' to run the full comparison suite.
5. Review the generated Scenario Comparison plots to identify thermal bottlenecks.

---

## Validation Protocol
To ensure simulation accuracy, the model is validated against:
* Bench Tests: Comparing simulated delta T against a single 40-cell module under constant 30A load.
* Material Analysis: Adjusting thermal mass based on the Aeropoxy PR2032 laminating resin and Nomex core construction of the battery box.
* Telemetry Correlation: Integration templates for Orion BMS log files to compare real-world cell data with predicted curves.
