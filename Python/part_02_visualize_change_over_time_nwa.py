from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import re
import glob
from pandas import DataFrame
import datetime
import pandas as pd
import pyroms
import pyroms_toolbox
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

# Temperature
# temp_1980s_f = '/Volumes/P4/workdir/jeewantha/data/decadal_means/annual_means/1980s/1980-decade-temp.txt'


# Now get a reference file to get the mask
ref = pyroms.io.Dataset(ref_file)
ref_temp = ref.variables['temp'][0]
ref_mask = ma.getmask(ref_temp[0])

# temp_1980s = np.loadtxt(temp_1980s_f)

# Get the masked version of the numpy arrays
# temp_1980s_ma = ma.array(temp_1980s, mask=ref_mask)

# Reset the longitudes
# lon = lon - 360

# Mercator Projection
# llcrnrlat,llcrnrlon,urcrnrlat,urcrnrlon
# are the lat/lon values of the lower left and upper right corners
# of the map.
# lat_ts is the latitude of true scale.
# resolution = 'c' means use crude resolution coastlines.

# 2022-06-20
# This is copied from `plot_covariates_through_time.py`

# Covariates for 1980s
temp_1980s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/1980s/1980-decade-temp.txt'
o2_1980s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/1980s/1980-decade-o2.txt'
salt_1980s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/1980s/1980-decade-salt.txt'
zplk_1980s_f = '/Volumes/P13/workdir/jeewantha/data/decadal_means/annual_means/1980s/1980-decade-zplk.txt'
mi_1980s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/1980s/mi_1980s.txt'


# Covariates for 2000s
temp_2000s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/2000s/2000-decade-temp.txt'
o2_2000s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/2000s/2000-decade-o2.txt'
salt_2000s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/2000s/2000-decade-salt.txt'
zplk_2000s_f = '/Volumes/P13/workdir/jeewantha/data/decadal_means/annual_means/2000s/2000-decade-zplk.txt'
mi_2000s_f = '/Users/jeewantha/Code/bsb_modeling/data/decadal_means/annual_means/2000s/mi_2000s.txt'

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
"""
# Draw the maps on the axes
fig, ax = plt.subplots(4, 2)
ax1 = ax[0, 0]
a = Basemap(projection='merc', llcrnrlat=28, urcrnrlat=50,\
            llcrnrlon=-83, urcrnrlon=-56, resolution='l', ax=ax1)
# lat_ts=20
a.drawcoastlines()
a.fillcontinents(color='#feb24c')
# draw parallels and meridians.
a.drawmapboundary()
colors_a = a.pcolor(lon, lat, temp_diff, cmap='coolwarm', latlon=True)
a.colorbar(colors_a, location='right', label='Celsius')

ax2 = ax[0, 1]
b = Basemap(projection='merc', llcrnrlat=28, urcrnrlat=50,\
            llcrnrlon=-83, urcrnrlon=-56, resolution='l', ax=ax2)
# lat_ts=20
b.drawcoastlines()
b.fillcontinents(color='#feb24c')
# draw parallels and meridians.
b.drawmapboundary()
colors_b = b.pcolor(lon, lat, o2_diff, cmap='BrBG', latlon=True)
b.colorbar(colors_b, location='right')

ax3 = ax[1, 0]
c = Basemap(projection='merc', llcrnrlat=28, urcrnrlat=50,\
            llcrnrlon=-83, urcrnrlon=-56, resolution='l', ax=ax3)
# lat_ts=20
c.drawcoastlines()
c.fillcontinents(color='#feb24c')
# draw parallels and meridians.
c.drawmapboundary()
colors_c = c.pcolor(lon, lat, salt_diff, cmap='PiYG', latlon=True)
c.colorbar(colors_c, location='right')

ax4 = ax[1, 1]
d = Basemap(projection='merc', llcrnrlat=28, urcrnrlat=50,\
            llcrnrlon=-83, urcrnrlon=-56, resolution='l', ax=ax4)
# lat_ts=20
d.drawcoastlines()
d.fillcontinents(color='#feb24c')
# draw parallels and meridians.
d.drawmapboundary()
colors_d = d.pcolor(lon, lat, mi_diff, cmap='Spectral', latlon=True)
d.colorbar(colors_d, location='right')

fig.savefig("/Users/jeewantha/Code/bsb_modeling/plots/covariates_with_subplots_2.png", dpi=300, orientation='portrait')

print('Done with drawing the map')
"""

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
        # lat_ts=20
        a.drawcoastlines()
        a.fillcontinents(color='#e5e5e5')
        # Original color - #feb24c#e5e5e5
        # draw parallels and meridians.
        a.drawmapboundary()
        colors_a = None
        colorb = None
        if map_labels[r][c] == '(f)':
            colors_a = a.pcolor(lon, lat, data_to_be_plotted[r][c], cmap=cmaps[r][c], vmin=-2.5, vmax=2.5, latlon=True)
        elif map_labels[r][c] == '(h)':
            colors_a = a.pcolor(lon, lat, data_to_be_plotted[r][c], cmap=cmaps[r][c], vmin=-8.5e-06, vmax=8.5e-06, latlon=True)
        else:
            colors_a = a.pcolor(lon, lat, data_to_be_plotted[r][c], cmap=cmaps[r][c], latlon=True)
        # If else starts here
        if map_labels[r][c] == '(d)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[-1.5, -0.75, 0, 0.75, 1.5])
            colorb.ax.set_xticklabels(['-1.5', '-0.75', '0', '0.75', '1.5'])
        elif map_labels[r][c] == '(e)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[0, 10, 20, 30, 40])
            colorb.ax.set_xticklabels(['0', '10', '20', '30', '40'])
        elif map_labels[r][c] == '(f)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[-2, -1, 0, 1, 2])
            colorb.ax.set_xticklabels(['-2', '-1', '0', '1', '2'])
        elif map_labels[r][c] == '(j)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[-0.8, -0.4, 0, 0.4, 0.8])
            colorb.ax.set_xticklabels(['-0.8', '-0.4', '0', '0.4', '0.8'])
        elif map_labels[r][c] == '(g)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[0, 0.0000325, 0.000065, 0.0000975, 0.00013])
            colorb.ax.set_xticklabels(['0', '3.25', '6.5', '9.75', '13'])
            colorb.formatter.set_powerlimits((0, 0))
        elif map_labels[r][c] == '(h)':
            colorb = a.colorbar(colors_a, location='bottom', ticks=[-8e-06, -4e-06, 0, 4e-06, 8e-06])
            colorb.ax.set_xticklabels(['-8', '-4', '0', '4', '8'])
            # colorb = a.colorbar(colors_a, location='bottom', ticks=[-8e-06, -2.75e-06, 2.5e-06, 7.75e-06, 13e-06])
            # colorb.ax.set_xticklabels(['-8', '-2.75', '2.5', '7.75', '13'])
            colorb.formatter.set_powerlimits((0, 0))
        else:
            colorb = a.colorbar(colors_a, location='bottom')
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
# plt.subplots_adjust(pad=-5.0)
fig.savefig("/Users/jeewantha/Code/bsb_modeling/plots/covariates_with_subplots.png", dpi=300)
