#############################################################################
###"data/interpolate.R"
## This script does:
# 1. Load function required to interpolate data;
# 2. Interpolate a time series from a given data frame
## DEPENDS ON:
library(reshape2)
library(FNN)
library(akima)
## USED BY:
# Nothing
## CREATES:
# Results may vary
#############################################################################


# 1. Load function required to interpolate data ---------------------------

# This function takes a single user defined set of coordinates (coords): lon/ lat
# It also takes into account the given/desired sie name
# As well as a user defined dataframe (df) of temperature time series
# It then creates a time series for that point based on the nearest n (n) time series

## For testing ##
# coords <- c(28.431673, -32.638033)
# coords <- c(17.89, -31.33)
# df <- SACTNmonthly_v4.1
# n <- 5
##

load("data/SACTNmonthly_v4.1.Rdata")
load("metadata/site_list_v4.1.Rdata")

interpolate <- function(coords, df = SACTNmonthly_v4.1, sites = site_list, n = 5){
  # if(is.data.frame(coords) == F){
  #   coords <- data.frame(lon = coords[1], lat = coords[2])
  # }
  # sites1 <- site_list
  # sites1 <- site_list[site_list$date.start <= as.Date(start),]
  # sites1 <- sites1[sites1$date.end >= as.Date(end),]
  # if(length(sites1$site) < 1){
  #   stop("No time series cover the given range of dates. Please redefine the given date range.")
  # }
  
  
  
  
  # Expand coastal coordinates for more accurate interpolating
  lon2 <- akima::aspline(coastline$x, n = length(coastline$x)*10)$y
  lat2 <- akima::aspline(coastline$y, n = length(coastline$y)*10)$y
  
  
  nn <- n-1
  df2 <- data.frame()
  while(length(df2) <= 12){
    nn <- nn+1
    sites2 <- droplevels(sites1[as.integer(knnx.index(sites1[,5:6], coords, k = nn)),])
    df1 <- df[df$index %in% sites2$index,]
    df2 <- dcast(df1, index ~ date, mean, value.var="temp")
    df3 <- df2[, colSums(is.na(df2)) == 0]
  }
  intrp <- function(dat){
    (interpp(x = sites2$lon, y = sites2$lat, z = as.matrix(dat), xo = coords$lon, yo = coords$lat, linear = TRUE, 
             extrap = TRUE, dupl = "mean"))$z
  }
  site <- data.frame(site = name, adply(df3[2:length(df3)], 2, intrp))[,1:3]
  site$X1 <- as.Date(site$X1)
  # if(length(site$V1[complete.cases(site$V1)]) == 0){
  #   sites3 <- droplevels(sites1[as.integer(knnx.index(sites1[,5:6], coords, k = 2)),])
  #   df4 <- df[df$index %in% sites3$index,]
  #   df5 <- dcast(df4, index ~ date, mean, value.var="temp")
  #   df6 <- df5[, colSums(is.na(df5)) == 0]
  #   site <- data.frame(site = name, adply(df6[2:length(df6)], 2, colMeans))
  #   site$X1 <- as.Date(site$X1)
  # }
  colnames(site)[2:3] <- c("date", "temp")
  return(site)
}


# 2. Interpolate a time series from a given data frame --------------------

# coords <- c(28.431673, -32.638033) # The coordinates for the coastline near Qolora
# qolora <- interpolate(coords, "Qolora", n = 12)

# save(qolora, file = "data/Qolora.Rdata")