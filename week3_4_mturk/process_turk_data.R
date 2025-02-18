library(ggplot2)
library(stringr)
library(readr)
library(dplyr)


setwd("~/git/AIT602/week3_4_mturk/")

# Load the result of M-Turk
turk1 <- read_delim("data/safe.csv", delim = ",",col_names = TRUE ) 
turk2 <- read_delim("data/beautiful.csv", delim = ",",col_names = TRUE ) 

turk1 <- turk1[,c("Input.city_A", "Input.city_B", "Answer.safe_cities.label")]
turk2 <- turk2[,c("Input.city_A", "Input.city_B", "Answer.beauty_cities.label")]

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
colnames(scores) <- c("city", "safety_score", "beauty_score")
scores$city <- unique(c(levels(turk$city_A), levels(turk$city_B)))
scores$safety_score <- 0
scores$beauty_score <- 0

for (i in 1:nrow(turk)){
  if (!is.na(turk[i,]$Answer1)) {
    if (turk[i,]$Answer1 == "City 1\r"){
      scores[scores$city == turk[i,]$city_A,]$safety_score <- 
        scores[scores$city == turk[i,]$city_A,]$safety_score + 1
    } else {
      scores[scores$city == turk[i,]$city_B,]$safety_score <- 
        scores[scores$city == turk[i,]$city_B,]$safety_score + 1
    }
  }
  
  if (!is.na(turk[i,]$Answer2)) {
    if (turk[i,]$Answer2 == "City 2\r"){
      scores[scores$city == turk[i,]$city_A,]$beauty_score <- 
        scores[scores$city == turk[i,]$city_A,]$beauty_score + 1
    } else {
      scores[scores$city == turk[i,]$city_B,]$beauty_score <- 
        scores[scores$city == turk[i,]$city_B,]$beauty_score + 1
    }
  }
}

write.table(scores, "data/turk_scores.csv", row.names=F, col.names=T, sep=",")


# Plotting
summary(lm(safety_score ~ beauty_score, data=scores))

ggplot(scores, aes(x = safety_score, y = beauty_score, label = city)) +
  geom_point(color="blue")  + 
  geom_smooth(method = "lm", se = TRUE, color="red", size=0.2)  +
  theme_bw()+  geom_text(hjust = 0, nudge_x = 0.05) +
  ylab("Safe")+
  xlab("Beautiful") + ggtitle("Relationship between two dimensions of Turker's Perceptions")

