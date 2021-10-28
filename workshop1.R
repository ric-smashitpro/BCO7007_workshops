# Step 1 - install packages
# install.packages("tidyverse")

# install.packages("tidymodels")

# install.packages("tidytext")

# install.packages("rtweet")


# Step 2 - load packages
library(tidyverse)
library(tidymodels)
library(tidytext)
library(rtweet)

# Create a variable with tweets

my_tweets <- "my awesome first text variables"
my_numbers <- 5
my_numbers <- "5"

my_real_tweets <- search_tweets(
  q = "chocolate",
  n = 1000,
  type = "popular"
)
 


my_lindt_tweets <-  search_tweets(
  q = "#lindt",
  n = 3000,
  include_rts = FALSE,
  lang = "fr"
)

my_coffee_tweets <-  search_tweets(
  q = "coffee",
  # n = 3000,
  include_rts = FALSE,
  lang = "en",
  retryonratelimit = TRUE
)

lindt <-  lookup_users("Lindt")
