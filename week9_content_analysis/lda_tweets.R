library(stringr)
library(readr)
library(dplyr)
library(tm)
library(ldatuning)
library(topicmodels)
library(tidytext)
library(text2vec)
library(SnowballC)
library(LDAvis)

setwd("~/git/AIT602/week9_content_analysis/data")

get_tokens <- function (df){
  data("stop_words")
  
  tidy_text <- df %>% dplyr::select(status_id, text)
  tidy_text <- tidy_text[,c("status_id", "text")]
  tidy_text <- tidy_text %>% unnest_tokens("word", text)
  
  #Removing stop words
  tidy_text <- tidy_text %>% anti_join(stop_words, by=c("word"))
  
  #removing numbers
  if (nrow(tidy_text[str_detect(tidy_text$word, "\\b\\d+\\b"),]) !=0){
    tidy_text <- tidy_text[-grep("\\b\\d+\\b", tidy_text$word),]
  }
  
  # removing whitespaces
  tidy_text$word <- gsub("\\s+","",tidy_text$word)
  
  # Stemming
  tidy_text <- tidy_text %>% mutate_at("word", funs(wordStem((.), language="en")))
  
  tidy_text
}

# Loading the Twitter data
tweets <- read_delim("corona_tweets_Feb2020.csv", delim = ",",col_names = TRUE)
tweets <- get_tokens(tweets)

# Tokenizing and text pre-processing
it = itoken(tweets$word, progressbar = TRUE)
v = create_vocabulary(it) %>%
  prune_vocabulary(doc_proportion_max = 0.1, term_count_min = 5)
vectorizer = vocab_vectorizer(v)
dtm = create_dtm(it, vectorizer)
castdtm <- tweets %>% count(status_id, word) %>% cast_dtm(status_id, word, n)

# Tuning -- determining K
result <- FindTopicsNumber(
  castdtm,
  topics = round(seq(1, 15, 1)),
  metrics = c("Arun2010", "Deveaud2014"),
  method = "Gibbs",
  control = list(seed = 12),
  mc.cores = 10L,
  verbose = TRUE
)
FindTopicsNumber_plot(result)


# LDA Viz
k = 4
a = 0.1
t = 0.01
lda_model = LDA$new(n_topics = k, doc_topic_prior = a, topic_word_prior = t)
doc_topic_distr = lda_model$fit_transform(x = dtm, n_iter = 1000,
                                          convergence_tol = 0.001, n_check_convergence = 25,
                                          progressbar = TRUE)
lda_model$plot()

# LDA
topic_model <- LDA(castdtm, k=4, control = list(seed = 123)) 
topics      <- tidy(topic_model, matrix = "beta")
docs        <- tidy(topic_model, matrix = "gamma")
write.table(topics, "tweet_topics.csv", row.names = F, sep=",")
print("Done.")
