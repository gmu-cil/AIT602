library(ggplot2)
library(stringr)
library(readr)
library(dplyr)
library(reshape2)
library(PerformanceAnalytics)
library(rtweet)

#### This Twitter data was collected using the #Coronavirus hashtag.


setwd("~/git/AIT602_Spring2021/week6_stat/")

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

corona_tweets <- search_tweets(q="#Coronavirus", n=500, include_rts = FALSE, lang = "en")
corona_tweets <- corona_tweets[,1:16]

corona_tweets$text <- iconv(corona_tweets$text, from = 'UTF-8', to = 'ASCII//TRANSLIT')
corona_tweets$text <- gsub("(f|ht)tp\\S+\\s*", "", corona_tweets$text)
corona_tweets$text <- gsub("[^-0-9A-Za-z///' ]", " ", corona_tweets$text, ignore.case = TRUE)
corona_tweets$text <- gsub("\\s+"," ",corona_tweets$text)

write.table(corona_tweets, "data/corona_tweets_03042021.csv", row.names = F, sep=",")
