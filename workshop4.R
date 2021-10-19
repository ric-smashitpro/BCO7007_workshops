library(tidyverse)
library(tidytext)
library(janeaustenr)

# install.packages("textdata")
library(textdata)


# Load text
tidy_books <- austen_books() %>% 
  group_by(book) %>% 
  mutate(linenumber = row_number(), 
         chapter = cumsum(str_detect(text, 
                                     regex("^chapter [\\divxlc]", #use regular expression to search for chapter X
                                           ignore_case = TRUE)))) %>%
  ungroup() %>% 
  unnest_tokens(word, text)

# use nrc dictionary
nrc <-  get_sentiments("nrc") 

nrc_joy <- get_sentiments("nrc") %>% 
  filter(sentiment == "joy")

tidy_books %>% 
  filter(book == "Emma") %>% 
  inner_join(nrc) %>% 
  count(sentiment, sort =TRUE)

# use bing dictionary - positive and negative only
bing <-  get_sentiments("bing")

jane_austen_sentiment <- tidy_books %>% 
  inner_join(get_sentiments("bing")) %>% 
  count(book, index = linenumber %/% 80, sentiment) %>% 
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>% 
  mutate(sentiment = positive - negative)

jane_austen_sentiment %>% 
  ggplot(aes(index, 
             sentiment, 
             fill = book)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~book, ncol = 2, scales = "free_x")

