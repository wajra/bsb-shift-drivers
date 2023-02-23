# Repository for Bandara, Pinsky, Curchitser (2023)

This repository contains the code necessary for running the calculations, species distribution models, and visualizations in the associated publication.

Please read this text to properly execute the code.

Languages: R (Version 4.1+) and Python (Version 2.7+)

Computer environments: The R code was natively run on an Apple Macbook computer runnig MacOS Catalina 10.15. The Python code was run on **Poseidon**; a Linux server computer housed at the Department of Environmental Sciences ([Link](https://envsci.rutgers.edu/)). Please contact the technical personnel (help@envsci.rutgers.edu) in that department to gain access to or assistance regarding this server. Please note that running the Python code requires a large number of daily ROMS hindcast files that are of significant size (0.7 GB/file). It's not feasible to store these files on a service such as GitHub.



Package requirements

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

## Section 1: Cleaning up the data and calculating seasonal values environmental and physiological parameters

Please read this section if you are interested in calculating seasonal variables from the ROMS hindcast datasets. Seasonal values are calculated for salinity, zooplankton density, and dissolved oxygen. Metabolic Index (MI) is then calculated from these values and associated with each haul.



## Section 2: Species Distribution Models

This section contains the code required to run a list of alternative species distribution models for Black Sea Bass. The list of models is shown below with the relevant .R file. These are 

|Model class   |Model name   | Abbreviation  | File  |
|---|---|---|---|
|-   |Null model   |-   |   |
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

Each model run produces PDF plots with GAM smooths for presence/absence and biomass as well as saved model objects for the GAMs. 

## Section 3: Visualizing SDM results


