# Repository for Bandara, Curchitser, Pinsky (2023)

This repository contains the code and data necessary for running the calculations, species distribution models, and visualizations in Bandara et al. (2023) published in Global Change Biology. 

Please read this guide to properly execute the code.

_Languages_: R (Version 4.1+) and Python (Version 2.7+)

_Computer environments_: The R code was natively run on an Apple Macbook computer running MacOS Catalina 10.15. The Python code was run on **Poseidon** and **Proteus**, two Linux server computers housed at the Department of Environmental Sciences at Rutgers University ([Link](https://envsci.rutgers.edu/)). Please contact the technical personnel ([help\@envsci.rutgers.edu](mailto:help@envsci.rutgers.edu)) in that department to gain access to or assistance regarding this server. Please note that running certain parts of the Python code requires a large number of daily ROMS hindcast files that are of significant size (0.7 GB/file). It's not feasible to store these files on a service such as GitHub or FigShare/Zenodo.

## Package requirements

### R

|Package name   |Version   |
|---|---|
|tidyverse   |1.3.1   |
|mgcv   |1.8.40   |
|sf   |1.0.8   |
|rnaturalearth   |0.1.0   |
|rnaturalearthdata   |0.1.0   |
|ggspatial   |1.1.5   |
|scales   |1.2.1   |
|dismo   |1.3.5   |
|beepr   |1.3   |
|respirometry   |1.3.0   |
|gridExtra   |2.3   |
|cowplot   |1.1.1   |
|DescTools   |0.99.48   |
|Hmisc   |4.7.1   |
|corrplot   |0.92   |

### Python

|Package name   |Version   |
|---|---|
|pandas   |0.23+   |
|pyroms   |1.0+   |
|pyroms_toolbox   |1.0+   |
|matplotlib   |2.0+   |
|mpl_toolkits   |1.2+   |
|numpy   |1.1+   |
|netCDF4   |4.3+   |

## Section 1: Cleaning up the ROMS-COBALT hindcast data and calculating seasonal values environmental and physiological parameters

Please read this section if you are interested in calculating seasonal variables from the ROMS hindcast datasets. Seasonal values are calculated for salinity, zooplankton density, and dissolved oxygen. Metabolic Index (MI) is then calculated from these values and associated with each haul. This is done by `part_01_calculate_seasonal_values.py` in the `Python` subfolder. The decadal differences for several environmental parameters is calculated by `part_02_visualize_change_over_time_nwa.py` in the same subfolder.

## Section 2: Data Prep & Species Distribution Models

The `R/data_prep` folder contains code for prepping the output from Section 1 for model runs. The `data` folder contains all relevant data required to run models and generate figures in the manuscript.
The `R/models` contains the code to run a list of alternative species distribution models for Black Sea Bass. The list of models is shown below with links to the relevant .R file.

### Single variable models

| Model name       | Abbreviation | File                                                                                                           |
|-------------------------|-----------------------------|------------------|
| Null Model       | \-           | [[1]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_01_null_model.R)             |
| Salinity         | S            | [[2]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_02_salinity_model.R)         |
| Temperature      | T            | [[3]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_03_temperature_model.R)      |
| Dissolved Oxygen | O            | [[4]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_04_dissolved_oxygen_model.R) |
| Zooplankton      | Z            | [[5]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_05_zooplankton_model.R)      |
| Metabolic Index  | MI           | [[6]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_06_metabolic_index_model.R)  |

### Multiple variable models

| Model class | Model name                                                                               | Abbreviation | File                                                                                                                              |
|------------------|------------------|------------------|------------------|
| \-          | Null model                                                                               | \-           | [[1]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_01_null_model.R)                                |
| T           | Temperature + Dissolved Oxygen                                                           | T+O          | [[2]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_07_temperature_do_model.R)                      |
| T           | Temperature + Salinity                                                                   | T+S          | [[3]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_09_temperature_salinity_model.R)                |
| T           | Temperature + Zooplankton                                                                | T+Z          | [[4]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_10_temperature_zooplankton_model.R)             |
| T           | Temperature + Metabolic Index                                                            | T+MI         | [[5]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_08_temperature_mi_model.R)                      |
| T           | Temperature + Dissolved Oxygen + Zooplankton                                             | T+O+Z        | [[6]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_11_temperature_do_zooplankton_model.R)          |
| T           | Temperature + Dissolved Oxygen + Salinity                                                | T+O+S        | [[7]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_12_temperature_do_salinity_model.R)             |
| T           | Temperature + Dissolved Oxygen + Salinity + Zooplankton                                  | T+O+S+Z      | [[8]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_13_temperature_do_salinity_zooplankton_model.R) |
| Hybrid      | Temperature + Dissolved Oxygen + Temperature-Oxygen interaction                          | T+O+T:O      | [[9]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_14_temperature_do_temp_do_interaction_model.R)  |
| Hybrid      | Temperature + Dissolved Oxygen + Metabolic Index                                         | T+O+MI       | [[10]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_15_temperature_do_mi_model.R)                   |
| Hybrid      | Temperature + Dissolved Oxygen + Salinity + Zooplankton + Metabolic Index                | T+O+S+Z+MI   | [[11]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_16_temperature_do_mi_s_z_model.R)               |
| Hybrid      | Temperature + Dissolved Oxygen + Salinity + Zooplankton + Temperature-Oxygen interaction | T+O+S+Z+T:O  | [[12]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_17_temperature_do_interaction_s_z_model.R)      |
| MI          | Metabolic Index + Salinity                                                               | MI+S         | [[13]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_18_mi_s_model.R)                                |
| MI          | Metabolic Index + Zooplankton                                                            | MI+Z         | [[14]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_19_mi_z_model.R)                                |
| MI          | Metabolic Index + Salinity + Zooplankton                                                 | MI+S+Z       | [[15]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_20_mi_s_z_model.R)                              |
| T:O         | Temperature-Oxygen interaction + Salinity                                                | T:O+S        | [[16]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_21_interaction_s_model.R)                       |
| T:O         | Temperature-Oxygen interaction + Zooplankton                                             | T:O+Z        | [[17]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_22_interaction_z_model.R)                     |
| T:O         | Temperature-Oxygen interaction + Salinity + Zooplankton                                  | T:O+S+Z      | [[18]](https://github.com/wajra/bsb-shift-drivers/blob/main/R/models/sp_dist_model_23_interaction_s_z_model.R)                       |

Each model run produces PDF plots with GAM smoothed curves for presence/absence and biomass as well as saved model objects for the GAMs. These outputs are stored in the `roms_tt_split_output` folder.


## Section 3: Visualizing SDM results

Visualizations for the best performing model are done by the code in `R/models_viz`. These figures can be found in the `roms_tt_split_output/figures` folder.

If you run into any issues running this code, please feel free to reach out to me ([jeewantha.bandara\@rutgers.edu](mailto:jeewantha.bandara@rutgers.edu))


