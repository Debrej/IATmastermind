library(ggplot2)
library(dplyr)
library(readr)

df = read_csv("eval.csv", col_types=cols(ratio=col_factor()))
df_factors = read_csv("eval.csv", col_types=cols(ratio=col_factor(), pop=col_factor(), taux=col_factor()))
df_tours = read_csv("evalFine.csv", col_types=cols(ratio=col_factor(), pop=col_factor(), taux=col_factor()))

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

ggplot(data = df_ratio_taux, mapping = aes(x = taux, y = pct)) +
  geom_point(aes(color = ratio)) +
  geom_smooth(aes(linetype = ratio, color = ratio))+
  theme_minimal() +
  ggtitle("Réussite ratio par rapport à taux")

ggplot(data = df_ratio, mapping = aes(x = ratio, y=pct)) +
  geom_col(aes(fill = ratio)) +
  theme_minimal() +
  ggtitle("Réussite par rapport à ratio")

ggplot(data = df_taux, mapping = aes(x = taux, y=pct)) +
  geom_col(aes(fill = taux)) +
  theme_minimal() +
  ggtitle("Réussite par rapport à taux")

ggplot(data = df_pop, mapping = aes(x = pop, y=pct)) +
  geom_col(aes(fill = pop)) +
  theme_minimal()+
  ggtitle("Réussite par rapport à pop")

ggplot(data = df_ratio_taux_pop, mapping = aes(x = pop, y = taux)) +
  geom_jitter(aes(shape = ratio, size = pct, color = pct), width = 0.5, height = 0.5) +
  scale_color_gradient2(low = "red", high = "green", mid = "green", midpoint = 0.90)+
  theme_minimal()+
  ggtitle("Réussite par rapport à ratio, pop et taux")

ggplot(data = df_tours, mapping = aes(x = nbTours)) +
  geom_density() +
  geom_vline(aes(xintercept = 8, color = "red", alpha = 0.8, linetype = "dotted"), show.legend = FALSE) +
  theme_minimal() +
  labs(title = "Répartition du nombre de tours requis", subtitle = "ratio du score = 3, pop = 200, taux de mutation = 5%")