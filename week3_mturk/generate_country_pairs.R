
# 6 U.S. cities
# Population Ranking: 1,2,3, 20,21,22
setwd("~/git/AIT602_Spring2021/week3_mturk/")
target_cities <- c("New York, NY", "Los Angeles, CA", "Chicago, IL", "Washington, DC", "Boston, MA", "El Paso, TX")

turk <- as.data.frame(matrix(ncol =3, nrow=0))
colnames(turk) <- c("id", "city_A", "city_B")
turk$id <- as.character(turk$id)
turk$city_A <- as.character(turk$city_A)
turk$city_B <- as.character(turk$city_B)
k = 1
len = length(target_cities)

for (i in 1:(len-1)){
  for (j in (i+1):len){
    # print(j)
    c <- data.frame(k, target_cities[i], target_cities[j])
    colnames(c) <- c("id", "city_A", "city_B")
    c$id <- as.character(c$id)
    c$city_A <- as.character(c$city_A)
    c$city_B <- as.character(c$city_B)
    
    k <- k+1
    turk <- rbind(turk, c)
  }
}
write.csv(turk, file="data/turk.csv", row.names = FALSE)
