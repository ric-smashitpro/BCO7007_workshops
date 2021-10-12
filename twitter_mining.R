library(tidyverse)
library(rtweet)

# repeat every week
data <- search_tweets(
  q = "Melbourne",
  n=18000,
  include_rts = FALSE,
  lang = "en",
  retryonratelimit = TRUE
)

data <- data %>% flatten()


# Change the name of the file
# if you don't you are going to lose your data!

data %>% write_csv("Melbourne_12_10_2021.csv")


#---------------------
# Merge all CSV files at the end - when you start your assessment
# Merging and opening of all csv files
# collects all csv filenames
files <- list.files(pattern = "\\.csv$", full.names = TRUE) # read file names with csv
all_data <- map_df(files, ~read.csv(.x)) # open and merge

# you may have duplicate entries
final_data <-  all_data %>% distinct()