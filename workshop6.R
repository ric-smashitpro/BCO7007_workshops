# Sentiment Analysis Part 2
# Session 6
# Date 21/10/2021

library(tidyverse)
library(tidytext)
library(textdata)

#twitter data (for assignment 2)
tweet <- read_csv("matcha_12_10_2021.csv")

class(tweet$created_at)
# install.packages("lubridate")
library(lubridate)

tweet <- 
  tweet %>% 
  mutate(timestamp = ymd_hms(created_at))

remove_reg <- "&amp;|&lt;|&gt;" # &amp = &, &lt = <, &gt = > 

# Removing special characters
tidy_tweets <- tweet %>% 
  filter(!str_detect(text, "^RT")) %>% #^RT = Retweet
  mutate(text = str_remove_all(text, remove_reg))

# Unnesting tweets
tidy_tweets<-tidy_tweets%>%
  unnest_tokens(word, text, token = "tweets")

selected_tweets <-  tidy_tweets %>% select(timestamp, word, user_id)

head(tidy_tweets$word)

tidy_tweets<-tidy_tweets%>%
  filter(!word %in% stop_words$word, #remove stopwords
         !word %in% str_remove_all(stop_words$word, "'"),
         str_detect(word, "[a-z]")) #keep only character-words

selected_tweets_tidy <-  tidy_tweets %>% select(timestamp, word, user_id)

# Remove mentions, urls, emojis, numbers, punctuations, etc.
tidy_tweets$word<-
  gsub("@\\w+", "", tidy_tweets$word)

tidy_tweets$word<-
  gsub("https?://.+", "", tidy_tweets$word)

tidy_tweets$word <- gsub("\\d+\\w*\\d*", "", tidy_tweets$word)
tidy_tweets$word <- gsub("#\\w+", "", tidy_tweets$word)
tidy_tweets$word <- gsub("[^\x01-\x7F]", "", tidy_tweets$word)
tidy_tweets$word <- gsub("[[:punct:]]", " ", tidy_tweets$word)

# sentiments
bing <- get_sentiments("bing")
nrc <- get_sentiments("nrc")

# use tidy_tweets variable. Maria used selected_tweets_tidy as she is having issues with her computer
selected_tweets_tidy<-tidy_tweets%>%select(timestamp, word, user_id)

selected_tweets_tidy<-selected_tweets_tidy%>%
  inner_join(bing)

selected_tweets_tidy %>% 
  count(sentiment, SORT = TRUE)

selected_tweets_tidy %>% 
  group_by(user_id) %>% 
  count(sentiment, SORT = TRUE)

# Working with wordclouds
# install.packages("wordcloud")
library(wordcloud)

selected_tweets_tidy%>%count(word) %>%
  with(wordcloud(word, n, max.words = 100))
