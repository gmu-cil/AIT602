library(ggplot2)
library(stringr)
library(readr)
library(dplyr)


setwd("/~/AIT602_Spring2021/week3_4_mturk/")

# Load the result of M-Turk
# culturally diverse cities
turk1 <- read_delim("data/Rafeef_turk.csv", delim = ",",col_names = TRUE ) 
# safe cities
turk2 <- read_delim("data/turk_safe_Yasas.csv", delim = ",",col_names = TRUE ) 

turk1 <- turk1[,c("Input.city_A", "Input.city_B", "Answer.Which city is more culturlly diverse.label")]
turk2 <- turk2[,c("Input.city_A", "Input.city_B", "Answer.which_city.label")]

colnames(turk1) <- c("city_A", "city_B", "Answer1")
colnames(turk2) <- c("city_A", "city_B", "Answer2")

turk2$Answer1 <- NA
turk1$Answer2 <- NA

turk <- rbind(turk1, turk2)
rm (turk1)
rm (turk2)
turk$city_A <- as.factor(turk$city_A)
turk$city_B <- as.factor(turk$city_B)

# Counting the Scores
scores <- as.data.frame(matrix(ncol=3, nrow=6))
colnames(scores) <- c("city", "diversity_score", "safe_score")
scores$city <- unique(c(levels(turk$city_A), levels(turk$city_B)))
scores$diversity_score <- 0
scores$safe_score <- 0

for (i in 1:nrow(turk)){
  if (!is.na(turk[i,]$Answer1)) {
    if (turk[i,]$Answer1 == "City A"){
      scores[scores$city == turk[i,]$city_A,]$diversity_score <- 
        scores[scores$city == turk[i,]$city_A,]$diversity_score + 1
    } else {
      scores[scores$city == turk[i,]$city_B,]$diversity_score <- 
        scores[scores$city == turk[i,]$city_B,]$diversity_score + 1
    }
  }
  
  if (!is.na(turk[i,]$Answer2)) {
    if (turk[i,]$Answer2 == "City A"){
      scores[scores$city == turk[i,]$city_A,]$safe_score <- 
        scores[scores$city == turk[i,]$city_A,]$safe_score + 1
    } else {
      scores[scores$city == turk[i,]$city_B,]$safe_score <- 
        scores[scores$city == turk[i,]$city_B,]$safe_score + 1
    }
  }
}

write.table(scores, "data/turk_scores_diverse_safe.csv", row.names=F, col.names=T, sep=",")


# Plotting
summary(lm(diversity_score ~ safe_score, data=scores))

ggplot(scores, aes(x = diversity_score, y = safe_score, label = city)) +
  geom_point(color="blue")  + 
  geom_smooth(method = "lm", se = TRUE, color="red", size=0.2)  +
  theme_bw()+  geom_text(hjust = 0, nudge_x = 0.05) +
  ylab("Culturally Diverse")+
  xlab("Safe") + ggtitle("Relationship between two dimensions of Turker's Perceptions")

