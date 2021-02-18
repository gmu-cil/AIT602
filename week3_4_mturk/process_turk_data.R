library(ggplot2)
library(stringr)
library(readr)
library(dplyr)


setwd("~/git/AIT602_Spring2021/week3_4_mturk/")

# Load the result of M-Turk
turk1 <- read_delim("data/turk_results_1.csv", delim = ",",col_names = TRUE ) 
turk2 <- read_delim("data/turk_results_2.csv", delim = ",",col_names = TRUE ) 
turk <- rbind(turk1, turk2)
rm (turk1)
rm (turk2)
turk$city_A <- as.factor(turk$city_A)
turk$city_B <- as.factor(turk$city_B)

# Counting the Scores
scores <- as.data.frame(matrix(ncol=2, nrow=6))
colnames(scores) <- c("city", "score")
scores$city <- unique(c(levels(turk$city_A), levels(turk$city_B)))
scores$score <- 0

for (i in 1:nrow(turk)){
  if (turk[i,]$Answer1 == "City A"){
    scores[scores$city == turk[i,]$city_A,]$score <- scores[scores$city == turk[i,]$city_A,]$score + 1
  } else {
    scores[scores$city == turk[i,]$city_B,]$score <- scores[scores$city == turk[i,]$city_B,]$score + 1
  }
  
  if (turk[i,]$Answer2 == "City A"){
    scores[scores$city == turk[i,]$city_A,]$score <- scores[scores$city == turk[i,]$city_A,]$score + 1
  } else {
    scores[scores$city == turk[i,]$city_B,]$score <- scores[scores$city == turk[i,]$city_B,]$score + 1
  }
}

write.table(scores, "data/turk_scores.csv", row.names=F, col.names=T, sep=",")


# Plotting
summary(lm(score1 ~ score2, data=data))

ggplot(shannon, aes(x = shannon.entropy, y = score, label = city)) +
  geom_point(color="blue")  + geom_smooth(method = "lm", se = FALSE, color="red", size=0.2)  +
  theme_bw()+  geom_text(hjust = 0, nudge_x = 0.05) +
  ylab("Dimension 1")+
  xlab("Dimension 2") + ggtitle("Relationship between two dimensions of Turker's Perceptions")

