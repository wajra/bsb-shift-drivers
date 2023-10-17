# Python Code

This README.md contains a general guide to the Python scripts that were used to process and visualize data for Bandara et al. (2023)

Please read this text to properly execute the code.

Languages: Python (Version 2.7+)

The Python code was run on **Poseidon** and **Proteus**; two Linux server computers housed at the Department of Environmental Sciences ([Link](https://envsci.rutgers.edu/)) depending on server availability. Both servers were interchangeable for our purposes. Please contact the technical personnel ([help\@envsci.rutgers.edu](mailto:help@envsci.rutgers.edu){.email}) in that department to gain access to or assistance regarding these servers. Please note that running the Python code requires a large number of daily ROMS hindcast files that are of significant size (0.7 GB/file). It's not feasible to store these files on a service such as GitHub.

#### Package requirements

*Python*

1.  `os`
2.  `re`
3.  `glob`
4.  `pandas`
5.  `datetime`
6.  `dateutil`
7.  `pyroms`
8.  `pyroms_toolbox`
9.  `matplotlib`
10. `mpl_toolkits` (Basemap)
11. `numpy`
12. `netCDF4`

Please read the following for a general outline and purpose of each of the scripts we have uploaded here

1. `functions_for_roms.py` - This script contains one major function. `get_file_index` builds an index of daily ROMS model hindcasts from 1982 to 2010 and assigns them to a year-month-date format so that they can be easily called for processing. There is also a piece of codein the __main__ section that tests the function for it's functionality.
2. `part_01_calculate_seasonal_values.py` - This script contains separate functions for calculating seasonal means for temperature, dissolved oxygen, zooplankton, and salinity. In the __main__ section of the code, we get all the unique dates for hauls associated with Black Sea Bass, and compute seasonal means for each of these covariates. We then output these values in a single dataframe associated with the hauls.
3. `part_02_visualize_change_over_time.py` - This script produces Figure 2 in the paper. For each covariate, we have computed the decadal means for the 1980s and 2000s. We visualize the distribution of the covariates in the North West Atlantic (NWA) in the 1980s and the change over time (2000s - 1980s for each covariate).

