library(ggplot2)
library(stringr)
library(readr)
library(dplyr)
library(reshape2)
library(PerformanceAnalytics)
library(igraph)
library(ggraph)


setwd("~/git/AIT602/week10_twitter_network/")


users <- read_delim("data/user_names.csv",  delim = ",",col_names = TRUE, col_types = "cc" )
links <- read_delim("data/links.csv",  delim = ",",col_names = TRUE, col_types = "cc" )

# links <- rbind(sample_n(links, 1000), links[nrow(links),])
users <- users[is.element(users$user_id, links$from) | is.element(users$user_id, links$to),]

# Constructing iGraph
net = graph_from_data_frame(links, vertices = users, directed = T)

# Centrality measures
bet <- betweenness(net, v = V(net), directed = TRUE, weights = NULL,
            normalized = FALSE)
close <- closeness(net, vids = V(net), mode = "all", 
                   weights = NULL, normalized = FALSE)

hist(log(bet+1), breaks=100)
hist(close, breaks=100)

users$betweenness <- bet
users$closeness <- close

ggraph (links, layout="nicely") +
  geom_edge_link(arrow = arrow(length = unit(1, 'mm'))) +
  geom_node_point() +
  # geom_node_text(aes(label = name))+ #if you want to display User ID
  theme_graph() 

# PageRank
pr <- page_rank (net, vids=V(net))
pr$vector
users$page_rank <- pr$vector

summary(lm(page_rank ~ betweenness + closeness, data=users))



