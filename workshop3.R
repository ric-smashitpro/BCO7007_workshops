# installed.packages("janeaustenr")

library(tidyverse)
library(tidytext)
library(janeaustenr)

data_books <- austen_books()

data_2_tokens <- data_books %>%  unnest_tokens(word, text)

book_word <- data_2_tokens %>% count(book, word, sort = TRUE)

total_words <- book_word %>%
  group_by(book) %>% 
  summarise(total = sum(n))

data_join <- left_join(book_word, total_words)

data_join2 <- right_join(book_word, total_words)