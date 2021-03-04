library(ggplot2)
library(stringr)
library(readr)
library(dplyr)
library(reshape2)
library(PerformanceAnalytics)
library(rtweet)
library(sm)
library(car)


setwd("~/git/AIT602_Spring2021//week6_stat/")

#############
# 1. Load the data. 
data <- read_delim("data/corona_tweets_03042021.csv", delim = ",",col_names = TRUE)
data$source <- as.factor(data$source)
data$user_id <- as.factor(data$user_id)

#############
# 2. Tweet frequency per user & per source
table(data$user_id)

summary(data$source)

#############
# 3. Numbers of favorites, retweets, and text length distribution
hist(data$favorite_count)
hist(data$retweet_count)
hist(data$display_text_width)

# denstiy graph
d <- density(data$display_text_width)
plot(d)
polygon(d, col="red")

# Not normal...
shapiro.test(data$favorite_count)
shapiro.test(data$retweet_count)
shapiro.test(data$display_text_width)

#############
# 4. Normality test per each source (3 biggest)

shapiro.test(data$favorite_count[data$source=="Twitter for Android"])
shapiro.test(data$favorite_count[data$source=="Twitter for iPhone"])
shapiro.test(data$favorite_count[data$source=="Twitter Web App"])
shapiro.test(data$retweet_count[data$source=="Twitter for Android"])
shapiro.test(data$retweet_count[data$source=="Twitter for iPhone"])
shapiro.test(data$retweet_count[data$source=="Twitter Web App"])
shapiro.test(data$display_text_width[data$source=="Twitter for Android"])
shapiro.test(data$display_text_width[data$source=="Twitter for iPhone"])
shapiro.test(data$display_text_width[data$source=="Twitter Web App"])
# Nothing is normal distribution

# homogeneity of variance
leveneTest(data$favorite_count, data$source, center=mean) #homogeneous
leveneTest(data$retweet_count, data$source, center=mean)  #homogeneous
leveneTest(data$display_text_width, data$source, center=mean) # NOT homogeneous

########
# 5. Some ANOVAs -- a quasi-experiment 
# So, in many cases, ANOVA results could be biased.
summary(aov(display_text_width ~ source, data=data))
summary(aov(favorite_count ~ source, data=data))
summary(aov(retweet_count ~ source, data=data))

########
# 6. Linear Regressions
fav <- lm(favorite_count ~ display_text_width, data=data)
ret <- lm(retweet_count ~ display_text_width, data=data)
summary(fav)
summary(ret)

# plot 1: Residuals vs Fitted: showing linear or non-linear relationship (line needs to be straight)
# plot 2: Normal Q-Q: showing if residuals are normaly distributed (if folloinwg the straight line) -- normality
# plot 3: Scale-Location: shows if residuals are spread equally along the ranges of predictors -- heteroscedasticity, Line needs to be horizontal.
# plot 4: Residual vs Leverage: Shows if there are outliers who are influential in deciding the regression line. Regression lines need to be outside of Cook's distance lines.
par(mfrow=c(2,2)) # init 4 charts in 1 panel
plot(fav)
plot(ret)

table(corona_tweets$is_quote)
just_test <- lm(is_quote ~ display_text_width + favorite_count + retweet_count, data = data)
summary(just_test)
car::vif(just_test) # it's safe from multicolinearity issue


#### some benchmarks
fav_bench <- rnorm(500, mean=mean(data$favorite_count), sd=sd(data$favorite_count))
ret_bench <- rnorm(500, mean=mean(data$retweet_count), sd=sd(data$retweet_count))
width_bench <- rnorm(500, mean=mean(data$display_text_width), sd=sd(data$display_text_width))
fav_lm <- lm(fav_bench ~ width_bench)
summary(fav_lm)
ret_lm <- lm(ret_bench ~ width_bench)
summary(ret_lm)

plot(fav_lm)
plot(ret_lm)


########
# 6. Logistic Regression

# this particular example is not a good case -- "is_quote" is too skewed. 
lgit <- glm(is_quote ~ display_text_width + favorite_count + retweet_count, 
            data = data, family = "binomial")
summary(lgit)


