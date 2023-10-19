# models

This README.md contains a general guide to the R scripts that were used run all the models for Bandara et al. (2023)

Please read this text to properly execute the code.

Languages: R (Version 4.1+)

Computer environments: The R code was natively run on an Apple Macbook computer running MacOS Catalina 10.15. It was also tested successfully on a system running MacOS Ventura 13.X+

Each of these scripts are a model described in the manuscript. The output of each models are PDF plots of GAM responses as well diagnostics. The models are described in the table below.

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

