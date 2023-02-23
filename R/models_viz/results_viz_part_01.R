# Code for Bandara et al. (2023) - The importance of oxygen for explaining rapid shifts in a marine fish
# R code - Model vizualizations - Part 01 - Visualizing prevalence and predictions through time
# To visualize data from ROMS-COBALT hindcast models
# # Author - Jeewantha Bandara (mailto:jeewantha.bandara@rutgers.edu) 
# Research Group - Pinsky Lab, Rutgers University (https://pinsky.marine.rutgers.edu)
# Following Advanced R style guide - http://adv-r.had.co.nz/Style.html


library("ggplot2")
library("sf")
library("rnaturalearth")
library("rnaturalearthdata")
library(tidyverse)
library(ggspatial)
library(cowplot)

# Things to be done
# 1. Read the predictions from a well performing model
# 2. Plot the actual abundance data vs. predicted abundance
# 3. Set the minima and maxima for xlim and ylim using the dataset itself
# 4. Insert the titles, north arrow and scales

world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

theme_set(theme_bw())

ggplot(data = world) +
  geom_sf()



hindcast <- read.csv(file="roms_tt_split_output/model_outputs/zplk_salinity_dissolved_oxygen_with_only_sbt_2021_11_11_full_predictions.csv")
# Worst performing model - roms_model_output_ver_1/full_dataset_hindcast.csv
# roms_model_output_ver_1/classic_model_full_hindcast.csv


hindcast$lat_grid025 <- floor(hindcast$lat*4)/4 + 0.125
hindcast$lon_grid025 <- floor(hindcast$lon*4)/4 + 0.125

hindcast$latlon <- paste(hindcast$lon_grid025,"-", hindcast$lat_grid025)

# 2021-02-28 - 
hindcast_1980 <- hindcast[(hindcast$year>=1980 & hindcast$year<1990),]
hindcast_2000 <- hindcast[(hindcast$year>=2000 & hindcast$year<2010),]


# Group and count
group_1980 <- hindcast_1980 %>% dplyr::count(lon_grid025, lat_grid025)
group_2000 <- hindcast_2000 %>% dplyr::count(lon_grid025, lat_grid025)

# Now take just the black sea bass observations
bsb_observations <- hindcast %>% dplyr::filter(sppocean=="centropristis striata_Atl")
bsb_observations_1980 <- bsb_observations[(bsb_observations$year>=1980 & bsb_observations$year<1990),]
bsb_observations_2000 <- bsb_observations[(bsb_observations$year>=2000 & bsb_observations$year<2010),]

# Now group the black sea bass observations by their latlon
bsb_obs_group_1980 <- bsb_observations_1980 %>% dplyr::count(lon_grid025, lat_grid025)
bsb_obs_group_2000 <- bsb_observations_2000 %>% dplyr::count(lon_grid025, lat_grid025)

# Create a new column using paste combining lat and lon
group_1980$latlon <- paste(group_1980$lon_grid025,"-", group_1980$lat_grid025)
group_2000$latlon <- paste(group_2000$lon_grid025,"-", group_2000$lat_grid025)
bsb_obs_group_1980$latlon <- paste(bsb_obs_group_1980$lon_grid025, "-", bsb_obs_group_1980$lat_grid025)
bsb_obs_group_2000$latlon <- paste(bsb_obs_group_2000$lon_grid025, "-", bsb_obs_group_2000$lat_grid025)



# Now we will rename some of the columns in all four dataframes of interest
# 1. group_1980
# 2. group_2000
# 3. bsb_obs_group_1980
# 4. bsb_obs_group_2000

group_1980 <- group_1980 %>% dplyr::rename(total_obs=n)
group_2000 <- group_2000 %>% dplyr::rename(total_obs=n)
bsb_obs_group_1980 <- bsb_obs_group_1980 %>% dplyr::rename(bsb_obs=n)
bsb_obs_group_2000 <- bsb_obs_group_2000 %>% dplyr::rename(bsb_obs=n)

# Merge for 1980s
merge_1980s <- merge(group_1980, bsb_obs_group_1980, by='latlon', all.x=TRUE)
# Merge for 2000s
merge_2000s <- merge(group_2000, bsb_obs_group_2000, by='latlon', all.x=TRUE)
# Replace NA's in the bsb_obs column by 0
merge_1980s <- merge_1980s %>% dplyr::mutate(bsb_obs = replace_na(bsb_obs, 0))
merge_2000s <- merge_2000s %>% dplyr::mutate(bsb_obs = replace_na(bsb_obs, 0))
# Now create a new column for the actual prevalance
merge_1980s <- merge_1980s %>% dplyr::mutate(prev=bsb_obs/total_obs)
merge_2000s <- merge_2000s %>% dplyr::mutate(prev=bsb_obs/total_obs)


# Set the plot/map boundaries

# Plotting on the map itself
# Here we need to get the minimum and maximum for latitude and longitude
lat_max <- max(hindcast_2000$lat, na.rm=TRUE) + 1
lat_min <- min(hindcast_2000$lat, na.rm=TRUE) - 1
lon_max <- max(hindcast_2000$lon, na.rm=TRUE) + 1
lon_min <- min(hindcast_2000$lon, na.rm=TRUE) - 1


# Now we plot only the common grids
unique_1980s <- unique(merge_1980s$latlon)
unique_2000s <- unique(merge_2000s$latlon)

intersect_two <- intersect(unique_1980s, unique_2000s)

merge_1980s <- merge_1980s[(merge_1980s$latlon %in% intersect_two), ]
merge_2000s <- merge_2000s[(merge_2000s$latlon %in% intersect_two), ]


prev_1980s_plot <- ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(lon_min, lon_max), ylim = c(lat_min, lat_max), expand = FALSE) +
  labs(fill="Prevalence") + ylab("Latitude") + xlab("") + 
  geom_tile(data=merge_1980s, aes(lon_grid025.x, lat_grid025.x, width = 0.25, fill = prev)) +  
  annotation_north_arrow(location = 'br', which_north = 'true', 
                         pad_x = unit(0.1, 'in'), pad_y = unit(0.3, 'in'), 
                         style = north_arrow_fancy_orienteering,
                         height=unit(1, "cm"),
                         width=unit(1, "cm")) +
  scale_fill_gradientn(colors=c("#ffffcc","#a1dab4","#41b6c4", "#225ea8")) +
  annotate(geom = "text", x = lon_min + 3, y = lat_max - 2, label = "(a)", 
           size = 4)+ theme(legend.position="none")




# Setting the scale for plot 1 - values = scales::rescale(c(0,0.5,1.5, max(sum_1980$x)))
# Previously used 'scale_fill_gradient2()' here for coloring the geom_tile

prev_2000s_plot <- ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(lon_min, lon_max), ylim = c(lat_min, lat_max), expand = FALSE) +
  geom_tile(data=merge_2000s, aes(lon_grid025.x, lat_grid025.x, width=0.25, fill=prev)) + 
  scale_fill_gradientn(colors=c("#ffffcc","#a1dab4","#41b6c4", "#225ea8")) + 
  labs(fill="Prevalence") +
  annotation_north_arrow(location = 'br', which_north = 'true', 
                         pad_x = unit(0.1, 'in'), pad_y = unit(0.3, 'in'), 
                         style = north_arrow_fancy_orienteering,
                         height=unit(1, "cm"),
                         width=unit(1, "cm")) +
  annotation_north_arrow(location = 'br', which_north = 'true', 
                         pad_x = unit(0.1, 'in'), pad_y = unit(0.3, 'in'), 
                         style = north_arrow_fancy_orienteering,
                         height=unit(1, "cm"),
                         width=unit(1, "cm")) +
  annotate(geom = "text", x = lon_min + 3, y = lat_max - 2 , label = "(b)", 
           size = 4) + xlab("") + ylab("")

# scale_fill_gradient(low = "#56B1F7", high = "#132B43"s)

# Fix the color scaling
# low = "blue", mid = "green", high = "red"
# png("roms_tt_split_output/figures/bsb_prevalance_1990_2010_version_testing.png", width=6, height=6, units="in", res=300)
# gridExtra::grid.arrange(plot_1, plot_2, nrow=2)
# dev.off()



############################################################################################

# Copying this section from vis_interacton_part_xviii_predictions_on_two_time_scales_common_grids


# Things to be done
# 1. Read the predictions from a well performing model
# 2. Plot the actual abundance data vs. predicted abundance
# 3. Set the minima and maxima for xlim and ylim using the dataset itself
# 4. Insert the titles, north arrow and scales

hindcast <- read.csv(file="roms_tt_split_output/model_outputs/mi_salinity_zooplankton_2021_12_02_full_predictions.csv")
# Worst performing model - roms_model_output_ver_1/full_dataset_hindcast.csv
# roms_model_output_ver_1/classic_model_full_hindcast.csv

# 2021-02-28 -> Originally from 1980 to 1990
hindcast_1980 <- hindcast[(hindcast$year>=1980 & hindcast$year<1990),]
hindcast_2000 <- hindcast[(hindcast$year>=2000 & hindcast$year<2010),]

# Here I need to basically write a couple of 'if' statements for the max and min
# values
plot_min <- NA
plot_max <- NA

# Get the max and min values for logwtcpue and log(preds)
logwtcpue_max <- max(hindcast_1980$logwtcpue, na.rm=TRUE)
log_preds_max <- max(log(hindcast_1980$preds), na.rm=TRUE)
logwtcpue_min <- min(hindcast_1980$logwtcpue, na.rm=TRUE)
log_preds_min <- min(log(hindcast_1980$preds), na.rm=TRUE)

# make plot_min == log_preds_min
# Then compare using 'if'
plot_min = log_preds_min
if (logwtcpue_min < plot_min){
  plot_min=logwtcpue_min
}
# Then max
plot_max = log_preds_max
if (logwtcpue_min < plot_min){
  plot_max=logwtcpue_max
}

# ggplot(hindcast_1980, aes(longrid, latgrid, width = 0.25, fill = logwtcpue)) + 
#  geom_tile() + scale_fill_gradient(limits = range(plot_min, plot_max))



# Plotting on the map itself
# Here we need to get the minimum and maximum for latitude and longitude
lat_max <- max(hindcast_1980$lat, na.rm=TRUE) + 1
lat_min <- min(hindcast_1980$lat, na.rm=TRUE) - 1
lon_max <- max(hindcast_1980$lon, na.rm=TRUE) + 1
lon_min <- min(hindcast_1980$lon, na.rm=TRUE) - 1

hindcast_1980$lat_grid025 <- floor(hindcast_1980$lat*4)/4 + 0.125
hindcast_1980$lon_grid025 <- floor(hindcast_1980$lon*4)/4 + 0.125

hindcast_2000$lat_grid025 <- floor(hindcast_2000$lat*4)/4 + 0.125
hindcast_2000$lon_grid025 <- floor(hindcast_2000$lon*4)/4 + 0.125


sum_1980 <- aggregate(hindcast_1980$preds1, 
                      by = list(lat = hindcast_1980$lat_grid025,
                                lon = hindcast_1980$lon_grid025),
                      FUN = mean, na.rm= TRUE)

sum_2000 <- aggregate(hindcast_2000$preds1, 
                      by = list(lat = hindcast_2000$lat_grid025,
                                lon = hindcast_2000$lon_grid025),
                      FUN = mean, na.rm= TRUE)

# Now we'll filter out only the common grids
# Now we should get the unique combinations between longrid and latgrid

# Make a new column joining the latgrid and longrid
sum_1980$lonandlat <- paste(sum_1980$lon, "-", sum_1980$lat)
sum_2000$lonandlat <- paste(sum_2000$lon, "-", sum_2000$lat)

unique_1980s <- unique(sum_1980$lonandlat)
unique_2000s <- unique(sum_2000$lonandlat)

intersect_two <- intersect(unique_1980s, unique_2000s)

sum_1980 <- sum_1980[(sum_1980$lonandlat %in% intersect_two), ]
sum_2000 <- sum_2000[(sum_2000$lonandlat %in% intersect_two), ]


# Note to self - 2021-02-17
# We kept scale_fill_gradient2() just as it is before
# Now we are trying to actually implement actual colors
pres_abs_1980_plot <- ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(lon_min, lon_max), ylim = c(lat_min, lat_max), expand = FALSE) +
  labs(fill="Probability") + ylab("Latitude") + xlab("Longitude") + 
  annotation_north_arrow(location = 'br', which_north = 'true', 
                         pad_x = unit(0.1, 'in'), pad_y = unit(0.3, 'in'), 
                         style = north_arrow_fancy_orienteering,
                         height=unit(1, "cm"),
                         width=unit(1, "cm")) +
  geom_tile(data=sum_1980, aes(lon, lat, width = 0.25, fill = x)) +
  #  scale_fill_gradient2(low = "#e7e1ef",
  #                       mid = "#c994c7",
  #                       high = "#dd1c77",
  #                       midpoint = 0.5)
  scale_fill_gradientn(colors=c("#ffffcc","#a1dab4","#41b6c4", "#225ea8")) +
  annotate(geom = "text", x = lon_min + 3, y = lat_max - 2 , label = "(c)", 
           size = 4) + theme(legend.position="none")

# https://stackoverflow.com/questions/41985921/specify-manual-values-for-scale-gradientn-with-transformed-color-fill-variable

pres_abs_2000_plot <- ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(lon_min, lon_max), ylim = c(lat_min, lat_max), expand = FALSE) +
  geom_tile(data=sum_2000, aes(lon, lat, width=0.25, fill=x)) + 
  # scale_fill_gradientn(colors=c("#ffffd9", "#edf8b1","#c7e9b4", "#7fcdbb",
  #                              "#41b6c4", "#1d91c0","#225ea8", "#0c2c84")) + 
  scale_fill_gradientn(colors=c("#ffffcc","#a1dab4","#41b6c4", "#225ea8")) + 
  labs(fill="Probability") + xlab("Longitude") + ylab("") + 
  annotation_north_arrow(location = 'br', which_north = 'true', 
                         pad_x = unit(0.1, 'in'), pad_y = unit(0.3, 'in'), 
                         style = north_arrow_fancy_orienteering,
                         height=unit(1, "cm"),
                         width=unit(1, "cm")) +
  annotate(geom = "text", x = lon_min + 3, y = lat_max - 2 , label = "(d)", 
           size = 4)

# low = "blue", mid = "green", high = "red"
# png("roms_tt_split_output/figures/mi_zplk_model_hindcast_predictions_pres_abs.png", width=6, height=6, units="in", res=300)
# gridExtra::grid.arrange(test_plot, plot_2, nrow=2)
# dev.off()

# Now create a 4 subplot figure

png("roms_tt_split_output/figures/temp_t_o_s_z_2022_06_17_hindcast_predictions_vs_prevalence_temp.png", width=8, height=6, units="in", res=300)
gridExtra::grid.arrange(prev_1980s_plot, prev_2000s_plot, pres_abs_1980_plot, 
                        pres_abs_2000_plot,
                        nrow=2, ncol=2)
dev.off()



# Trying to make a map inset

boxes<-data.frame(maxlat = lat_max,minlat = lat_min,maxlong = lon_max,minlong = lon_min, id="1")
boxes<-transform(boxes, laby=(maxlat +minlat )/2, labx=(maxlong+minlong )/2)

# -171.791110603, 18.91619, -66.96466, 71.3577635769
usa_lon_min <- -120
usa_lon_max <- -50
usa_lat_min <- 18.91619
usa_lat_max <- 71.3577635769

usa_inset <- ggplot(data = world) +
  geom_sf() + coord_sf(xlim = c(usa_lon_min, usa_lon_max), ylim = c(usa_lat_min, usa_lat_max), expand = FALSE) +
  geom_rect(data=boxes, aes(xmin=minlong , xmax=maxlong, ymin=minlat, ymax=maxlat ), color="red", fill="transparent")


gg_inset_map1 = ggdraw() +
  draw_plot(pres_abs_2000_plot) +
  draw_plot(usa_inset, x = 0.05, y = 0.65, width = 0.3, height = 0.3)

gg_inset_map1
