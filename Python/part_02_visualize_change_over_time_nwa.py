from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import re
import glob
# from pandas import DataFrame
import datetime
# import pandas as pd
import pyroms
# import pyroms_toolbox
import numpy as np
import numpy.ma as ma
import netCDF4
from netCDF4 import Dataset


# Now test with drawing the actual stuff on the map

# Get the longitudes and latitudes
grd = pyroms.grid.get_ROMS_grid('NWA')
lon = grd.hgrid.lon_rho
lat = grd.hgrid.lat_rho

# The reference file
ref_file = '/Volumes/P13/ROMS/NWA/NWA-SZ.HCob10T/1980/NWA-SZ.HCob10T_avg_1980-06-18T01:00:00.nc'

# Now get a reference file to get the mask
ref = pyroms.io.Dataset(ref_file)
ref_temp = ref.variables['temp'][0]
ref_mask = ma.getmask(ref_temp[0])

# Covariates for 1980s
temp_1980s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/1980s/1980-decade-temp.txt'
o2_1980s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/1980s/1980-decade-o2.txt'
salt_1980s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/1980s/1980-decade-salt.txt'
zplk_1980s_f = '/Volumes/P13/workdir/jeewantha/data/decadal_means/annual_means/1980s/1980-decade-zplk.txt'
mi_1980s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/1980s/1980-decade-mi.txt'


# Covariates for 2000s
temp_2000s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/2000s/2000-decade-temp.txt'
o2_2000s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/2000s/2000-decade-o2.txt'
salt_2000s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/2000s/2000-decade-salt.txt'
zplk_2000s_f = '/Volumes/P13/workdir/jeewantha/data/decadal_means/annual_means/2000s/2000-decade-zplk.txt'
mi_2000s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/2000s/2000-decade-mi.txt'

# Read them into arrays
temp_1980s = np.loadtxt(temp_1980s_f)
o2_1980s = np.loadtxt(o2_1980s_f)
salt_1980s = np.loadtxt(salt_1980s_f)
zplk_1980s = np.loadtxt(zplk_1980s_f)
mi_1980s = np.loadtxt(mi_1980s_f)

temp_2000s = np.loadtxt(temp_2000s_f)
o2_2000s = np.loadtxt(o2_2000s_f)
salt_2000s = np.loadtxt(salt_2000s_f)
zplk_2000s = np.loadtxt(zplk_2000s_f)
mi_2000s = np.loadtxt(mi_2000s_f)

print('Done')

# Now to reset some values
# If a value is below zero for O2 and Metabolic Index, set it to 0
low_o2s_1980s = o2_1980s < 0
o2_1980s[low_o2s_1980s] = 0
low_o2s_2000s = o2_2000s < 0
o2_2000s[low_o2s_2000s] = 0

# Do the same for metabolic index
low_mi_1980s = mi_1980s < 0
mi_1980s[low_mi_1980s] = 0
low_mi_2000s = mi_2000s < 0
mi_2000s[low_mi_2000s] = 0

# Convert O2 from mol/kg to mg/dl
o2_1980s = o2_1980s*32*1000/0.9766
o2_2000s = o2_2000s*32*1000/0.9766

# Get their differences
temp_diff = temp_2000s - temp_1980s
o2_diff = o2_2000s - o2_1980s
salt_diff = salt_2000s - salt_1980s
zplk_diff = zplk_2000s - zplk_1980s
mi_diff = mi_2000s - mi_1980s

high_salt_diff = salt_diff > 35
salt_diff[high_salt_diff] = 0

print('Values for salinity above 35: {0}'.format((salt_diff > 35).sum()))

# Now get a reference file to get the mask
ref = pyroms.io.Dataset(ref_file)
ref_temp = ref.variables['temp'][0]
ref_mask = ma.getmask(ref_temp[0])

# Get the masked version of the numpy arrays
temp_diff_ma = ma.array(temp_diff, mask=ref_mask)
o2_diff_ma = ma.array(o2_diff, mask=ref_mask)
salt_diff_ma = ma.array(salt_diff, mask=ref_mask)
zplk_diff_ma = ma.array(zplk_diff, mask=ref_mask)
mi_diff_ma = ma.array(mi_diff, mask=ref_mask)

print(type(temp_diff_ma))

# Get the minima and maxima of the zplk arrays
print('For the 1980s')
print(zplk_1980s.min())
print(zplk_1980s.max())
print('For the difference')
print(zplk_diff.min())
print(zplk_diff.max())


# Reset the longitudes
lon = lon - 360

text_x = -100
text_y = 50


data_to_be_plotted = [[temp_1980s, temp_diff, o2_1980s, o2_diff],
                      [salt_1980s, salt_diff, zplk_1980s, zplk_diff],
                      [mi_1980s, mi_diff]]

map_labels = [['(a)', '(b)', '(c)', '(d)'],
              ['(e)', '(f)', '(g)', '(h)'],
              ['(i)', '(j)']]

cmaps = [['Spectral', 'coolwarm', 'Spectral', 'coolwarm'],
         ['Spectral', 'coolwarm', 'Spectral', 'coolwarm'],
         ['Spectral', 'coolwarm']]

colormap_units = [[r'Temperature ($^\circ$C)', r'$\Delta$ Temperature ($^\circ$C)', 'Dissolved Oxygen (mg/dl)', r'$\Delta$ Dissolved Oxygen (mg/dl)'],
                  ['Salinity (ppm)', r'$\Delta$ Salinity (ppm)', r'Zooplankton (x $10^{-5}$ mol/kg)', r'$\Delta$ Zooplankton (x $10^{-6}$ mol/kg)'],
                  ['MI', r'$\Delta$ MI']]


label_x = -82
label_y = 47

rows = 3
cols = 4

# Set the figure size - Previously set at 3,8
# Previously set (2022-07-28) at 10,8
plt.rcParams["figure.figsize"] = [10, 8]

# Usually set as (rows, cols)
fig, ax = plt.subplots(rows, cols)
# fig.subplots_adjust(wspace=0, hspace=0)

for r in range(rows):
    for c in range(cols):
        if r == 2 and c > 1:
            ax[r, c].axis('off')
            continue
        ax1 = ax[r][c]
        a = Basemap(projection='merc', llcrnrlat=28, urcrnrlat=50, \
                    llcrnrlon=-83, urcrnrlon=-56, resolution='l', ax=ax1)
        a.drawmapboundary()
        colors_a = None
        colorb = None
        if map_labels[r][c] == '(f)':
            colors_a = a.pcolor(lon, lat, data_to_be_plotted[r][c], cmap=cmaps[r][c], vmin=-1, vmax=1, latlon=True)
        elif map_labels[r][c] == '(h)':
            colors_a = a.pcolor(lon, lat, data_to_be_plotted[r][c], cmap=cmaps[r][c], vmin=-4e-06, vmax=4e-06, latlon=True)
        else:
            colors_a = a.pcolor(lon, lat, data_to_be_plotted[r][c], cmap=cmaps[r][c], latlon=True)
        # If else starts here
        if map_labels[r][c] == '(d)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[-1, -0.5, 0, 0.5, 1])
            colorb.ax.set_xticklabels(['-1', '-0.5', '0', '0.5', '1'])
        elif map_labels[r][c] == '(e)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[0, 10, 20, 30, 40])
            colorb.ax.set_xticklabels(['0', '10', '20', '30', '40'])
        elif map_labels[r][c] == '(f)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[-1, -0.5, 0, 0.5, 1])
            colorb.ax.set_xticklabels(['-1', '-0.5', '0', '0.5', '1'])
        elif map_labels[r][c] == '(j)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[-0.8, -0.4, 0, 0.4, 0.8])
            colorb.ax.set_xticklabels(['-0.8', '-0.4', '0', '0.4', '0.8'])
        elif map_labels[r][c] == '(g)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[0, 0.0000325, 0.000065, 0.0000975, 0.00013])
            colorb.ax.set_xticklabels(['0', '3.25', '6.5', '9.75', '13'])
            # colorb.formatter.set_powerlimits((0, 0))
        elif map_labels[r][c] == '(h)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[-4e-06, -2e-06, 0, 2e-06, 4e-06])
            colorb.ax.set_xticklabels(['-4', '-2', '0', '2', '4'])
            # colorb = a.colorbar(colors_a, location='bottom', ticks=[-8e-06, -2.75e-06, 2.5e-06, 7.75e-06, 13e-06])
            # colorb.ax.set_xticklabels(['-8', '-2.75', '2.5', '7.75', '13'])
            # colorb.formatter.set_powerlimits((0, 0))
        else:
            colorb = a.colorbar(colors_a, location='bottom')
        # Fill in the continents
        a.drawcoastlines()
        a.fillcontinents(color='#e5e5e5')
        # Else ends before this
        # Set label size at 5
        colorb.ax.tick_params(labelsize=10)
        # Set x label at 8
        colorb.set_label(colormap_units[r][c], fontsize=12)

        # if map_labels[r][c] in ['(c)', '(d)']:
        #    colorb.ax.set_xticklabels(["{:.0e}".format(i) for i in colorb.get_ticks()])
        x, y = a(label_x, label_y)
        # Set map label at 8
        ax1.text(x, y, map_labels[r][c], fontsize=10)


plt.tight_layout()
fig.savefig("/Users/jeewantha/Code/bsb_modeling/plots/covariates_with_subplots.png", dpi=300)
