library(ggplot2)
library(stringr)
library(readr)
library(dplyr)
library(reshape2)
library(PerformanceAnalytics)

#### Ack: The data and scripts are from: https://www.r-exercises.com/2017/04/23/experimental-design-exercises
#### Experiment: How working-out affects people's body mass?
#### Three groups all have similar food and sport habits
#### Each group did a different type of exercise


setwd("~/git/AIT602_Spring2021/week5_experiments/")

####################
#    Exercise 1: Load the data. 
#    Calculate descriptive statistics and test for the normality of both initial and final measurements 
#   for whole sample and for each group
####################


data <- read.csv("data/experimental-design.csv")
as.factor(data$group) -> data$group
as.factor(data$age) -> data$age
summary(data$initial_mass)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   53.50   62.18   68.90   67.70   72.27   86.00
summary(data$final_mass)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   50.60   60.08   64.45   65.44   72.00   81.30
shapiro.test(data$initial_mass) 
## 
## 	Shapiro-Wilk normality test
## 
## data:  data$initial_mass
## W = 0.98306, p-value = 0.5053 --- normal
shapiro.test(data$final_mass)
## 
## 	Shapiro-Wilk normality test
## 
## data:  data$final_mass
## W = 0.97517, p-value = 0.2073 --- normal 
sapply(split(data$initial_mass, data$group), summary)
##             1     2     3
## Min.    53.50 53.50 54.50
## 1st Qu. 63.40 62.00 62.18
## Median  68.20 69.65 68.25
## Mean    67.24 68.26 67.58
## 3rd Qu. 70.00 73.00 72.72
## Max.    86.00 82.00 81.00
sapply(split(data$final_mass, data$group), summary)
##             1     2     3
## Min.    50.60 52.00 51.00
## 1st Qu. 60.08 60.25 61.00
## Median  62.95 70.50 65.00
## Mean    62.43 68.64 65.25
## 3rd Qu. 64.62 75.00 72.00
## Max.    81.30 81.00 77.00

sapply(split(data$age, data$group), summary)
#             1  2 3
# middle-age  6 10 9
# old         5  6 5
# young      11  6 8

sapply(split(data$initial_mass, data$group), shapiro.test)
##           1                             2                            
## statistic 0.9561618                     0.9735745                    
## p.value   0.415793                      0.7920937                    
## method    "Shapiro-Wilk normality test" "Shapiro-Wilk normality test"
## data.name "X[[i]]"                      "X[[i]]"                     
##           3                            
## statistic 0.9777148                    
## p.value   0.8768215                    
## method    "Shapiro-Wilk normality test"
## data.name "X[[i]]"
sapply(split(data$final_mass, data$group), shapiro.test)
##           1                             2                            
## statistic 0.9447748                     0.9231407                    
## p.value   0.2479696                     0.08832153                   
## method    "Shapiro-Wilk normality test" "Shapiro-Wilk normality test"
## data.name "X[[i]]"                      "X[[i]]"                     
##           3                            
## statistic 0.9453135                    
## p.value   0.2543017                    
## method    "Shapiro-Wilk normality test"
## data.name "X[[i]]"
####################
#    Exercise 2: Is there effect of exercises and what is the size of that effect for each group? (Tip: You should use paired t test.)
####################


invisible(sapply(split(data, data$group), function(x)
{
  t.test(x$initial_mass, x$final_mass, paired=TRUE) -> t
  cat(sprintf("Group %d\r\nstatistic=%.3f\r\ndf=%d\r\np=%.3f\r\neta^2=%.3f\r\n\r\n",
              unique(x$group), t$statistic, t$parameter, t$p.value,
              t$statistic^2/(t$statistic^2+t$parameter)))
  
}))
## Group 1

## statistic=7.474
## df=21
## p=0.000
## eta^2=0.727
## 

## Group 2
## statistic=-0.687
## df=21
## p=0.500
## eta^2=0.022
## 

## Group 3
## statistic=4.372
## df=21
## p=0.000
## eta^2=0.477
## 

####################
#    Exercise 3: Is the variance of the body mass on final measurement the same for each of the three groups? (Tip: Use Levene’s test for homogeneity of variances)
####################


library("car")
leveneTest(data$final_mass, data$group, center=mean)
## Levene's Test for Homogeneity of Variance (center = mean)
##       Df F value Pr(>F)
## group  2   1.232 0.2986
##       63
# There's evidence that the test does not reject the null hypothesis (which means the variances are homogeneous)

####################
#    Exercise 4: Is there a difference between groups on final measurement and what is the effect size? (Tip: Use one-way ANOVA)
####################


print(summary(aov(final_mass ~ group, data)) -> f)
##             Df Sum Sq Mean Sq F value Pr(>F)  
## group        2    425  212.64   3.626 0.0323 *
## Residuals   63   3694   58.64                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
ss = f[[1]]$'Sum Sq'
paste("eta squared=", round(ss[1] / (ss[1]+ss[2]), 3))
## [1] "eta squared= 0.103"
####################
#    Exercise 5: Between which groups does the difference of body mass appear after the working-out? (Tip: Conduct post-hoc test.)
####################


summary(f <- aov(final_mass ~ group, data))
##             Df Sum Sq Mean Sq F value Pr(>F)  
## group        2    425  212.64   3.626 0.0323 *
## Residuals   63   3694   58.64                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
TukeyHSD(f, "group")
##   Tukey multiple comparisons of means
##     95% family-wise confidence level
## 
## Fit: aov(formula = final_mass ~ group, data = data)
## 
## $group
##          diff        lwr       upr     p adj
## 2-1  6.209091  0.6669343 11.751248 0.0245055
## 3-1  2.818182 -2.7239748  8.360338 0.4455950
## 3-2 -3.390909 -8.9330657  2.151248 0.3128050
# significant difference appears between 1st and 2nd group (p<0.05)


####################
#    Exercise 6: What is the impact of age and working-out program on body mass on final measurement? (Tip: Use two-way between groups ANOVA.)
####################


options(contrasts = c("contr.helmert", "contr.poly"))
m.lm <- lm(final_mass ~ age + group + age*group, data=data)
print(m.anova <- Anova(m.lm, type=3))
## Anova Table (Type III tests)
## 
## Response: final_mass
##             Sum Sq Df   F value    Pr(>F)    
## (Intercept) 267773  1 8536.0541 < 2.2e-16 ***
## age           1388  2   22.1282 7.725e-08 ***
## group          186  2    2.9678  0.059415 .  
## age:group      564  4    4.4981  0.003152 ** 
## Residuals     1788 57                        
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
m.anova[[1]][2:4] / (m.anova[[1]][2:4]+m.anova[[1]][5])
## [1] 0.43707242 0.09431139 0.23992294
####################
#    Exercise 7: What is the origin of effect of working-out program between subjects of different age? (Tip: You should conduct post-hoc test.)
####################


m.aov <- aov(final_mass ~ age + group +  age*group, data)
TukeyHSD(x=m.aov, "age")
##   Tukey multiple comparisons of means
##     95% family-wise confidence level
## 
## Fit: aov(formula = final_mass ~ age + group + age * group, data = data)
## 
## $age
##                       diff        lwr       upr     p adj
## old-middle-age     6.69775   2.382683 11.012817 0.0012494
## young-middle-age  -5.75200  -9.564155 -1.939845 0.0017300
## young-old        -12.44975 -16.764817 -8.134683 0.0000000
# there is significant difference between all groups

