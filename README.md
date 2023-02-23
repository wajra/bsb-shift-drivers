# Repository for Bandara, Pinsky, Curchitser (2023)

This repository contains the code necessary for running the calculations, species distribution models, and visualizations in the associated publication.

Please read this text to properly execute the code.

Languages: R (Version 4.1+) and Python (Version 2.7+)

Computer environments: The R code was natively run on an Apple Macbook computer running MacOS Catalina 10.15. The Python code was run on **Poseidon**; a Linux server computer housed at the Department of Environmental Sciences ([Link](https://envsci.rutgers.edu/)). Please contact the technical personnel (help@envsci.rutgers.edu) in that department to gain access to or assistance regarding this server. Please note that running the Python code requires a large number of daily ROMS hindcast files that are of significant size (0.7 GB/file). It's not feasible to store these files on a service such as GitHub.

#### Package requirements

*R*

1. `tidyverse`
2. `mgcv`
3. `sf`
4. `rnaturalearth`
5. `rnaturalearthdata`
6. `ggspatial`
7. `scales`
8. `dismo`
9. `beepr`
10. `respirometry`

*Python*

1. `os`
2. `re`
3. `glob`
3. `pandas`
4. `datetime`
5. `dateutil`
6. `pyroms`
7. `pyroms_toolbox`
8. `matplotlib`
9. `mpl_toolkits` (Basemap)
10. `numpy`
11. `netCDF4`

## Section 1: Cleaning up the ROMS-COBALT hindcast data and calculating seasonal values environmental and physiological parameters

Please read this section if you are interested in calculating seasonal variables from the ROMS hindcast datasets. Seasonal values are calculated for salinity, zooplankton density, and dissolved oxygen. Metabolic Index (MI) is then calculated from these values and associated with each haul. This is done by `part_01_calculate_seasonal_values.py` in the Python subfolder. The decadal differences for several environmental parameters is calculated by `part_02_visualize_change_over_time_nwa.py` in the same subfolder.



## Section 2: Data Prep & Species Distribution Models

The `R/data_prep` folder contains code for prepping the output from Section 1 for model runs.
The `R/models` contains the code to run a list of alternative species distribution models for Black Sea Bass. The list of models is shown below with links to the relevant .R file.

|Model class   |Model name   | Abbreviation  | File  |
|---|---|---|---|
|-   |Null model   |-   | [[1]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_01_null_model.R)  |
|T   |Temperature + Dissolved Oxygen   |T+O   |   |
|T   |Temperature + Salinity   |T+S   |   |
|T   |Temperature + Zooplankton   |T+Z   |   |
|T   |Temperature + Metabolic Index   |T+MI   |   |
|T   |Temperature + Dissolved Oxygen + Zooplankton   |T+O+Z   |   |
|T   |Temperature + Dissolved Oxygen + Salinity   |T+O+S   |   |
|T   |Temperature + Dissolved Oxygen + Salinity + Zooplankton   |T+O+S+Z   |   |
|Hybrid   |Temperature + Dissolved Oxygen + Temperature-Oxygen interaction    |T+O+T:O   |   |
|Hybrid   |Temperature + Dissolved Oxygen + Metabolic Index   |T+O+MI   |   |
|Hybrid   |Temperature + Dissolved Oxygen + Salinity + Zooplankton + Metabolic Index   |T+O+S+Z+MI   |   |
|Hybrid   |Temperature + Dissolved Oxygen + Salinity + Zooplankton + Temperature-Oxygen interaction   |T+O+S+Z+T:O   |   |
|MI   |Metabolic Index + Salinity   |MI+S   |   |
|MI   |Metabolic Index + Zooplankton   |MI+Z   |   |
|MI   |Metabolic Index + Salinity + Zooplankton   |MI+S+Z   |   |
|T:O   |Temperature-Oxygen interaction + Salinity   |T:O+S   |   |
|T:O   |Temperature-Oxygen interaction + Zooplankton   |T:O+Z   |   |
|T:O   |Temperature-Oxygen interaction + Salinity + Zooplankton   |T:O+S+Z   |   |

Each model run produces PDF plots with GAM smooths for presence/absence and biomass as well as saved model objects for the GAMs. These outputs are stored in the `roms_tt_split_output` folder.

## Section 3: Visualizing SDM results

Visualizations for the best performing model are done by the code in `R/models_viz`. These figures can be found in the `roms_tt_split_output/figures` folder.

If you run into any issues running this code, please feel free to reach out to me (jeewantha.bandara@rutgers.edu)

