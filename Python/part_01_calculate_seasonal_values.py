from functions_for_roms import get_file_index
import os
import re
import glob
from pandas import DataFrame
import datetime
from datetime import timedelta
from dateutil.relativedelta import relativedelta
import pandas as pd
import pyroms
import pyroms_toolbox
import matplotlib.pyplot as plt
import numpy as np
import numpy.ma as ma

# parameters_file_path = '/Users/jeewantha/Code/data/monthly_means/'
parameters_file_path = '/Volumes/P4/workdir/jeewantha/data/monthly_means_2/'
nwa_grd = pyroms.grid.get_ROMS_grid('NWA')


# Create plot of whatever grid you want
def create_monthly_mean_plot(data_array, plot_date, parameter):
  grd = pyroms.grid.get_ROMS_grid('NWA')
lon = grd.hgrid.lon_rho
lat = grd.hgrid.lat_rho
plt.figure()
# plt.pcolor(lon, lat, daily_o2[0], vmin=bottom_min, vmax=bottom_max)
plt.pcolor(lon, lat, data_array, cmap='RdYlGn')
plt.colorbar()
plt.axis('image')
plt.title('{0} for {1}'.format(parameter, plot_date))
# Plot coastline
pyroms_toolbox.plot_coast_line(grd)
# Save plot
outfile = '/Users/jeewantha/Code/images/monthly_means/{0}_bottom_ver_1.png'.format(parameter)
plt.savefig(outfile, dpi=300, orientation='portrait')
plt.close()
return True


# But would the netCDF4 file be the best cause of action?
# Just writing text files. Would that work?
# Create a netCDF4 file with monthly averages for a certain date
# Haul date is a datetime object
def create_monthly_mean(haul_date):
  haul_date = pd.to_datetime(haul_date)
daily_index = get_file_index()
start_date = haul_date - relativedelta(months=1)
end_date = haul_date + relativedelta(months=2)
file_paths = daily_index.loc[start_date:end_date, 'file_path'].tolist()
# For O2, Large zooplankton, Medium Zooplankton, Small zooplankton
o2_list = []
lg_zplk = []
me_zplk = []
sm_zplk = []
temp = []
for file_path in file_paths:
  daily_o2 = pyroms.utility.get_nc_var('o2', file_path)[0]
daily_lg_zplk = pyroms.utility.get_nc_var('nlgz', file_path)[0]
daily_me_zplk = pyroms.utility.get_nc_var('nmdz', file_path)[0]
daily_sm_zplk = pyroms.utility.get_nc_var('nsmz', file_path)[0]
daily_temp = pyroms.utility.get_nc_var('temp', file_path)[0]
# Append the values to
o2_list.append(daily_o2[0])
lg_zplk.append(daily_lg_zplk[0])
me_zplk.append(daily_me_zplk[0])
sm_zplk.append(daily_sm_zplk[0])
temp.append(daily_temp[0])
# Calculate the mean across axis=0
mean_o2 = ma.mean(ma.array(o2_list), axis=0)
mean_lg_zplk = ma.mean(ma.array(lg_zplk), axis=0)
mean_me_zplk = ma.mean(ma.array(me_zplk), axis=0)
mean_sm_zplk = ma.mean(ma.array(sm_zplk), axis=0)
mean_temp = ma.mean(ma.array(temp), axis=0)
storage_location = parameters_file_path + '{0}/{1}/'.format(haul_date.year, haul_date.month)
# If the path does not exist
if not os.path.exists(storage_location):
  os.makedirs(storage_location)
print('Path newly created')
else:
  print('Path exists')
files_to_write = [mean_o2, mean_lg_zplk, mean_me_zplk, mean_sm_zplk, mean_temp]
file_names_to_write = ['o2_data.out', 'lg_zplk_data.out', 'me_zplk_data.out', 'sm_zplk_data.out', 'temp_data.out']
for file_name, file_to_write in zip(file_names_to_write, files_to_write):
  file_name = storage_location + file_name
# np.savetxt(file_name, file_to_write)
file_to_write.dump(file_name)
print('Saved {0}'.format(file_name))
print('Success')


def get_zooplankton_total_column(haul_date):
  haul_date = pd.to_datetime(haul_date)
daily_index = get_file_index()
start_date = haul_date - relativedelta(months=1)
end_date = haul_date + relativedelta(months=2)
file_paths = daily_index.loc[start_date:end_date, 'file_path'].tolist()
# For Large zooplankton, Medium Zooplankton, Small zooplankton
lg_zplk = []
me_zplk = []
sm_zplk = []
for file_path in file_paths:
  daily_lg_zplk = pyroms.utility.get_nc_var('nlgz', file_path)[0]
daily_me_zplk = pyroms.utility.get_nc_var('nmdz', file_path)[0]
daily_sm_zplk = pyroms.utility.get_nc_var('nsmz', file_path)[0]
# Append the values to the empty lists
lg_zplk.append(ma.sum(daily_lg_zplk, axis=0))
me_zplk.append(ma.sum(daily_me_zplk, axis=0))
sm_zplk.append(ma.sum(daily_sm_zplk, axis=0))
# Calculate the mean in the lists across axis=0
mean_lg_zplk = ma.mean(ma.array(lg_zplk), axis=0)
mean_me_zplk = ma.mean(ma.array(me_zplk), axis=0)
mean_sm_zplk = ma.mean(ma.array(sm_zplk), axis=0)
storage_location = parameters_file_path + '{0}/{1}/'.format(haul_date.year, haul_date.month)
# If the path does not exist
if not os.path.exists(storage_location):
  os.makedirs(storage_location)
print('Path newly created')
else:
  print('Path exists')
files_to_write = [mean_lg_zplk, mean_me_zplk, mean_sm_zplk]
file_names_to_write = ['lg_zplk_sum_data.out', 'me_zplk_sum_data.out', 'sm_zplk_sum_data.out']
for file_name, file_to_write in zip(file_names_to_write, files_to_write):
  file_name = storage_location + file_name
# np.savetxt(file_name, file_to_write)
file_to_write.dump(file_name)
print('Saved {0}'.format(file_name))
print('Success')



def get_zooplankton_class_mean(haul_date):
  haul_date = pd.to_datetime(haul_date)
daily_index = get_file_index()
start_date = haul_date - relativedelta(months=1)
end_date = haul_date + relativedelta(months=2)
file_paths = daily_index.loc[start_date:end_date, 'file_path'].tolist()
# For Large zooplankton, Medium Zooplankton, Small zooplankton
tot_zplk_list = []
for file_path in file_paths:
  daily_lg_zplk = pyroms.utility.get_nc_var('nlgz', file_path)[0]
daily_me_zplk = pyroms.utility.get_nc_var('nmdz', file_path)[0]
daily_sm_zplk = pyroms.utility.get_nc_var('nsmz', file_path)[0]
# Append the values to the empty lists
# daily_o2[0]
tot_zplk = daily_lg_zplk[0] + daily_me_zplk[0] + daily_sm_zplk[0]
tot_zplk_list.append(tot_zplk)
# Calculate the mean in the lists across axis=0
mean_tot_zplk = ma.mean(ma.array(tot_zplk_list), axis=0)
storage_location = parameters_file_path + '{0}/{1}/'.format(haul_date.year, haul_date.month)
# If the path does not exist
if not os.path.exists(storage_location):
  os.makedirs(storage_location)
print('Path newly created')
else:
  print('Path exists')
files_to_write = [mean_tot_zplk]
file_names_to_write = ['mean_tot_zplk.out']
for file_name, file_to_write in zip(file_names_to_write, files_to_write):
  file_name = storage_location + file_name
# np.savetxt(file_name, file_to_write)
file_to_write.dump(file_name)
print('Saved {0}'.format(file_name))
print('Success')

# Python method to get salinity data
def get_salinity(haul_date):
  haul_date = pd.to_datetime(haul_date)
daily_index = get_file_index()
start_date = haul_date - relativedelta(months=1)
end_date = haul_date + relativedelta(months=2)
file_paths = daily_index.loc[start_date:end_date, 'file_path'].tolist()
# Empty arrays for salinity
salinity = []
for file_path in file_paths:
  daily_salinity = pyroms.utility.get_nc_var('salt', file_path)[0]
# Append the values to the empty lists
salinity.append(daily_salinity[0])
# Calculate the mean in the lists across axis=0
# ma.mean(ma.array(o2_list), axis=0)
mean_salinity = ma.mean(ma.array(salinity), axis=0)
storage_location = parameters_file_path + '{0}/{1}/'.format(haul_date.year, haul_date.month)
# If the path does not exist
if not os.path.exists(storage_location):
  os.makedirs(storage_location)
print('Path newly created')
else:
  print('Path exists')
files_to_write = [mean_salinity]
file_names_to_write = ['mean_salinity.out']
for file_name, file_to_write in zip(file_names_to_write, files_to_write):
  file_name = storage_location + file_name
# np.savetxt(file_name, file_to_write)
file_to_write.dump(file_name)
print('Saved {0}'.format(file_name))
print('Success')

# This calcualte the mean total for 3 zooplankton class across the whole
# water column
def get_zooplankton_class_sum_across_column(haul_date):
  haul_date = pd.to_datetime(haul_date)
daily_index = get_file_index()
start_date = haul_date - relativedelta(months=1)
end_date = haul_date + relativedelta(months=2)
file_paths = daily_index.loc[start_date:end_date, 'file_path'].tolist()
# For Large zooplankton, Medium Zooplankton, Small zooplankton
daily_zplk_total_array = []
for file_path in file_paths:
  daily_lg_zplk = pyroms.utility.get_nc_var('nlgz', file_path)[0]
daily_me_zplk = pyroms.utility.get_nc_var('nmdz', file_path)[0]
daily_sm_zplk = pyroms.utility.get_nc_var('nsmz', file_path)[0]
daily_zplk_total = daily_lg_zplk + daily_me_zplk + daily_sm_zplk
# Append the values to the empty lists
daily_zplk_total_array.append(ma.sum(daily_zplk_total, axis=0))
#ma.sum(daily_lg_zplk, axis=0)
# Calculate the mean in the lists across axis=0
mean_daily_zplk_total = ma.mean(ma.array(daily_zplk_total_array), axis=0)
storage_location = parameters_file_path + '{0}/{1}/'.format(haul_date.year, haul_date.month)
# If the path does not exist
if not os.path.exists(storage_location):
  os.makedirs(storage_location)
print('Path newly created')
else:
  print('Path exists')
files_to_write = [mean_daily_zplk_total]
file_names_to_write = ['mean_daily_zplk_column_total.out']
for file_name, file_to_write in zip(file_names_to_write, files_to_write):
  file_name = storage_location + file_name
# np.savetxt(file_name, file_to_write)
file_to_write.dump(file_name)
print('Saved {0}'.format(file_name))
print('Success')



############ - From here we start matching the values to hauls ######
#####################################################################


# A method where we feed a row and get the corresponding
# [O2] value for the haul/row
def get_o2_mean(row):
  year = int(row['year'])
month = int(row['month'])
o2_file_loc = '{0}{1}/{2}/o2_data.out'.format(parameters_file_path,
                                              year, month)
print(o2_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(o2_file_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# surrounding_indices = [(j + 2, i), (j + 2, i + 2), (j, i + 2), (j - 2, i + 2), (j - 2, i), (j - 2, i - 2),
#                       (j, i - 2), (j + 2, i - 2)]
# Load the masked array
# print('{0}, {1}'.format(i, j))
with open(o2_file_loc) as o2_file:
  o2_array = np.load(o2_file)
# fill up the masked values with np.nan
o2_array = o2_array.filled(np.nan)
# print(o2_array.shape)
# Get the [O2] value from the array
o2_value = o2_array[j, i]
if np.isnan(o2_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(o2_array[new_j, new_i])
np_array = np.array(test_array)
o2_value = np.nanmean(np_array)
# print(o2_value)
return o2_value
return None


# A method where we feed a row and get the corresponding
# [N2] for Small Zooplankton value for the haul/row
def get_sm_zplk_mean(row):
  year = int(row['year'])
month = int(row['month'])
sm_zplk_file_loc = '{0}{1}/{2}/sm_zplk_data.out'.format(parameters_file_path,
                                                        year, month)
# print(sm_zplk_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(sm_zplk_file_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
sm_zplk_array = np.load(sm_zplk_file_loc)
sm_zplk_array = sm_zplk_array.filled(np.nan)
# Get the [O2] value from the array
sm_zplk_value = sm_zplk_array[j, i]
if np.isnan(sm_zplk_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(sm_zplk_array[new_j, new_i])
np_array = np.array(test_array)
sm_zplk_value = np.nanmean(np_array)
return sm_zplk_value
return None


# A method where we feed a row and get the corresponding
# [N2] for Medium Zooplankton value for the haul/row
def get_me_zplk_mean(row):
  year = int(row['year'])
month = int(row['month'])
me_zplk_file_loc = '{0}{1}/{2}/me_zplk_data.out'.format(parameters_file_path,
                                                        year, month)
# print(me_zplk_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(me_zplk_file_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
me_zplk_array = np.load(me_zplk_file_loc)
me_zplk_array = me_zplk_array.filled(np.nan)
# Get the [O2] value from the array
me_zplk_value = me_zplk_array[j, i]
if np.isnan(me_zplk_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(me_zplk_array[new_j, new_i])
np_array = np.array(test_array)
me_zplk_value = np.nanmean(np_array)
return me_zplk_value
return None


# A method where we feed a row and get the corresponding
# [N2] for Large Zooplankton value for the haul/row
def get_lg_zplk_mean(row):
  year = int(row['year'])
month = int(row['month'])
lg_zplk_file_loc = '{0}{1}/{2}/lg_zplk_data.out'.format(parameters_file_path,
                                                        year, month)
# print(lg_zplk_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(lg_zplk_file_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
lg_zplk_array = np.load(lg_zplk_file_loc)
lg_zplk_array = lg_zplk_array.filled(np.nan)
# Get the [O2] value from the array
lg_zplk_value = lg_zplk_array[j, i]
if np.isnan(lg_zplk_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(lg_zplk_array[new_j, new_i])
np_array = np.array(test_array)
lg_zplk_value = np.nanmean(np_array)
return lg_zplk_value
return None


# A method where we feed a row and get the corresponding
# Celsius value for the bottom temperature value for the haul/row
def get_temp_mean(row):
  year = int(row['year'])
month = int(row['month'])
temp_file_loc = '{0}{1}/{2}/temp_data.out'.format(parameters_file_path,
                                                  year, month)
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(temp_file_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
temp_array = np.load(temp_file_loc)
temp_array = temp_array.filled(np.nan)
# Get the [O2] value from the array
temp_value = temp_array[j, i]
if np.isnan(temp_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(temp_array[new_j, new_i])
np_array = np.array(test_array)
temp_value = np.nanmean(np_array)
return temp_value
return None

# A method where we feed a row and get the corresponding
# [N2] for Small Zooplankton value for the haul/row
def get_column_sm_zplk_mean(row):
  year = int(row['year'])
month = int(row['month'])
sm_zplk_file_loc = '{0}{1}/{2}/sm_zplk_sum_data.out'.format(parameters_file_path,
                                                            year, month)
# print(sm_zplk_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(sm_zplk_file_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
sm_zplk_array = np.load(sm_zplk_file_loc)
sm_zplk_array = sm_zplk_array.filled(np.nan)
# Get the [O2] value from the array
sm_zplk_value = sm_zplk_array[j, i]
if np.isnan(sm_zplk_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(sm_zplk_array[new_j, new_i])
np_array = np.array(test_array)
sm_zplk_value = np.nanmean(np_array)
return sm_zplk_value
return None


# A method where we feed a row and get the corresponding
# [N2] for Medium Zooplankton value for the haul/row
def get_column_me_zplk_mean(row):
  year = int(row['year'])
month = int(row['month'])
me_zplk_file_loc = '{0}{1}/{2}/me_zplk_sum_data.out'.format(parameters_file_path,
                                                            year, month)
# print(me_zplk_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(me_zplk_file_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
me_zplk_array = np.load(me_zplk_file_loc)
me_zplk_array = me_zplk_array.filled(np.nan)
# Get the [O2] value from the array
me_zplk_value = me_zplk_array[j, i]
if np.isnan(me_zplk_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(me_zplk_array[new_j, new_i])
np_array = np.array(test_array)
me_zplk_value = np.nanmean(np_array)
return me_zplk_value
return None


# A method where we feed a row and get the corresponding
# [N2] for Large Zooplankton value for the haul/row
def get_column_lg_zplk_mean(row):
  year = int(row['year'])
month = int(row['month'])
lg_zplk_file_loc = '{0}{1}/{2}/lg_zplk_sum_data.out'.format(parameters_file_path,
                                                            year, month)
# print(lg_zplk_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(lg_zplk_file_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
lg_zplk_array = np.load(lg_zplk_file_loc)
lg_zplk_array = lg_zplk_array.filled(np.nan)
# Get the [O2] value from the array
lg_zplk_value = lg_zplk_array[j, i]
if np.isnan(lg_zplk_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(lg_zplk_array[new_j, new_i])
np_array = np.array(test_array)
lg_zplk_value = np.nanmean(np_array)
return lg_zplk_value
return None


# Method to get the corresponding salinity value for
# a haul
def get_salinity_mean(row):
  year = int(row['year'])
month = int(row['month'])
mean_salinity_loc = '{0}{1}/{2}/mean_salinity.out'.format(parameters_file_path,
                                                          year, month)
# print(lg_zplk_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(mean_salinity_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
salinity_array = np.load(mean_salinity_loc)
salinity_array = salinity_array.filled(np.nan)
# Get the [O2] value from the array
salinity_value = salinity_array[j, i]
if np.isnan(salinity_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(salinity_array[new_j, new_i])
np_array = np.array(test_array)
salinity_value = np.nanmean(np_array)
return salinity_value
return None


# Get mean total zooplankton classes sum out
# A method where we feed a row and get the corresponding
# [N2] for mean sum bottom Zooplankton value for the haul/row
def get_tot_zplk_mean(row):
  year = int(row['year'])
month = int(row['month'])
tot_zplk_file_loc = '{0}{1}/{2}/mean_tot_zplk.out'.format(parameters_file_path,
                                                          year, month)
# print(sm_zplk_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(tot_zplk_file_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
tot_zplk_array = np.load(tot_zplk_file_loc)
tot_zplk_array = tot_zplk_array.filled(np.nan)
# Get the [O2] value from the array
tot_zplk_value = tot_zplk_array[j, i]
if np.isnan(tot_zplk_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(tot_zplk_array[new_j, new_i])
np_array = np.array(test_array)
tot_zplk_value = np.nanmean(np_array)
return tot_zplk_value
return None

# Get mean total zooplankton classes sum out
# A method where we feed a row and get the corresponding
# [N2] for mean sum bottom Zooplankton value for the haul/row
def get_zplk_class_total_across_column(row):
  year = int(row['year'])
month = int(row['month'])
mean_daily_zplk_total_loc = '{0}{1}/{2}/mean_daily_zplk_column_total.out'.format(parameters_file_path,
                                                                                 year, month)
# print(sm_zplk_file_loc)
# Get longitude
haul_lon = row['lon']
# Since the coordinate system is a little odd we have to add
# 360 to the normal value
haul_lon = haul_lon + 360
# Get latitude
haul_lat = row['lat']
if os.path.exists(mean_daily_zplk_total_loc):
  # Get the grid coordinates
  i, j = pyroms.utility.get_ij(haul_lon, haul_lat, nwa_grd)
surrounding_indices = [(j + 1, i), (j + 1, i + 1), (j, i + 1), (j - 1, i + 1), (j - 1, i), (j - 1, i - 1),
                       (j, i - 1), (j + 1, i - 1)]
# Load the masked array
tot_zplk_array = np.load(mean_daily_zplk_total_loc)
tot_zplk_array = tot_zplk_array.filled(np.nan)
# Get the [O2] value from the array
tot_zplk_value = tot_zplk_array[j, i]
if np.isnan(tot_zplk_value):
  test_array = []
for new_j, new_i in surrounding_indices:
  test_array.append(tot_zplk_array[new_j, new_i])
np_array = np.array(test_array)
tot_zplk_value = np.nanmean(np_array)
return tot_zplk_value
return None


if __name__ == '__main__':
  print('Running the Seasonal total Zooplankton')
daily_index = get_file_index()
catch_hauls_df = pd.read_csv('data/catch_data_hauls_merge_3.csv')
print(catch_hauls_df.head(10))
# Add a day column with default set to 1
catch_hauls_df['day'] = 1
# Create a 'haul_date' column by using the 'year', 'month', and 'day' columns
catch_hauls_df['haul_date'] = pd.to_datetime(catch_hauls_df[['year', 'month', 'day']])
print('How does the haul date column look')
# Print out the relevant columns
print(catch_hauls_df[['haul_date', 'year', 'month', 'day']].head(10))
# The number of hauls
# Filter the data from or after 1980-01-01
mask_post_1980_pre_2011 = (catch_hauls_df['haul_date'] >= '1980-01-01') & (
  catch_hauls_df['haul_date'] < '2010-12-01')
catch_hauls_df = catch_hauls_df[mask_post_1980_pre_2011]
# The number of hauls after timespan filtering
# Filter out the data from New Foundland Hauls
mask_newfoundland = (catch_hauls_df['regionfact'] != 'DFO_Newfoundland')
catch_hauls_df = catch_hauls_df[mask_newfoundland]
# The number of hauls after regional filtering
print("Print out the final dataframe")
# Sort the dataframe by 'haul_date'
catch_hauls_df = catch_hauls_df.sort_values(by='haul_date')
# OK. So this works
# Now on to the fun stuff
catch_hauls_df.reset_index(inplace=True)

# Just for counting
# We'll append the date to the 'date_list'
date_list = []
m = 0

for run_date in catch_hauls_df['haul_date'].unique()[225:]:
  get_zooplankton_class_sum_across_column(run_date)
print('Done for {0}: {1}'.format(m, run_date))
# Append to date_list
date_list.append(run_date)
m = m + 1
print('Done for Total Class Sum across Water Column for Zooplankton')

test_df = catch_hauls_df.copy(deep=True)
# Disable chained assignment warnings. This is such a pain
pd.options.mode.chained_assignment = None
# Apply 'get_o2_mean'
test_df['o2_seasonal'] = test_df.apply(get_o2_mean, axis=1)
# Apply 'get_sm_zplk_mean'
test_df['sm_zplk_seasonal'] = test_df.apply(get_sm_zplk_mean, axis=1)
# Apply 'get_me_zplk_mean'
test_df['me_zplk_seasonal'] = test_df.apply(get_me_zplk_mean, axis=1)
# Apply 'get_lg_zplk_mean'
test_df['lg_zplk_seasonal'] = test_df.apply(get_lg_zplk_mean, axis=1)
# Apply 'get_temp'
test_df['sbt_temp_seasonal'] = test_df.apply(get_temp_mean, axis=1)
# Apply 'get_column_sm_zplk_mean'
test_df['column_sm_zplk_seasonal'] = test_df.apply(get_column_sm_zplk_mean, axis=1)
# Apply 'get_column_me_zplk_mean'
test_df['column_me_zplk_seasonal'] = test_df.apply(get_column_me_zplk_mean, axis=1)
# Apply 'get_column_lg_zplk_mean'
test_df['column_lg_zplk_seasonal'] = test_df.apply(get_column_lg_zplk_mean, axis=1)
# Apply 'get_salinity_mean'
test_df['salinity_seasonal'] = test_df.apply(get_salinity_mean, axis=1)
# Apply 'get_tot_zplk_mean'
test_df['zplk_class_mean_seasonal'] = test_df.apply(get_tot_zplk_mean, axis=1)
# Apply 'get_zplk_class_total_across_column'
test_df['zplk_class_sum_across_column'] = test_df.apply(get_zplk_class_total_across_column, axis=1)

print(test_df[['year', 'month', 'o2_seasonal']])
out_df = test_df[['haulid', 'sppocean', 'year', 'month', 'lat', 'lon',
                  'o2_seasonal', 'sm_zplk_seasonal', 'me_zplk_seasonal', 'lg_zplk_seasonal', 'sbt_temp_seasonal',
                  'column_sm_zplk_seasonal', 'column_me_zplk_seasonal', 'column_lg_zplk_seasonal',
                  'salinity_seasonal', 'zplk_class_mean_seasonal', 'zplk_class_sum_across_column']]
out_df.to_csv('/Users/jeewantha/Code/data/full_haul_data_ver_11.csv')
print('Done yo')
