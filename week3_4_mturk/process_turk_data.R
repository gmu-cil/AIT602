library(ggplot2)
library(stringr)
library(readr)
library(dplyr)


setwd("~/git/AIT602_Spring2021/week3_4_mturk/")

# Load the result of M-Turk
turk1 <- read_delim("data/hingle_turk_hit_file.csv", delim = ",",col_names = TRUE ) 
turk2 <- read_delim("data/Akshata_BeautifulCity_Results.csv", delim = ",",col_names = TRUE ) 

turk1 <- turk1[,c("Input.city_A", "Input.city_B", "Answer.equal.label")]
turk2 <- turk2[,c("Input.city_A", "Input.city_B", "Answer.which_city.label")]

colnames(turk1) <- c("city_A", "city_B", "Answer1")
colnames(turk2) <- c("city_A", "city_B", "Answer2")

turk1$Answer2 <- NA
turk2$Answer1 <- NA

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
    next
  } else {
    scores[scores$city == turk[i,]$city_B,]$score <- scores[scores$city == turk[i,]$city_B,]$score + 1
    next
  }
  
  if (turk[i,]$Answer2 == "City A"){
    scores[scores$city == turk[i,]$city_A,]$score <- scores[scores$city == turk[i,]$city_A,]$score + 1
    next
  } else {
    scores[scores$city == turk[i,]$city_B,]$score <- scores[scores$city == turk[i,]$city_B,]$score + 1
    next
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

