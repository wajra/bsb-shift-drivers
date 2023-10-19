# Code for Bandara et al. (2023) - The importance of oxygen for explaining rapid shifts in a marine fish
# R code - Model vizualizations - Part 03 - Visualizing the GAM curves for best performing models
# To visualize data from ROMS-COBALT hindcast models
# # Author - Jeewantha Bandara (mailto:jeewantha.bandara@rutgers.edu) 
# Research Group - Pinsky Lab, Rutgers University (https://pinsky.marine.rutgers.edu)
# Following Advanced R style guide - http://adv-r.had.co.nz/Style.html


library(mgcv)
library(tidyverse)

# Load the GAMS
load("roms_tt_split_output/saved_models/jb_CEmods_Nov2017_GMEXdrop_zplk_salinity_dissolved_oxygen_with_only_sbt_2021_11_11_centropristis striata_Atl.RData")


# Read the GAM for presence/absence
mi_model_gam_1 <- mods$mygam1
# Read the GAM for biomass/abundance
mi_model_gam_2 <- mods$mygam2

summary(mi_model_gam_2)


###################### Plotting only the six most significant curves #######

# Biomass model

png(filename="roms_tt_split_output/figures/tosz_biomass.png",
    width=6, height=4, units="in", res=300)
# Setting up a plot of 3x3 grids
par(mfrow=c(2,3))
# First SBT.seasonal
par(mai=c(0.62,0.55,0.1,0.1),las=1)
plot(mi_model_gam_2, select=1, xlab="",
     ylab="Partial effect",
     shade=T, cex.lab=1.2, cex.axis=1.1)
text(x = 0, y = 5, # Coordinates
     label = "(a)")
mtext("Temperature (°C)",side=1,line=2.2,cex=0.8)
# Then Dissolved oxygen
plot(mi_model_gam_2, select=2, xlab="",
     ylab="",shade=T, cex.lab=1.2)
text(x = 3.5e-5, y = 5, # Coordinates
     label = "(b)")
mtext("Dissolved Oxygen (mol/kg)",side=1,line=2.2,cex=0.8)
# Then Zooplankton
plot(mi_model_gam_2, select=3, xlab="",
     ylab="",shade=T, cex.lab=1.2)
text(x = 1e-05, y = 5, # Coordinates
     label = "(c)")
mtext("Zooplankton (mol/kg)",side=1,line=2.2,cex=0.8)
# Then Salinity
plot(mi_model_gam_2, select=4, xlab="",
     ylab="Partial effect",
     shade=T, cex.lab=1.2, cex.axis=1.1)
text(x = 27.5, y = 5, # Coordinates
     label = "(d)")
mtext("Salinity (ppm)",side=1,line=2.2,cex=0.8)
# Then Rugosity
plot(mi_model_gam_2, select=5, xlab="",
     ylab="",
     shade=T, cex.lab=1.2, cex.axis=1.1)
text(x = 0.4, y = 5, # Coordinates
     label = "(e)")
mtext("Rugosity",side=1,line=2.2,cex=0.8)
# Then Grainsize
plot(mi_model_gam_2, select=6, xlab="",
     ylab="",
     shade=T, cex.lab=1.2, cex.axis=1.1)
text(x = -1.5, y = 5, # Coordinates
     label = "(f)")
mtext("Grainsize (Φ)",side=1,line=2.2,cex=0.8)

dev.off()


######################################################################

# Presence/Absence model

png(filename="roms_tt_split_output/figures/tosz_pres_abs_reduced.png",
    width=6, height=4, units="in", res=300)
# Setting up a plot of 3x3 grids
par(mfrow=c(2,3))
# First SBT.seasonal
par(mai=c(0.62,0.55,0.1,0.12),las=1)
# par(mar=c(4,4,2,1)+0.5,las=1)
plot(mi_model_gam_1, select=1, xlab="",
     ylab="Partial effect",
     shade=T, cex.lab=1.2, cex.axis=1.1, ylim=c(-1.75,1.2))#,xaxt = "n")
# axis(1, at = seq(0,24, by = 4),
#     labels = seq(0,24, by = 4))
text(x = 0, y = 1, # Coordinates
     label = "(a)", cex=1.1)
mtext("Temperature (°C)",side=1,line=2.2,cex=0.8)
# Then dissolved oxygen
plot(mi_model_gam_1, select=2, xlab="",
     ylab="",shade=T, cex.lab=1.2, ylim=c(-7,2.1))
text(x = 0.4e-04, y = 1.6, # Coordinates
     label = "(b)")
mtext("Dissolved Oxygen (mol/kg)",side=1,line=2.2,cex=0.8)
# Then Zooplankton
plot(mi_model_gam_1, select=3, xlab="",
     ylab="",shade=T, cex.lab=1.2, ylim=c(-2,2))
text(x = 1e-05, y = 1.8, # Coordinates
     label = "(c)")
mtext("Zooplankton (mol/kg)",side=1,line=2.2,cex=0.8)
# Then Salinity
plot(mi_model_gam_1, select=4, xlab="",
     ylab="Partial effect",
     shade=T, cex.lab=1.2, cex.axis=1.1, ylim=c(-5.5,1))
text(x = 26, y = 0.65, # Coordinates
     label = "(d)")
mtext("Salinity (ppm)",side=1,line=2.2,cex=0.8)
# Rugosity
plot(mi_model_gam_1, select=5, xlab="",
     ylab="",
     shade=T, cex.lab=1.2, cex.axis=1.1, ylim=c(-0.5,1.5))
text(x = 0.4, y = 1.4, # Coordinates
     label = "(e)")
mtext("Rugosity",side=1,line=2.2,cex=0.8)
# Grainsize
plot(mi_model_gam_1, select=6, xlab="",
     ylab="",
     shade=T, cex.lab=1.2, cex.axis=1.1, ylim=c(-25,2))
text(x = -5, y = 0, # Coordinates
     label = "(f)")
mtext("Grainsize (Φ)",side=1,line=2.2,cex=0.8)
dev.off()
