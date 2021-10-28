# Topic Modelling

# install.packages("topicmodels")
library(topicmodels)
library(tidymodels)
library(tidytext)

data("AssociatedPress")

# Set a seed so that the output of the model is predictable: list(seed=1234)
lda_results <- LDA(AssociatedPress, k=4, control = list(seed=1234))
lda_results

ap_topics <- tidy(lda_results, matrix="beta")
ap_topics

lda_results_6 <- LDA(AssociatedPress, k=6, control = list(seed=1234))

ap_topics_6 <- tidy(lda_results_6, matrix="beta")

ap_topics_6_gamma <- tidy(lda_results_6, matrix="gamma")

ap_top_terms <- ap_topics %>% 
  group_by(topic) %>% 
  slice_max(beta, n = 10) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

ap_top_terms %>% 
  mutate(term = reorder_within(term, beta, topic)) %>% 
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()

  