library(ggplot2)
library(stringr)
library(readr)
library(dplyr)
library(reshape2)
library(PerformanceAnalytics)
library(rtweet)

#### This Twitter data has been collected in Feb 2020.


setwd("~/git/AIT602_Spring2021/week10_twitter_network/")

####################
# 1. Collect the data. 
####################

# Twitter Keys
appname <- "myeong_app"
key <- "your_key"
secret <- "your_secret"
access_token <- "access_token"
access_secret <- "access_secret"

twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret,
  access_token = access_token,
  access_secret = access_secret)

fllrs <- get_followers("fairfaxhealth", n = 100) #ID: 117134352. Random 100 users who follow @fairfaxhealth
fx <- as.data.frame(t(matrix(c("117134352", "fairfaxhealth"))))

fllrs_info <- lookup_users(fllrs$user_id)
fllrs_info <- fllrs_info[,c("user_id", "screen_name")]
colnames(fx) <- colnames(fllrs_info)
fx$user_id <- as.character(fx$user_id)
fx$screen_name <- as.character(fx$screen_name)

network <- as.data.frame(matrix(ncol=2, nrow=0))
colnames(network) <- c("from", "to")

i=1

for (uid in fllrs$user_id){
  print (i)
  
  network[i,] <- c(uid, "117134352")
  i <- i+1
  
  tmp <- get_followers(uid, n=100, retryonratelimit = TRUE)
  tmp <- lookup_users(tmp$user_id)
  tmp <- tmp[,c("user_id", "screen_name")]
  fllrs_info <- rbind(fllrs_info, tmp)
  
  for (u in tmp$user_id){
    network[i,] <- c(u, uid)
    i <- i+1
  }
  Sys.sleep(2)
}

fllrs_info <- rbind(fllrs_info, fx)
fllrs_info <- fllrs_info[!duplicated(fllrs_info$user_id),]


write.table(fllrs_info, "data/user_names.csv", row.names = F, sep=",")
write.table(network, "data/links.csv", row.names = F, sep=",")
