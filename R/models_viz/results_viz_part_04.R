# Code for Bandara et al. (2023) - The importance of oxygen for explaining rapid shifts in a marine fish
# R code - Model vizualizations - Part 04 - Visualizing Prevalence and Prediction anomalies
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
library(DescTools)

world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

theme_set(theme_bw())

ggplot(data = world) +
  geom_sf()



hindcast <- read.csv(file="roms_tt_split_output/model_outputs/zplk_salinity_dissolved_oxygen_with_only_sbt_2021_11_11_full_predictions.csv")

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
bsb_observations_1990 <- bsb_observations[(bsb_observations$year>=1990 & bsb_observations$year<2000),]
bsb_observations_2000 <- bsb_observations[(bsb_observations$year>=2000 & bsb_observations$year<2010),]

#Lat center of biomass
bsb_center_biomass_lat_1980 <- weighted.mean(x=bsb_observations_1980$lat, w=bsb_observations_1980$wtcpue, na.rm=TRUE)
bsb_center_biomass_lat_1990 <- weighted.mean(x=bsb_observations_1990$lat, w=bsb_observations_1990$wtcpue, na.rm=TRUE)
bsb_center_biomass_lat_2000 <- weighted.mean(x=bsb_observations_2000$lat, w=bsb_observations_2000$wtcpue, na.rm=TRUE)

# Lon center of biomass
bsb_center_biomass_lon_1980 <- weighted.mean(x=bsb_observations_1980$lon, w=bsb_observations_1980$wtcpue, na.rm=TRUE)
bsb_center_biomass_lon_1990 <- weighted.mean(x=bsb_observations_1990$lon, w=bsb_observations_1990$wtcpue, na.rm=TRUE)
bsb_center_biomass_lon_2000 <- weighted.mean(x=bsb_observations_2000$lon, w=bsb_observations_2000$wtcpue, na.rm=TRUE)


bsb_99th_perc_1980 <- DescTools::Quantile(x=bsb_observations_1980$lat, weights=bsb_observations_1980$wtcpue, probs=c(0.99), na.rm=TRUE)[["99%"]]
bsb_99th_perc_1990 <- DescTools::Quantile(x=bsb_observations_1990$lat, weights=bsb_observations_1990$wtcpue, probs=c(0.99), na.rm=TRUE)[["99%"]]
bsb_99th_perc_2000 <- DescTools::Quantile(x=bsb_observations_2000$lat, weights=bsb_observations_2000$wtcpue, probs=c(0.99), na.rm=TRUE)[["99%"]]

bsb_max_obs_1980 <- max(bsb_observations_1980$lat, na.rm=TRUE)
bsb_max_obs_1990 <- max(bsb_observations_1990$lat, na.rm=TRUE)
bsb_max_obs_2000 <- max(bsb_observations_2000$lat, na.rm=TRUE)

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

prev_anomalies <- merge_2000s
prev_anomalies$prev <- merge_2000s$prev - merge_1980s$prev


# Setting the scale for plot 1 - values = scales::rescale(c(0,0.5,1.5, max(sum_1980$x)))
# Previously used 'scale_fill_gradient2()' here for coloring the geom_tile

# Prevalence anomalies plot
prev_anomalies_plot <- ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(lon_min, lon_max), ylim = c(lat_min, lat_max), expand = FALSE) +
  geom_tile(data=prev_anomalies, aes(lon_grid025.x, lat_grid025.x, width=0.25, fill=prev)) + 
  scale_fill_gradientn(colors=c("#00876c","#90c0b0","#f9f9f9", "#f0a0a1", "#d43d51")) + 
  labs(fill="Prevalence anomaly") +
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
  annotate(geom = "text", x = lon_min + 3, y = lat_max - 2 , label = "(a)", 
           size = 4, fontface="bold") + xlab("") + ylab("")



hindcast <- read.csv(file="roms_tt_split_output/model_outputs/zplk_salinity_dissolved_oxygen_with_only_sbt_2021_11_11_full_predictions.csv")
# Worst performing model - roms_model_output_ver_1/full_dataset_hindcast.csv
# roms_model_output_ver_1/classic_model_full_hindcast.csv

# 2021-02-28 -> Originally from 1980 to 1990
hindcast_1980 <- hindcast[(hindcast$year>=1980 & hindcast$year<1990),]
hindcast_2000 <- hindcast[(hindcast$year>=2000 & hindcast$year<2010),]

hindcast_1980_lat_center_bio <- weighted.mean(x=hindcast_1980$lat, w=hindcast_1980$preds, na.rm=TRUE)
hindcast_1980_lon_center_bio <- weighted.mean(x=hindcast_1980$lon, w=hindcast_1980$preds, na.rm=TRUE)

hindcast_2000_lat_center_bio <- weighted.mean(x=hindcast_2000$lat, w=hindcast_2000$preds, na.rm=TRUE)
hindcast_2000_lon_center_bio <- weighted.mean(x=hindcast_2000$lon, w=hindcast_2000$preds, na.rm=TRUE)


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

pred_anomalies <- sum_2000
pred_anomalies$x <- sum_2000$x - sum_1980$x


library(scales)
# Predictions anomalies plot
pred_anomalies_plot <- ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(lon_min, lon_max), ylim = c(lat_min, lat_max), expand = FALSE) +
  geom_tile(data=pred_anomalies, aes(lon, lat, width=0.25, fill=x)) + 
  # scale_fill_gradientn(colors=c("#ffffd9", "#edf8b1","#c7e9b4", "#7fcdbb",
  #                              "#41b6c4", "#1d91c0","#225ea8", "#0c2c84")) + 
  scale_fill_gradientn(colors=c("#00876c","#90c0b0","#f9f9f9", "#f0a0a1", "#d43d51"), values=rescale(c(-0.3,-0.15,0,0.15,0.3))) + 
  labs(fill="Probability anomaly") + xlab("Longitude") + ylab("") + 
  annotation_north_arrow(location = 'br', which_north = 'true', 
                         pad_x = unit(0.1, 'in'), pad_y = unit(0.3, 'in'), 
                         style = north_arrow_fancy_orienteering,
                         height=unit(1, "cm"),
                         width=unit(1, "cm")) +
  annotate(geom = "text", x = lon_min + 3, y = lat_max - 2 , label = "(b)", 
           size = 4)



# Anomalies plot
png("roms_tt_split_output/figures/temp_t_o_s_z_2023_10_09_anomalies_plot.png", width=4, height=6, units="in", res=300)
gridExtra::grid.arrange(prev_anomalies_plot, pred_anomalies_plot,
                        nrow=2, ncol=1)
dev.off()

