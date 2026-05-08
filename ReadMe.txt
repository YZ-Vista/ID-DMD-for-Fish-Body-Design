# Fish Hydrodynamic Dataset and ID-DMD Workflow

All fish hydrodynamic data are summarised in the folder **`Fishes dataset`**.  
The dataset includes 15 fish species, together with their body shapes and corresponding hydrodynamic fields, including:

- Pressure fields
- Velocity fields
- Vorticity fields

## Code Workflow

Please run the code in the following order:

### A0s: Fish Body Shape Analysis

This part analyses the 2D fish body shapes and extracts shape features for subsequent modelling and design.

### A1s: Fluid Field Dynamics Analysis

This part analyses the fluid-field dynamics of the fish swimming simulations, including pressure, velocity, and vorticity fields.

### B: ID-DMD Identification

This part identifies the inverse-design Dynamic Mode Decomposition model based on the extracted fish-shape and hydrodynamic-field data.

### C: Data Preparation for Optimisation

This part prepares the ID-DMD-based reduced-order data required for optimisation and design.

### D: Optimisation and Design

This part performs optimisation and design based on the trained ID-DMD model.