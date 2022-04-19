#!/usr/bin/env Rscript

# Written by Myeong Lee (calculating the ethnic heterogeneity of urban areas in the U.S.)

library(ggplot2)
library(stringr)
library(readr)
library(dplyr)
library(data.table)
library(SnowballC)
library(reshape2)
library(DescTools)
library(diverse)
library(tidyr)

setwd("~/git/AIT602/week12_diversity")

# Function that processes the Census data file.
extract_cities <- function (path){
  data <- read_delim(path, delim = ",",col_names = TRUE)
  # data[1,] <- gsub("; ", "_", data[1,])
  # data[1,] <- gsub(" ", "_", data[1,])
  # data[1,] <- gsub(":", "", data[1,])
  # data[1,] <- gsub("_-_", "-", data[1,])
  # colnames(data) <- data[1,]
  colnames(data) <- data[1,]
  data <- data[-1,]
  data<- data[,-which(str_detect(colnames(data), "Error"))]
  
  return (data)
}


# This data is the 5-year Estimate American Community Survey (ACS) data for 2017.
race <- extract_cities("2017_census/ACSDT5Y2017.B02001_data_with_overlays_2020-04-24T234215.csv")
race <- race[,1:9]

colnames(race) <- c("id", "city", "total", "white", "black", "native", "asian", "hawaii", "other_race")

race <- race[complete.cases(race),]

race$total <- as.integer(race$total)
race$white <- as.integer(race$white)
race$black <- as.integer(race$black)
race$native <- as.integer(race$native)
race$asian <- as.integer(race$asian)
race$hawaii <- as.integer(race$hawaii)
race$other_race <- as.integer(race$other_race)

# Calculating the proportions of each ethnic group
race$white <- race$white / race$total
race$black <- race$black / race$total
race$native <- race$native / race$total
race$asian <-  race$asian / race$total
race$hawaii <- race$hawaii / race$total
race$other_race <- race$other_race / race$total
race <- race[,c("city", "id", "white", "black", "native", "asian", "hawaii", "other_race")]


# Reshaping the DF for diversity calculation
columns=c("entity", "category", "value")
score_df <- gather(race[,-1], "category", "value", -id)
colnames(score_df) <- columns
score_df <- score_df[,columns]


# 1. Calculating the Herfindahl-Hirschman Index (HHI): When treating all the ethnic groups being orthogonal to each other.
hetero <- diverse::diversity(as.data.frame(score_df), type="hh")
hetero$HHI <- 1 - hetero$HHI
hetero$id <- row.names(hetero)
hetero <- hetero[,c("id", "HHI")]
race <- race %>% left_join(hetero, by=c("id"))


# 2. Calculating the Rao-Strirling diversity: When it is possible to identify the distances between different ethnic groups. 

## distance matrix: in this code, distances between categories are randomly generated. 
## In real research, this distance matrix needs to be constructed by modeling other dataset such as social netwrok data.
dimnames <-colnames(race[,4:ncol(race)-1])
dis <- matrix(data=sample(1:20, 36, replace = T), ncol = 6, nrow=6, dimnames = list(dimnames,dimnames) )
dis <- dis/20 # normalizing the distances so they range between 0 and 1.

rao <- diverse::diversity(as.data.frame(score_df), type="rao-stirling", dis=dis)
rao$id <- row.names(rao)
rao <- rao[,c("id", "rao.stirling")]
race <- race %>% left_join(rao, by=c("id"))


# Plot the differences between Rao-Stirling Diversity and HHI-based diversity: The higher, the more diverse.
plot(race[,c("HHI", "rao.stirling")])


# An Example: Washington DC's ethnic diversity compared to New York City's?
# In the examples below: if you use HHI for quantifying ethnic diversity, Washington DC area is more diverse; if using Rao-Stirling, NYC is more diverse.
# Of course, Rao-Stirling diversity is wrong here because we used random numbers for the distances between ethnic groups.
# But conceptually, it is important to note that choosing more precise measure is very important -- it makes the data science results different. 
race$HHI[race$city=="Washington, DC--VA--MD Urbanized Area (2010)"]
race$rao.stirling[race$city=="Washington, DC--VA--MD Urbanized Area (2010)"]

race$HHI[race$city=="New York--Newark, NY--NJ--CT Urbanized Area (2010)"]
race$rao.stirling[race$city=="New York--Newark, NY--NJ--CT Urbanized Area (2010)"]

