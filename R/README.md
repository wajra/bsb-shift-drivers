# R Code

This README.md contains a general guide to the R scripts that were used to process and visualize data for Bandara et al. (2023)

Please read this text to properly execute the code.

Languages: R (Version 4.1+)

Computer environments: The R code was natively run on an Apple Macbook computer running MacOS Catalina 10.15. It was also tested successfully on a system running MacOS Ventura 13.X+

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

A brief description of the folders listed here and their purpose

1. `data_prep` - Script for visualizing and preparing ROMS hindcast data and NEUS bottom trawl survey  for modeling
2. `models` - Scripts for each model
3. `models_viz` - Scripts for visualizing model results

