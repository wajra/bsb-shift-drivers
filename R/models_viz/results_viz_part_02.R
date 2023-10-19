# Code for Bandara et al. (2023) - The importance of oxygen for explaining rapid shifts in a marine fish
# R code - Model vizualizations - Part 02 - Visualizing the temperature and oxygen interaction
# To visualize data from ROMS-COBALT hindcast models
# # Author - Jeewantha Bandara (mailto:jeewantha.bandara@rutgers.edu) 
# Research Group - Pinsky Lab, Rutgers University (https://pinsky.marine.rutgers.edu)
# Following Advanced R style guide - http://adv-r.had.co.nz/Style.html

library(tidyverse)

library(mgcv)
library(dismo)
library(beepr)
library(respirometry)
library(gridExtra)


# This is the dataset named 'dat'
load('data/master_hauls_March7_2017.RData') # import master hauls file
# This is the dataset named 'hauls'
load('data/dat_selectedspp_Feb_1_2017.Rdata')# load species catch data

filtered_hauls_roms <- read.csv('data/transformed_haul_data_NWA-SZ_HCob10T_including_column_ver_5.csv',stringsAsFactors = FALSE)
# Drop some of the unncessary columns
filtered_hauls_roms <- subset(filtered_hauls_roms, select=-c(sppocean,year,month,lon,lat))
# Now we load the 
hauls <- merge(filtered_hauls_roms,hauls,by='haulid',all.x=T,sort=F)




################## 2021-04-07 - Removing the VIMS_NEAMAP and GOMEX ###########
# Print out the unique regions
# print(unique(hauls$region))
hauls <- hauls[!(hauls$region %in% c("VIMS_NEAMAP","SEFSC_GOMex")),]




# Changed the runname for my own diagnostics
runname <- "metabolic_index_zooplankton_model_tt_split_2021_04_11"

# Before all other data clean ups we can actually filter out only black sea bass columns
# This will lessen the load on my poor laptop

# We'll use a function for this
bsb_filter <- function(x) startsWith(x, "centropristis striata")

# Then using 'sapply' we'll apply the function to 'sppocean' column in dat
dat <- dat[sapply(dat$sppocean,bsb_filter),]

# Here they simply say that all other rows apart from those having a 'wtcpue' value of 0 and 'region'
# value of 'DFO_SoGulf' are actual absences therefore can be removed from the dataframe
dat <- dat[!(dat$wtcpue == 0 & dat$region == 'DFO_SoGulf'),] # the zeros in SoGulf are actual zeros (ie not just a scale issue) and thus are true absences
# And then the remaining zero values of 'wtcpue' are set to 0.0002 because they do have a value. They are not absences.
# They are barely there
dat$wtcpue[dat$wtcpue == 0] <- 0.0002 # 'zeros' in dat are now species too light to register on scales_here a value below the lowest non-zero value is assigned_for transforming data
# Then we check for the species ('sppocean' column) named 'calappa sulcata in Atlantic Ocean' and
# check if there 'wtcpue' is missing. If so we set it to 0.13.
dat$wtcpue[dat$sppocean=="calappa sulcata_Atl" & is.na(dat$wtcpue)] <- 0.13 # the median weight of this species when observed
# Then a new column is created named 'logwtcpue' and log values of 'wtcpue' is set to it
dat$logwtcpue <- log(dat$wtcpue)


#### After the log(abundance) we'll add the metabolic index
# First convert mol/kg to to mg/L of seawater
# Then convert that to partial pressure (Units: kPa)
# Then calculate the metabolic index
hauls$o2_seasonal_mgl <- hauls$o2_seasonal*32*1000/0.9766
hauls$o2_seasonal_kPa <- respirometry::conv_o2(o2=hauls$o2_seasonal_mgl, 
                                               from="mg_per_l", 
                                               to="kPa", temp=hauls$SBT.seasonal, 
                                               sal=hauls$salinity_seasonal, atm_pres=1013.25)

# Now do the computations for 'Metabolic index' : phi
# Metabolic index (phi) was defined by Deutch et al. (2015) as follows
# phi = Ao * Bn * Po2 / exp(-Eo/kB * T)
# Where
# phi -> Metabolic index [unitless]
# Ao -> 0.00040728 [unitless]
# Bn -> 1 [unitless]
# Po2 -> [units: kPa]
# Eo -> 0.27 [unitless]
# kB -> Boltzmann's constant: 8.617E-05 [units: eVK^-1]
# T -> [units: Kelvin]
# Species specific values for these constants were gathered from Saba et al, and
# Slesinger et al.
Ao <- 0.00040728
Bn <- 1E-02
Eo <- 0.27
kB <- 8.617E-05

hauls$mi <- (Ao * hauls$o2_seasonal_kPa *Bn)/exp(-Eo/(kB*(hauls$SBT.seasonal+273.15)))

# drop dubious GMex observations of temperate species or species that have a Gulf of Mexico endemic congener that closely resembles the Atlantic coast species
# So what we have here is a list or vector of a set of species that are in both Gulf of Mexico and Atlantic Ocean
drops <- c('alosa pseudoharengus_Gmex', 'brevoortia tyrannus_Gmex', 'clupea harengus_Gmex', 'dipturus laevis_Gmex', 'paralichthys dentatus_Gmex',
           'hippoglossoides platessoides_Gmex', 'pseudopleuronectes americanus_Gmex', 'scomber scombrus_Gmex', 'cryptacanthodes maculatus_Gmex',
           'echinarachnius parma_Gmex', 'illex illecebrosus_Gmex', 'melanostigma atlanticum_Gmex', 'menidia menidia_Gmex', 'ovalipes ocellatus_Gmex','placopecten magellanicus_Gmex')
# 'gsub' is a function that simply substitutes a substring for another substring in a string or vector
# USAGE
# gsub(pattern, replacement, x, ignore.case = FALSE, perl = FALSE, fixed = FALSE, useBytes = FALSE)
drops <- gsub('_Gmex', '_Atl', drops)

# OK. So here we need to understand some context. 'SEFSC_GOMexFall' is the Gulf of Mexico survey
# This survey went from 1982-2014 and occured in the Summer and Fall.
# So what needs to be done is see whether a row has 'region' belonging to these surveys and seasons and
# see whether the 'sppocean' value is in the 'drops' vector
# Rows that fall into this classification are filtered out using !
dat <- dat[!(dat$region=='SEFSC_GOMexFall' & dat$sppocean %in% drops),]
# Same for Summery surveys
dat <- dat[!(dat$region=='SEFSC_GOMexSummer' & dat$sppocean %in% drops),]

# trim columns that are already in master hauls file, which will be merged in below with the hauls data
# Creating a new data frame using columns and data from 'dat' data frame
dat <- data.frame(haulid = dat$haulid, sppocean = dat$sppocean, Freq = dat$Freq, wtcpue = dat$wtcpue, logwtcpue = dat$logwtcpue, presfit = TRUE, stringsAsFactors = F)
# Here the rows that have'sppocean'  value of 'NO CATCH' will be filtered out
dat <- dat[!dat$sppocean=='NO CATCH',]
#dat <- dat[!is.na(dat$wtcpue),] # drop NAs as it creates errors for some species. May want to go back and manually do 'oncorhynchus tshawytscha_Pac' as almost 10% of presence records have NA for wtcpue (tagging study?)
# Found a species naming error_correcting here
dat$sppocean[dat$sppocean=='heppasteria phygiana_Atl'] <- 'hippasteria phrygiana_Atl' # no need to aggregate as they never overlapped w/n hauls (only found in Newfoundland and they called it one way or the other)


############# ------------- This is the new code ------------#############

# We join the hauls and BSB observations for just the BSB observations
bsb_env <- merge(dat,hauls,by='haulid',all.x=T,sort=F)

# write.csv(bsb_env, file="data/merged_bsb_observations.csv")
# So we have 5405 observations there.
# Now we need to get the mean for the following values
# i. SBT.min
# ii. SBT.max
# iii. SST.max
# iv. rugosity
# v. GRAINSIZE
# vi. SST.seasonal.mean

# And we need to get the range for these values
# i. SBT.seasonal
# ii. o2_seasonal

# So, we will create a new dataframe and fill it up with these values
# Do we run these models for each region?
# Probably yes
# So we just make a list of the regions and loop through them also
# List the unique 'regionfact'
# First, drop the levels that aren't being used
bsb_env <- droplevels(bsb_env)
print(unique(bsb_env$regionfact))

# Drop the 'NA' based on regionfact and then drop the unused levels again
bsb_env <- bsb_env %>% 
  tidyr::drop_na(regionfact) %>% droplevels()

bsb_env <- bsb_env %>% 
  dplyr::select(haulid, SBT.min, SBT.max, SST.max,
                rugosity, GRAINSIZE, SST.seasonal.mean, SBT.seasonal, o2_seasonal,
                regionfact, zplk_class_sum_across_column, mi, salinity_seasonal)


surveys_categorized <- bsb_env %>% 
  dplyr::group_by(regionfact) %>% 
  dplyr::summarise()


test_df <- expand.grid(1:3,1:10, etc=c(5))

temp_range <- range(bsb_env$SBT.seasonal)

# 2022-06-

# Create a SBT sequence for this range
# SBT_seasonal_seq <- seq(temp_range[1], temp_range[2], 0.5)
SBT_seasonal_seq <- seq(-3, temp_range[2], 0.5)

# Do the same for o2_seasonal
o2_range <- range(bsb_env$o2_seasonal)
# o2_seasonal_seq <- seq(o2_range[1], o2_range[2], 0.00002)
o2_seasonal_seq <- seq(o2_range[1], 0.0004, 0.00002)

# mean for the other values will go in the dataframe
bsb_matrix <- expand.grid(SBT.min=mean(bsb_env$SBT.min),
                          SBT.max=mean(bsb_env$SBT.max),
                          SST.max=mean(bsb_env$SST.max),
                          rugosity=mean(bsb_env$rugosity),
                          GRAINSIZE=mean(bsb_env$GRAINSIZE),
                          SST.seasonal.mean=mean(bsb_env$SST.seasonal.mean),
                          salinity_seasonal=mean(bsb_env$salinity_seasonal),
                          zplk_class_sum_across_column=mean(bsb_env$zplk_class_sum_across_column),
                          SBT.seasonal=SBT_seasonal_seq,
                          o2_seasonal=o2_seasonal_seq,
                          regionfact=factor(c("NEFSC_NEUS")))


# Now we should run the model and get the results
# From here starts 'roms_data_ver_16_interaction_classic_model.R'

# Basically run the model and then predict using both the full model and the
# testing/training model



# From here on make the predictions based on the 'bsb_matrix'
# Make predictions for both models from testing-training split
# and the full dataset

# Predict using the 80/20 model and the full model
# Predict both the occurence and biomass
# As well as the uncertainly associated with each prediction


# For FULL model
# preds1 <- mygam1$fitted.values
# mygam1 is the presence model
# Why do we say 'exp'. Because the abundance values are in 'log'.
# To get natural values we need to exponent them
# What stuff here means
# We are predicting how well mygam2 predicted the abundance
# We compare it to spdata dataframe (This is what we measure our predictions against)
# type="response" gives the predicted probabilities
# preds2 <- exp(predict(mygam2, newdata = spdata, type='response', na.action='na.pass')) # abundance predictions
# mygam2 is the abundance model


# Load the gams
load("roms_tt_split_output/saved_models/jb_CEmods_Nov2017_GMEXdrop_full_model_o2_interaction_with_only_sbt_2021_11_09_centropristis striata_Atl.RData")

# Read the GAM for presence/absence
mygam1 <- mods$mygam1
# Read the GAM for biomass/abundance
mygam2 <- mods$mygam2


# Part I : First for the full model derived GAM

# For the abundance : We use mygam2
# Get the abundance values
abundance_full_prediction_val <- exp(predict(mygam2, newdata=bsb_matrix, 
                                             type='response', na.action='na.pass'))
# Then the standard error
abundance_full_prediction_se <- exp(predict(mygam2, newdata=bsb_matrix, 
                                            type='response', na.action='na.pass', se.fit=TRUE)$se.fit)

# Now let's plot these and see 
# First extract only the columns that we are interested in from bsb_matrix
bsb_vals <- bsb_matrix[c("SBT.seasonal", "o2_seasonal")]
# Then create a new dataframe for the predictions
full_model_predictions_abundance_val <- cbind(bsb_vals, 
                                              abundance_full_prediction_val)
# Rename the Columns
names(full_model_predictions_abundance_val)[2] <- "O2.seasonal"
names(full_model_predictions_abundance_val)[3] <- "Abundance"
# Import ggplot2
library(ggplot2)
# Using the guidelines here for coloring and plotting the matrix
# https://www.r-graph-gallery.com/79-levelplot-with-ggplot2.html
# Use 'geom_tile' for plotting
abundance_plot <- ggplot(full_model_predictions_abundance_val, aes(SBT.seasonal, 
                                                                   O2.seasonal, fill= Abundance)) + 
  geom_tile()+
  scale_fill_gradient(low="white", high="blue")



# Now create the same dataframe for standard error
full_model_predictions_abundance_se <- cbind(bsb_vals, 
                                             abundance_full_prediction_se)
# Rename the columns same as before
names(full_model_predictions_abundance_se)[2] <- "O2.seasonal"
names(full_model_predictions_abundance_se)[3] <- "SE"
# Create the plot
abundance_se_plot <- ggplot(full_model_predictions_abundance_se, aes(SBT.seasonal, 
                                                                     O2.seasonal, fill= SE)) + 
  geom_tile() +
  scale_fill_gradient(low="white", high="blue")


# For the presence : We use mygam1
# Get the probabilities
presence_full_prediction_val <- predict(mygam1, newdata=bsb_matrix, 
                                        type='response', na.action='na.pass')
# Then the standard error
presence_full_prediction_se <- predict(mygam1, newdata=bsb_matrix, 
                                       type='response', na.action='na.pass', se.fit=TRUE)$se.fit

# Then create a new dataframe for the predictions
full_model_predictions_presence_val <- cbind(bsb_vals, 
                                             presence_full_prediction_val)
# Rename the Columns
names(full_model_predictions_presence_val)[2] <- "O2.seasonal"
names(full_model_predictions_presence_val)[3] <- "Presence"

presence_plot <- ggplot(full_model_predictions_presence_val, aes(SBT.seasonal, 
                                                                 O2.seasonal, fill= Presence)) + 
  geom_tile() +
  scale_fill_gradient(low="white", high="blue")



# Now create the same things for the Standard Error
full_model_predictions_presence_se <- cbind(bsb_vals, 
                                            presence_full_prediction_se)
# Rename the Columns
names(full_model_predictions_presence_se)[2] <- "O2.seasonal"
names(full_model_predictions_presence_se)[3] <- "Presence.SE"

presence_se_plot <- ggplot(full_model_predictions_presence_se, aes(SBT.seasonal, 
                                                                   O2.seasonal, fill= Presence.SE)) + 
  geom_tile() +
  scale_fill_gradient(low="white", high="blue")

# 


write.csv(full_model_predictions_presence_val, file="visuazling_tt_split_model/data/presence_predictions_2022_05_10.csv")


presence_predictions_df <- read_csv("visuazling_tt_split_model/data/presence_predictions_2022_05_10.csv")

presence_predictions_df$O2.seasonal <- presence_predictions_df$O2.seasonal*32*1000/0.9766


# 2022-05-10
# Now we'll have to separate the biomass and presence/absence into two different plots
# First we'll have to modify the plots themselves
# We'd have to modify the axis for the plots
presence_plot <- ggplot(presence_predictions_df, 
                        aes(SBT.seasonal, O2.seasonal, fill= Presence)) + 
  theme_classic() + 
  theme(axis.title = element_text(size = 14),
        axis.text=element_text(size=10),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10)) +
  labs(fill="Presence") + 
  xlab("") + ylab("Dissolved Oxygen (mg/L)") +
  geom_tile() +
  scale_fill_gradient(low="white", high="blue")







# 2022-05-10
# Now to plot the actual bsb observations

# This works
respirometry::conv_o2(o2=9.1, from="mg_per_l", to="kPa", temp=9.2, 
                      sal=34, atm_pres=1013.25)
# Now converting Dissolved Oxygen
# ROMS has DO is mol/kg
# mol/kg -> mg/L -> kPa
# 1 L of seawater = 1.024 kg
# 1 mol/0.9766 L
# Example = 0.0003 mol/kg
# This is : 32g/mol of O2
# So.... :
# Molar mass * [mol/kg] * [g to mg| 1000]
32*0.0003*1000
# So the value in mg/L is
32*0.0003*1000/0.9766


############################ Read the data ####################################

bsb_environment <- read.csv("roms_tt_split_output/model_outputs/metabolic_index_zooplankton_model_tt_split_2021_04_11_full_predictions.csv")

other_obs <- bsb_environment %>% filter(is.na(sppocean))

bsb_environment <- bsb_environment %>% filter(sppocean=="centropristis striata_Atl")


bsb_environment <- bsb_environment %>% drop_na(o2_seasonal)
# Do same for other obs
other_obs <- other_obs %>% drop_na(o2_seasonal)

# Convert the oxygen to mg/L
bsb_environment$o2_mgl <- bsb_environment$o2_seasonal*32*1000/0.9766
# Same for other_obs

other_obs$o2_mgl <- other_obs$o2_seasonal*32*1000/0.9766

# Get the minimum and maximum for 'o2_seasonal'
o2_seasonal_max <- max(bsb_environment$o2_seasonal, na.rm=TRUE)
# Get the minimum value
o2_seasonal_min <- min(bsb_environment$o2_seasonal, na.rm=TRUE)
# We should convert these from mol/kg to mg/L of seawater
o2_seasonal_max <- o2_seasonal_max*32*1000/0.9766
o2_seasonal_min <- o2_seasonal_min*32*1000/0.9766

# Do the same for 'SBT.seasonal'
sbt_seasonal_max <- max(bsb_environment$SBT.seasonal, na.rm=TRUE)
# Get the minimum value
sbt_seasonal_min <- min(bsb_environment$SBT.seasonal, na.rm=TRUE)

# Now let's create the matrix
# First get a sequence of values
# sbt_seasonal_seq <- seq(-1.5, 29.5, 0.5)
# sbt_seasonal_seq <- seq(-1.5, 29.5, 0.5)
sbt_seasonal_seq <- seq(-5, 30, 0.1)

# o2_seasonal_seq <- seq(o2_seasonal_min, 13, 0.1)
o2_seasonal_seq <- seq(o2_seasonal_min, 15, 0.1)

# Now make the matrix
sbt_o2_comb <- expand.grid(sbt_seasonal = sbt_seasonal_seq,
                           o2_seasonal=o2_seasonal_seq)

# Insert an empty column to the matrix for the partial pressure of O2
sbt_o2_comb$po2 <- NA

# Insert a value to the first row of the third column
# Notation is [row,column] for insertions
# We'll loop along the length of the matrix
# We'll use 'NROW' function to get the number of rows
matrix_seq <- seq(1, NROW(sbt_o2_comb))

# Now we loop through
for (loc in matrix_seq){
  sbt_o2_comb[loc,3] <- respirometry::conv_o2(o2=sbt_o2_comb[loc,2], 
                                              from="mg_per_l", 
                                              to="kPa", temp=sbt_o2_comb[loc,1], 
                                              sal=34, atm_pres=1013.25)
}

# Now convert Temperature units from Celsius to Kelvin
sbt_o2_comb[,1] <- sbt_o2_comb[,1] + 273.15

# Now do the computations for 'Metabolic index' : phi
# Metabolic index (phi) was defined by Deutch et al. (2015) as follows
# phi = Ao * Bn * Po2 / exp(-Eo/kB * T)
# Where
# phi -> Metabolic index [unitless]
# Ao -> 0.00040728 [unitless]
# Bn -> 1 [unitless]
# Po2 -> [units: kPa]
# Eo -> 0.27 [unitless]
# kB -> Boltzmann's constant: 8.617E-05 [units: eVK^-1]
# T -> [units: Kelvin]
# Species specific values for these constants were gathered from Saba et al, and
# Slesinger et al.
Ao <- 0.00040728
Bn <- 1E-02
Eo <- 0.27
kB <- 8.617E-05

# Insert an empty column to the matrix for the partial pressure of O2
sbt_o2_comb$phi <- NA

# For this operation we have to multiply the numerator by 10^-2 to equalize the terms
# So, we have the values for the metabolic index
for (loc in matrix_seq){
  sbt_o2_comb[loc,4] <- (Ao * sbt_o2_comb[loc,3] *Bn)/exp(-Eo/(kB*sbt_o2_comb[loc,1]))
}


# So, what should we do now??
# We should plot the variation of 'phi' with temperature and oxygen
# Then we should plot the variation of 'alpha' with temperature and oxygen
# Then we can start producing the interesting ecological states

# Date - 2020/11/29

# Now, change the first column back to Celsius and drop the third column
sbt_o2_comb <- sbt_o2_comb[,-3]
sbt_o2_comb[,1] <- sbt_o2_comb[,1] - 273.15

# theme_minimal()
# theme_classic()

phi_heatmap <- ggplot(sbt_o2_comb, aes(sbt_seasonal,
                                       o2_seasonal)) + 
  theme_classic() + 
  theme(axis.title = element_text(size = 14),
        axis.text=element_text(size=10),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10)) +
  geom_tile(aes(fill=phi)) +
  scale_fill_gradient(low="white", high="blue") + 
  labs(fill="  \u03d5  ") + 
  xlab("Temperature (C)") + ylab("Dissolved Oxygen (mg/L)") +
  geom_point(data = other_obs, 
             mapping = aes(x = SBT.seasonal, y = o2_mgl),
             alpha=0.3, size=1.2, color='grey') +
  geom_point(data = bsb_environment, 
             mapping = aes(x = SBT.seasonal, y = o2_mgl),
             alpha=0.3, size=1.2)


phi_heatmap

# Make a copy of sbt_o2_comb
phi_one_df <- sbt_o2_comb[(sbt_o2_comb$phi<1.01) & (sbt_o2_comb$phi>0.99500),]
phi_one_df$phi <- 1.0
phi_heatmap + geom_line(data = phi_one_df, 
                        mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=0.8)

phi_two_df <- sbt_o2_comb[(sbt_o2_comb$phi<2.01) & (sbt_o2_comb$phi>1.99500),]
phi_two_df$phi <- 2.0
bsb_vs_phi <- phi_heatmap + geom_line(data = phi_two_df, 
                                      mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=0.8) +
  geom_line(data = phi_one_df, 
            mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=0.8,
            color='red')

phi_two_half_df <- sbt_o2_comb[(sbt_o2_comb$phi<2.51) & (sbt_o2_comb$phi>2.49500),]
phi_two_half_df$phi <- 2.5
bsb_vs_phi <- phi_heatmap + geom_line(data = phi_two_df, 
                                      mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=0.8) +
  geom_line(data = phi_one_df, 
            mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=0.8,
            color='red') + 
  geom_line(data = phi_two_half_df, 
            mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=0.8,
            color='blue')

# Now we need to calculate how much of these points lie below each threshold
# No. of points below 1
# First calculate the MI for bsb_environment
bsb_environment$o2_seasonal_kPa <- respirometry::conv_o2(o2=bsb_environment$o2_mgl, 
                                                         from="mg_per_l", 
                                                         to="kPa", temp=bsb_environment$SBT.seasonal, 
                                                         sal=bsb_environment$salinity_seasonal, atm_pres=1013.25)

# Species specific values for these constants were gathered from Saba et al, and
# Slesinger et al.
Ao <- 0.00040728
Bn <- 1E-02
Eo <- 0.27
kB <- 8.617E-05

bsb_environment$mi <- (Ao * bsb_environment$o2_seasonal_kPa *Bn)/exp(-Eo/(kB*(bsb_environment$SBT.seasonal+273.15)))


#################### 2022-05-10 ###############################################

# Now let's count the number of observations below 1
mi_below_1 <- bsb_environment %>% dplyr::filter(mi<1)
mi_below_2 <- bsb_environment %>% dplyr::filter(mi<2)
mi_below_2_5 <- bsb_environment %>% dplyr::filter(mi<2.5)


# 2022-05-10
# Now plot the lines on the presence_plot

# First clean up the lines
phi_one_df <- phi_one_df %>% dplyr::filter(sbt_seasonal<=28)
phi_two_df <- phi_two_df %>% dplyr::filter(sbt_seasonal<=28)
phi_two_half_df <- phi_two_half_df %>% dplyr::filter(sbt_seasonal<=28)


pred_pres_obs <- ggplot(presence_predictions_df, 
                        aes(SBT.seasonal, O2.seasonal)) + 
  theme_classic() + 
  theme(axis.title = element_text(size = 14),
        axis.text=element_text(size=10),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10)) +
  labs(fill="Probability") + 
  xlab("") + ylab("Dissolved Oxygen (mg/L)") + xlab("Temperature (C)") +
  geom_tile(aes(fill = Presence)) +
  scale_fill_gradient(low="#e5f5e0", high="#31a354") +
  geom_point(data = other_obs, 
             mapping = aes(x = SBT.seasonal, y = o2_mgl),
             shape=1, alpha=0.1, size=1.2,fill=NA,color='grey') +
  geom_point(data = bsb_environment, 
             mapping = aes(x = SBT.seasonal, y = o2_mgl),
             shape=1,alpha=0.3, size=1.2,fill=NA,color='black') +
  geom_line(data = phi_one_df, 
            mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=0.8,
            color='#d53e4f') + 
  geom_line(data = phi_two_df, 
            mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=0.8,
            color='#fee08b') +
  geom_line(data = phi_two_half_df, 
            mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=0.8,
            color='#3288bd')

pred_pres_obs

ggsave(filename="roms_tt_split_output/figures/2023_02_07_interaction_vs_obs_mi.png", 
       pred_pres_obs, width=5, height=4)

# 2023-02-07
# Make an alternate plot with different styling

pred_pres_obs_2 <- ggplot(presence_predictions_df, 
                          aes(SBT.seasonal, O2.seasonal)) + 
  theme_classic() + 
  theme(axis.title = element_text(size = 14),
        axis.text=element_text(size=10),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10)) +
  labs(fill="Probability") + 
  xlab("") + ylab("Dissolved Oxygen (mg/L)") + xlab("Temperature (C)") +
  geom_tile(aes(fill = Presence)) +
  scale_fill_gradient(low="#fee6ce", high="#e6550d") +
  geom_point(data = other_obs, 
             mapping = aes(x = SBT.seasonal, y = o2_mgl),
             shape=1, alpha=0.9, size=1.2,fill=NA,color='gray') +
  geom_point(data = bsb_environment, 
             mapping = aes(x = SBT.seasonal, y = o2_mgl),
             shape=2,alpha=0.9, size=1.2,fill=NA,color='black') +
  geom_line(data = phi_one_df, 
            mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=1,
            color='black', linetype='twodash') + 
  geom_line(data = phi_two_df, 
            mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=1,
            color='#228833', linetype='dashed') +
  geom_line(data = phi_two_half_df, 
            mapping = aes(x = sbt_seasonal, y = o2_seasonal), alpha=1,
            color='#4477aa')

ggsave(filename="roms_tt_split_output/figures/temp_oxygen_interaction_vs_obs_mi.png", 
       pred_pres_obs_2, width=5, height=4)
