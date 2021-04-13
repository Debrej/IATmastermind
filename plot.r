library(ggplot2)
library(dplyr)
library(readr)

df = read_csv("eval.csv", col_types=cols(ratio=col_factor()))
df_factors = read_csv("eval.csv", col_types=cols(ratio=col_factor(), pop=col_factor(), taux=col_factor()))
df_tours_30 = read_csv("evalFine30.csv", col_types=cols(ratio=col_factor(), pop=col_factor(), taux=col_factor()))
df_tours_15 = read_csv("evalFine15.csv", col_types=cols(ratio=col_factor(), pop=col_factor(), taux=col_factor()))
df_tours_5 = read_csv("evalFine5.csv", col_types=cols(ratio=col_factor(), pop=col_factor(), taux=col_factor()))

NB_RATIO = 5
NB_POP = 3
NB_TAUX = 4
NB_OCCURENCE = 50

# Data transformation
df_ratio_pop <- summarize(df, df = count(df, ratio, pop, found)) %>%
  filter(df$found == "TRUE") %>%
  group_by(df$ratio, df$pop) %>%
  summarize(pct = df$n/(NB_TAUX*NB_OCCURENCE)) %>% 
  ungroup() %>% 
  rename(pop = 'df$pop', ratio = 'df$ratio')

df_ratio_taux <- summarize(df, df = count(df, ratio, taux, found)) %>%
  filter(df$found == "TRUE") %>%
  group_by(df$ratio, df$taux) %>%
  summarize(pct = df$n/(NB_POP*NB_OCCURENCE)) %>% 
  ungroup() %>% 
  rename(taux = 'df$taux', ratio = 'df$ratio')

df_ratio_taux_pop <- summarize(df, df = count(df, ratio, taux, pop, found)) %>%
  filter(df$found == "TRUE") %>%
  group_by(df$ratio, df$taux, df$pop) %>%
  summarize(pct = df$n/NB_OCCURENCE) %>% 
  ungroup() %>% 
  rename(taux = 'df$taux', ratio = 'df$ratio', pop = 'df$pop') %>%
  filter(pct >= 0.8)

# df_tours <- filter(df_tours, df_tours$found == "TRUE")

df_ratio <- summarize(df_factors, df_factors = count(df_factors, ratio, found)) %>%
  filter(df_factors$found == "TRUE") %>%
  group_by(df_factors$ratio) %>%
  summarize(pct = df_factors$n/(NB_TAUX*NB_OCCURENCE*NB_POP)) %>% 
  ungroup() %>% 
  rename(ratio = 'df_factors$ratio')

df_pop <- summarize(df_factors, df_factors = count(df_factors, pop, found)) %>%
  filter(df_factors$found == "TRUE") %>%
  group_by(df_factors$pop) %>%
  summarize(pct = df_factors$n/(NB_TAUX*NB_OCCURENCE*NB_RATIO)) %>% 
  ungroup() %>% 
  rename(pop = 'df_factors$pop')

df_taux <- summarize(df_factors, df_factors = count(df_factors, taux, found)) %>%
  filter(df_factors$found == "TRUE") %>%
  group_by(df_factors$taux) %>%
  summarize(pct = df_factors$n/(NB_RATIO*NB_OCCURENCE*NB_POP)) %>% 
  ungroup() %>% 
  rename(taux = 'df_factors$taux')

# Plots
ggplot(data = df_ratio_pop, mapping = aes(x = pop, y = pct)) +
  geom_point(aes(color = ratio)) +
  geom_smooth(aes(linetype = ratio, color = ratio))+
  theme_minimal() +
  ggtitle("Réussite ratio par rapport à pop")

ggsave("ratio_pop.png")

ggplot(data = df_ratio_taux, mapping = aes(x = taux, y = pct)) +
  geom_point(aes(color = ratio)) +
  geom_smooth(aes(linetype = ratio, color = ratio))+
  theme_minimal() +
  ggtitle("Réussite ratio par rapport à taux")

ggsave("ratio_taux.png")

ggplot(data = df_ratio, mapping = aes(x = ratio, y=pct)) +
  geom_col(aes(fill = ratio)) +
  theme_minimal() +
  ggtitle("Réussite par rapport à ratio")

ggsave("reussite_ratio.png")

ggplot(data = df_taux, mapping = aes(x = taux, y=pct)) +
  geom_col(aes(fill = taux)) +
  theme_minimal() +
  ggtitle("Réussite par rapport à taux")

ggsave("reussite_taux.png")

ggplot(data = df_pop, mapping = aes(x = pop, y=pct)) +
  geom_col(aes(fill = pop)) +
  theme_minimal()+
  ggtitle("Réussite par rapport à pop")

ggsave("reussite_pop.png")

ggplot(data = df_ratio_taux_pop, mapping = aes(x = pop, y = taux)) +
  geom_jitter(aes(shape = ratio, size = pct, color = pct), width = 0.5, height = 0.5) +
  scale_color_gradient2(low = "red", high = "green", mid = "green", midpoint = 0.90)+
  theme_minimal()+
  ggtitle("Réussite par rapport à ratio, pop et taux")

ggsave("reussite_ratio_pop_taux.png")

ggplot() +
  geom_density(data = df_tours_15, mapping = aes(x = nbTours), color = "blue", show.legend = FALSE) +
  geom_density(data = df_tours_5, mapping = aes(x = nbTours), color = "green", show.legend = FALSE) +
  geom_density(data = df_tours_30, mapping = aes(x = nbTours), color = "purple", show.legend = FALSE) +
  geom_vline(aes(xintercept = 8), color = "red", alpha = 0.8, linetype = "dotted", show.legend = FALSE) +
  theme_minimal() +
  labs(title = "Répartition du nombre de tours requis", subtitle = "en violet, taux = 30%, en bleu, taux = 15%, en vert, taux = 5%")

ggsave("rep_nb_tours_density.png")

ggplot() +
  geom_count(data = filter(df_tours_30, found == "TRUE"), mapping = aes(x = taux, y = nbTours), color = "purple", show.legend = FALSE) +
  geom_count(data = filter(df_tours_15, found == "TRUE"), mapping = aes(x = taux,y = nbTours), color = "blue", show.legend = FALSE) +
  geom_count(data = filter(df_tours_5, found == "TRUE"), mapping = aes(x = taux, y = nbTours), color = "green", show.legend = FALSE) +
  theme_minimal() +
  labs(title = "Répartition du nombre de tours requis", subtitle = "en violet, taux = 30%, en bleu, taux = 15%, en vert, taux = 5%")

ggsave("rep_nb_tours_diff.png")

ggplot(mapping = aes(x = taux, y = nbTours)) +
  geom_violin(data = filter(df_tours_30, found == "TRUE"), fill = "purple", color = "purple", show.legend = FALSE) +
  geom_violin(data = filter(df_tours_15, found == "TRUE"), fill = "blue", color = "blue", show.legend = FALSE) +
  geom_violin(data = filter(df_tours_5, found == "TRUE"), fill = "green", color = "green", show.legend = FALSE) +
  theme_minimal() +
  labs(title = "Répartition du nombre de tours requis", subtitle = "en violet, taux = 30%, en bleu, taux = 15%, en vert, taux = 5%")

ggsave("rep_nb_tours_diff.png")