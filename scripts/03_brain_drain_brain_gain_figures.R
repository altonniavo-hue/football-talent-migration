###############################################################
# BRAIN DRAIN / BRAIN GAIN — Player Migration & National Teams
# Thesis: Soccer talent export & Big Five influence
# Reference: Poli et al. (CIES), Milanovic (2005),
#            Baur & Lehmann (2007), Szymanski (2003)
###############################################################

# ── 0. PACKAGES ───────────────────────────────────────────────
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse, scales, ggrepel, patchwork,
  knitr, kableExtra, writexl, broom
)

setwd("/Users/niavo/Documents/TD économétrie M1")

league_colors <- c(
  "Premier League" = "#3F1F69",
  "La Liga"        = "#D4002A",
  "Bundesliga"     = "#E8001C",
  "Serie A"        = "#007AC2",
  "Ligue 1"        = "#1D4E89"
)

# ─────────────────────────────────────────────────────────────
# DATA 1 — Player export flows from emerging countries
# Source: CIES Football Observatory, 2024
# ─────────────────────────────────────────────────────────────

migration_df <- tribble(
  ~country,       ~region,          ~expatriates_big5, ~total_pro_players, ~fifa_rank_2024, ~wc_best_result,
  "Brazil",       "South America",  312,               2500,               5,               1,
  "Argentina",    "South America",  285,               2000,               1,               1,
  "France",       "West Africa",    NA,                NA,                 2,               1,   # kept as ref
  "Senegal",      "Africa",         124,               600,                20,              3,
  "Nigeria",      "Africa",         187,               900,                49,              3,
  "Ghana",        "Africa",         98,                550,                60,              3,
  "Ivory Coast",  "Africa",         112,               580,                62,              2,
  "Cameroon",     "Africa",         89,                500,                55,              3,
  "Morocco",      "Africa",         143,               700,                14,              3,
  "Colombia",     "South America",  156,               1100,               23,              2,
  "Ecuador",      "South America",  67,                450,                40,              2,
  "Uruguay",      "South America",  198,               800,                19,              3,
  "Mexico",       "CONCACAF",       45,                1200,               16,              2,
  "USA",          "CONCACAF",       89,                1500,               13,              2,
  "Serbia",       "Eastern Europe", 134,               700,                33,              2,
  "Croatia",      "Eastern Europe", 112,               600,                10,              3,
  "Portugal",     "Western Europe", 201,               900,                6,               3,
  "Netherlands",  "Western Europe", 178,               1000,               7,               3
) %>%
  filter(!is.na(expatriates_big5)) %>%
  mutate(
    export_rate   = expatriates_big5 / total_pro_players,
    export_rate_pct = export_rate * 100
  )

# ─────────────────────────────────────────────────────────────
# DATA 2 — Expatriate share by Big Five league (2024)
# Source: CIES Football Observatory Monthly Report, 2024
# ─────────────────────────────────────────────────────────────

league_origin_df <- tribble(
  ~league,          ~origin_region,      ~n_players,
  "Premier League", "Africa",            187,
  "Premier League", "South America",     142,
  "Premier League", "Eastern Europe",    98,
  "Premier League", "CONCACAF",          67,
  "Premier League", "Asia/Oceania",      23,
  "La Liga",        "South America",     198,
  "La Liga",        "Africa",            134,
  "La Liga",        "Eastern Europe",    67,
  "La Liga",        "CONCACAF",          45,
  "La Liga",        "Asia/Oceania",      18,
  "Bundesliga",     "Eastern Europe",    156,
  "Bundesliga",     "Africa",            112,
  "Bundesliga",     "South America",     89,
  "Bundesliga",     "CONCACAF",          34,
  "Bundesliga",     "Asia/Oceania",      45,
  "Serie A",        "South America",     167,
  "Serie A",        "Africa",            98,
  "Serie A",        "Eastern Europe",    78,
  "Serie A",        "CONCACAF",          23,
  "Serie A",        "Asia/Oceania",      12,
  "Ligue 1",        "Africa",            234,
  "Ligue 1",        "South America",     89,
  "Ligue 1",        "Eastern Europe",    56,
  "Ligue 1",        "CONCACAF",          34,
  "Ligue 1",        "Asia/Oceania",      15
)

# ─────────────────────────────────────────────────────────────
# DATA 3 — FIFA ranking evolution for key emerging countries
# Source: FIFA World Rankings archive, 2000-2024
# ─────────────────────────────────────────────────────────────

fifa_rank_df <- tribble(
  ~year, ~country,     ~fifa_rank, ~expatriate_rate,
  2000,  "Senegal",    60,  0.12,
  2004,  "Senegal",    40,  0.18,
  2008,  "Senegal",    55,  0.20,
  2012,  "Senegal",    62,  0.22,
  2016,  "Senegal",    28,  0.24,
  2020,  "Senegal",    20,  0.25,
  2024,  "Senegal",    20,  0.27,
  2000,  "Nigeria",    80,  0.15,
  2004,  "Nigeria",    35,  0.19,
  2008,  "Nigeria",    50,  0.21,
  2012,  "Nigeria",    45,  0.22,
  2016,  "Nigeria",    67,  0.24,
  2020,  "Nigeria",    48,  0.26,
  2024,  "Nigeria",    49,  0.28,
  2000,  "Ghana",      70,  0.10,
  2004,  "Ghana",      50,  0.14,
  2008,  "Ghana",      30,  0.18,
  2012,  "Ghana",      45,  0.20,
  2016,  "Ghana",      58,  0.22,
  2020,  "Ghana",      55,  0.24,
  2024,  "Ghana",      60,  0.25,
  2000,  "Morocco",    55,  0.12,
  2004,  "Morocco",    48,  0.16,
  2008,  "Morocco",    90,  0.18,
  2012,  "Morocco",    95,  0.22,
  2016,  "Morocco",    85,  0.26,
  2020,  "Morocco",    42,  0.30,
  2024,  "Morocco",    14,  0.34,
  2000,  "Colombia",   23,  0.09,
  2004,  "Colombia",   27,  0.12,
  2008,  "Colombia",   40,  0.15,
  2012,  "Colombia",   43,  0.16,
  2016,  "Colombia",   16,  0.19,
  2020,  "Colombia",   18,  0.21,
  2024,  "Colombia",   23,  0.22
)

# ─────────────────────────────────────────────────────────────
# DATA 4 — World Cup performance vs expatriate rate (2006-2022)
# Source: FIFA, CIES
# ─────────────────────────────────────────────────────────────

wc_df <- tribble(
  ~country,      ~wc_year, ~wc_round,  ~expat_rate, ~region,
  "Senegal",     2022,     5,          0.26,         "Africa",
  "Morocco",     2022,     6,          0.30,         "Africa",
  "Ghana",       2022,     3,          0.24,         "Africa",
  "Cameroon",    2022,     3,          0.22,         "Africa",
  "Nigeria",     2018,     3,          0.26,         "Africa",
  "Ivory Coast", 2014,     3,          0.21,         "Africa",
  "Colombia",    2014,     5,          0.19,         "South America",
  "Ecuador",     2022,     3,          0.15,         "South America",
  "Uruguay",     2018,     4,          0.24,         "South America",
  "Brazil",      2022,     5,          0.14,         "South America",
  "Argentina",   2022,     7,          0.16,         "South America",
  "Croatia",     2022,     6,          0.20,         "Eastern Europe",
  "Serbia",      2022,     3,          0.19,         "Eastern Europe",
  "Portugal",    2022,     5,          0.24,         "Western Europe",
  "Mexico",      2018,     3,          0.04,         "CONCACAF",
  "USA",         2022,     4,          0.06,         "CONCACAF"
) %>%
  mutate(
    wc_round_label = case_when(
      wc_round == 3 ~ "Group Stage",
      wc_round == 4 ~ "Round of 16",
      wc_round == 5 ~ "Quarter-Final",
      wc_round == 6 ~ "Semi-Final",
      wc_round == 7 ~ "Final/Winner"
    ),
    wc_round_label = factor(wc_round_label,
                            levels = c("Group Stage","Round of 16",
                                       "Quarter-Final","Semi-Final","Final/Winner"))
  )

###############################################################
# FIGURE 1 — Lollipop chart : expatriate count by country
###############################################################

fig1_data <- migration_df %>%
  arrange(desc(expatriates_big5)) %>%
  mutate(country = fct_reorder(country, expatriates_big5))

fig1 <- fig1_data %>%
  ggplot(aes(x = country, y = expatriates_big5, colour = region)) +
  geom_segment(aes(xend = country, y = 0, yend = expatriates_big5),
               size = 1) +
  geom_point(size = 4) +
  coord_flip() +
  scale_colour_brewer(palette = "Set1") +
  scale_y_continuous(breaks = seq(0, 350, 50)) +
  labs(
    title    = "Number of players exported to the Big Five leagues by country of origin",
    subtitle = "Emerging and semi-peripheral football nations, 2023/24 season",
    x        = NULL,
    y        = "Number of expatriate players in the Big Five",
    colour   = "Region",
    caption  = "Source: CIES Football Observatory (2024)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(colour = "grey40"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

ggsave("bd_fig1_lollipop_exportcount.pdf", fig1, width = 8, height = 6)
ggsave("bd_fig1_lollipop_exportcount.png", fig1, width = 8, height = 6, dpi = 300)
cat("✔ Figure 1 saved\n")

###############################################################
# FIGURE 2 — Stacked bar : origin region by Big Five league
###############################################################

fig2 <- league_origin_df %>%
  ggplot(aes(x = league, y = n_players, fill = origin_region)) +
  geom_col(position = "fill", width = 0.7) +
  scale_fill_brewer(palette = "Set2") +
  scale_y_continuous(labels = percent_format()) +
  labs(
    title    = "Geographic origin of foreign players in the Big Five leagues",
    subtitle = "Share of expatriate players by region of origin, 2023/24",
    x        = NULL,
    y        = "Share of foreign players",
    fill     = "Region of origin",
    caption  = "Source: CIES Football Observatory Monthly Report (2024)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(colour = "grey40"),
    legend.position = "bottom",
    axis.text.x   = element_text(angle = 15, hjust = 1),
    panel.grid.minor = element_blank()
  )

ggsave("bd_fig2_origin_stacked.pdf", fig2, width = 8, height = 5)
ggsave("bd_fig2_origin_stacked.png", fig2, width = 8, height = 5, dpi = 300)
cat("✔ Figure 2 saved\n")

###############################################################
# FIGURE 3 — FIFA ranking evolution for key emerging countries
###############################################################

fig3 <- fifa_rank_df %>%
  ggplot(aes(x = year, y = fifa_rank,
             colour = country, group = country)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  # Lower rank = better: invert y axis
  scale_y_reverse(breaks = seq(10, 100, 10)) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 4)) +